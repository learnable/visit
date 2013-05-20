module Visit
  class Factory

    class Collect
      attr_reader :collection

      def initialize(model_class, collection)
        @model_class = model_class
        @collection = collection
      end

      protected

      attr_reader :model_class

      private

      def bulk_insert!(models)
        model_class.import models, :validate => false
      end
    end

    class Collect::Values < Collect
      def initialize(model, collection)
        super(model, collection)
        @cache = Cache::Memory.new
      end

      def import!
        models = @cache.to_h.map do |cache_key, h|
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
          @cache.fetch(cache_key(value)) do
            { value: value, created_at: created_at }
          end
        end
      end

      private

      def should_import?(value)
        k = cache_key(value)

        ret = true
        # Manage.log "AMHERE 1: value: #{value} cache_key.to_s: #{k.to_s}" if k.key =~ /robot/

        ret = ret && !@cache.has_key?(k)
        # Manage.log "AMHERE 2: ret: #{ret}" if k.key =~ /robot/

        ret = ret && !Configurable.cache.has_key?(k)
        # Manage.log "AMHERE 3: ret: #{ret}" if k.key =~ /robot/

        ret = ret && model_class.find_by_v(value).nil?
        # Manage.log "AMHERE 4: ret: #{ret}"

        ret
      end

      def cache_key(value)
        model_class.cache_key(value)
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
              model.k_id = Visit::TraitValue.get_id_from_optimistic_find_or_create_by_v(k)
              model.v_id = Visit::TraitValue.get_id_from_optimistic_find_or_create_by_v(v)
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
        @collection.each do |request_payload_hash|
          event = Visit::Event.new \
            vid:       request_payload_hash[:vid],
            user_id:   request_payload_hash[:user_id],
            remote_ip: request_payload_hash[:remote_ip]

          event.url_id        = payload_to_source_value_id request_payload_hash, :url
          event.user_agent_id = payload_to_source_value_id request_payload_hash, :user_agent
          event.referer_id    = payload_to_source_value_id request_payload_hash, :referer
          event.http_method   = request_payload_hash[:http_method]
          event.created_at    = request_payload_hash[:created_at]
          event.save!

          request_payload_hash[:event] = event
        end
      end

      private

      def payload_to_source_value_id(h, key)
        value = h[key]

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
