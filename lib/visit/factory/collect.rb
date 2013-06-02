module Visit
  class Factory

    class Collect
      attr_reader :collection

      def initialize(model_class, collection, cache = nil)
        @model_class = model_class
        @collection = collection
        @cache = cache
      end

      protected

      attr_reader :model_class

      def cache
        @cache
      end

      private

      def bulk_insert!(models)
        model_class.import models, :validate => false
      end
    end

    class Collect::Values < Collect
      def initialize(model, collection, cache)
        super(model, collection, cache)
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

        ret = ret && !model_class.get_id_from_find_by_v(value, cache)
        # Manage.log "AMHERE 3: ret: #{ret}"

        ret
      end

      def cache_key(v)
        model_class.cache_key(v)
      end
    end

    class Collect::SourceValues < Collect::Values
      def transform!
        @collection.each do |request_payload_hash|
          RequestPayloadHashDecorator.new(request_payload_hash).to_values.each do |value|
            candidate_for_import(value, request_payload_hash[:created_at])
          end
        end
      end
    end

    class Collect::TraitValues < Collect::Values
      def transform!
        @collection.each do |o|
          o[:traits].each do |k,v|
            candidate_for_import(k, o[:event].created_at)
            candidate_for_import(v, o[:event].created_at)
          end
        end
      end
    end    

    class Collect::Traits < Collect
      def transform!
        @collection.each do |o|
          o[:traits] = Event::Traits.new(o[:event]).to_h
        end
      end

      def import!
        models = @collection.flat_map do |o|
          o[:traits].map do |k,v|
            model_class.new.tap do |model|
              model.k_id = Visit::TraitValue.get_id_from_find_by_v(k, cache)
              model.v_id = Visit::TraitValue.get_id_from_find_by_v(v, cache)
              model.visit_event_id = o[:event].id
              model.created_at = o[:event].created_at
            end
          end
        end

        bulk_insert! models
      end
    end

    class Collect::Events < Collect
      def import!
        ActiveRecord::Base.transaction do
          @collection.each do |request_payload_hash|
            event = Visit::Event.new \
              token:     request_payload_hash[:token],
              user_id:   request_payload_hash[:user_id],
              remote_ip: request_payload_hash[:remote_ip]

            event.url_id        = payload_to_source_value_id request_payload_hash[:url]
            event.user_agent_id = payload_to_source_value_id request_payload_hash[:user_agent]
            event.referer_id    = payload_to_source_value_id request_payload_hash[:referer]
            event.http_method   = request_payload_hash[:http_method]
            event.created_at    = request_payload_hash[:created_at]
            event.save!

            request_payload_hash[:event] = event
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
      def initialize(model, collection)
        super(model, collection)
        @a = []
      end

      def transform!
        @collection.each do |request_payload_hash|
          @a << {
            visit_event_id: request_payload_hash[:event].id,
            created_at: request_payload_hash[:created_at],
            pairs: RequestPayloadHashDecorator.new(request_payload_hash).to_pairs(Visit::SourceValue)
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
