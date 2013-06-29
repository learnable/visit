module Visit
  class Factory
    class Collect
      attr_reader :boxes

      def initialize(model_class, boxes)
        @model_class = model_class
        @boxes = boxes
      end

      def self.import!(boxes)
        collect = new boxes
        collect.transform!
        collect.bulk_insert!
      end

      protected

      attr_reader :model_class

      def warm_cache_row(id, v, model_class)
        Configurable.cache.fetch(cache_key_for_v(v, model_class)) { id }

        if model_class == Visit::SourceValue
          Configurable.cache.fetch(Visit::Event.cache_key_for_id(id)) { v }
        end
      end

      def cache_key_for_v(v, model_class)
        model_class.cache_key_for_v v
      end

      private

      def bulk_insert_models!(models)
        Visit::Factory.instrumenter.mark "before_bulk_insert_#{model_class.table_name}" => models.count

        model_class.import columns, models, :validate => false

        Visit::Factory.instrumenter.mark "after_bulk_insert_#{model_class.table_name}" => nil
      end
    end

    class Collect::Values < Collect
      def initialize(model, boxes)
        super model, boxes

        @to_import = {}
      end

      def bulk_insert!
        models = [].tap do |models|
          @to_import.each do |v, created_at|
            models << [v, created_at]
          end
        end

        bulk_insert_models! models

        warm_cache(@to_import)

        Visit::Factory.instrumenter.mark "after_warm_cache_#{model_class.table_name}" => nil
      end

      def transform!
        @to_import = boxes_to_candidates

        dont_import_when_in_cache(@to_import)

        dont_import_when_in_db(@to_import)
      end

      protected

      def columns
        ["v", "created_at"]
      end

      def dont_import_when_in_cache(candidates)
        candidates.select! { |v, created_at| !Configurable.cache.has_key?(cache_key_for_v(v, model_class)) }
      end

      def dont_import_when_in_db(candidates)
        for_each_row_in_values_table(candidates) do |row|
          candidates.delete(row.v)

          warm_cache_row(row.id, row.v, model_class)
        end
      end

      def for_each_row_in_values_table(candidates)
        if !candidates.empty?
          values = candidates.keys

          begin
            subset = values.slice!(0, 1000)

            model_class.where(v: subset).each do |row|
              yield row
            end
          end while !values.empty?
        end
      end

      def warm_cache(candidates)
        for_each_row_in_values_table(candidates) do |row|
          warm_cache_row(row.id, row.v, model_class)
        end
      end
    end

    class Collect::SourceValues < Collect::Values
      def initialize(boxes)
        super Visit::SourceValue, boxes
      end

      protected

      def boxes_to_candidates
        {}.tap do |candidates|
          @boxes.each do |box|
            box.request_payload.to_values.each do |value|
              candidates[value] = box.request_payload[:created_at] unless candidates.has_key?(value)
            end
          end
        end
      end
    end

    class Collect::TraitValues < Collect::Values
      def initialize(boxes)
        super Visit::TraitValue, boxes
      end

      protected

      def boxes_to_candidates
        {}.tap do |candidates|
          @boxes.each do |box|
            box[:traits].each do |k,v|
              candidates[k.to_s] = box.event.created_at unless candidates.has_key?(k)
              candidates[v] = box.event.created_at unless candidates.has_key?(v)
            end
          end
        end
      end
    end    

    class Collect::Traits < Collect
      def initialize(boxes)
        super Visit::Trait, boxes
      end

      def transform!
        Visit::Factory.instrumenter.mark "before_transform_#{model_class.table_name}" => nil
        @boxes.each do |box|
          box[:traits] = box.event.to_traits.to_h
        end
        Visit::Factory.instrumenter.mark "after_transform_#{model_class.table_name}" => nil
      end

      def bulk_insert!
        models = @boxes.flat_map do |box|
          box[:traits].map do |k,v|
            [
              Visit::TraitValue.get_id_from_find_by_v(k),
              Visit::TraitValue.get_id_from_find_by_v(v),
              box.event.id,
              box.event.created_at
            ]
          end
        end

        bulk_insert_models! models
      end

      protected

      def columns
        ["k_id", "v_id", "visit_event_id", "created_at"]
      end
    end

    class Collect::Events < Collect
      def initialize(boxes)
        super Visit::Event, boxes
      end

      def bulk_insert!
        Visit::Factory.instrumenter.mark "before_bulk_insert_#{model_class.table_name}" => @boxes.count

        Event.transaction do
          @boxes.each do |box|
            event = Visit::Event.new \
              token:     box.request_payload[:token],
              user_id:   box.request_payload[:user_id],
              remote_ip: box.request_payload[:remote_ip]

            event.url_id        = payload_to_source_value_id box.request_payload[:url]
            event.user_agent_id = payload_to_source_value_id box.request_payload[:user_agent]
            event.referer_id    = payload_to_source_value_id box.request_payload[:referer]
            event.http_method   = box.request_payload[:http_method]
            event.created_at    = box.request_payload[:created_at]
            event.save!

            box.event = event
          end
        end

        Visit::Factory.instrumenter.mark "after_bulk_insert_#{model_class.table_name}" => @boxes.count
      end

      def transform!
      end

      private

      def payload_to_source_value_id(value)
        value.nil? ?
          nil :
          Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(value)
      end
    end

    class Collect::Sources < Collect
      def initialize(boxes)
        super Visit::Source, boxes

        @a = []
      end

      def transform!
        @boxes.each do |box|
          @a << {
            visit_event_id: box.event.id,
            created_at: box.request_payload[:created_at],
            pairs: box.request_payload.to_pairs
          }
        end
      end

      def bulk_insert!
        models = @a.flat_map do |h|
          h[:pairs].map do |h_pair|
            [
              h_pair[:k_id],
              h_pair[:v_id],
              h[:visit_event_id],
              h[:created_at]
            ]
          end
        end

        bulk_insert_models! models
      end

      protected

      def columns
        ["k_id", "v_id", "visit_event_id", "created_at"]
      end
    end
  end
end
