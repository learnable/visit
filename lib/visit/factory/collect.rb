module Visit
  class Factory

    class Collect
      attr_reader :boxes

      def initialize(model_class, boxes)
        @model_class = model_class
        @boxes = boxes
      end

      protected

      attr_reader :model_class

      private

      def bulk_insert!(models)
        model_class.import models, :validate => false
      end
    end

    class Collect::Values < Collect
      def initialize(model, boxes)
        super(model, boxes)
        @to_import = Cache::Memory.new
      end

      def import!
        models = @to_import.to_h.map do |cache_key, h|
          model_class.new.tap do |model|
            model.v = h[:value]
            model.created_at = h[:created_at]
          end
        end

        bulk_insert! models
      end

      protected

      def candidate_for_import(value, created_at)
        value = "" if value.nil?

        if should_import?(value)
          @to_import.fetch(cache_key(value)) do
            { value: value, created_at: created_at }
          end
        end
      end

      private

      def should_import?(value)
        k = cache_key(value)

        ret = true
        # Manage.log "AMHERE 1: value: #{value} k: #{k.to_s}"

        ret = ret && !@to_import.has_key?(k)
        # Manage.log "AMHERE 2: ret: #{ret}"

        ret = ret && !model_class.get_id_from_find_by_v(value)
        # Manage.log "AMHERE 3: ret: #{ret}"

        ret
      end

      def cache_key(v)
        model_class.cache_key(v)
      end
    end

    class Collect::SourceValues < Collect::Values
      def initialize(boxes)
        super Visit::SourceValue, boxes
      end

      def transform!
        @boxes.each do |box|
          box.request_payload.to_values.each do |value|
            candidate_for_import(value, box.request_payload[:created_at])
          end
        end
      end
    end

    class Collect::TraitValues < Collect::Values
      def initialize(boxes)
        super Visit::TraitValue, boxes
      end

      def transform!
        @boxes.each do |box|
          box[:traits].each do |k,v|
            candidate_for_import(k, box.event.created_at)
            candidate_for_import(v, box.event.created_at)
          end
        end
      end
    end    

    class Collect::Traits < Collect
      def initialize(boxes)
        super Visit::Trait, boxes
      end

      def transform!
        @boxes.each do |box|
          box[:traits] = box.event.to_traits
        end
      end

      def import!
        models = @boxes.flat_map do |box|
          box[:traits].map do |k,v|
            model_class.new.tap do |model|
              model.k_id = Visit::TraitValue.get_id_from_find_by_v(k)
              model.v_id = Visit::TraitValue.get_id_from_find_by_v(v)
              model.visit_event_id = box.event.id
              model.created_at = box.event.created_at
            end
          end
        end

        bulk_insert! models
      end
    end

    class Collect::Events < Collect
      def initialize(boxes)
        super Visit::Event, boxes
      end

      def import!
        ActiveRecord::Base.transaction do
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
        super(Visit::Source, boxes)
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

      def import!
        models = @a.flat_map do |h|
          h[:pairs].map do |h_pair|
            model_class.new.tap do |model|
              model.k_id = h_pair[:k_id]
              model.v_id = h_pair[:v_id]
              model.visit_event_id = h[:visit_event_id]
              model.created_at = h[:created_at]
            end
          end
        end

        bulk_insert! models
      end
    end
  end
end
