module Visit
  class Arrival
    class << self


      def create(request_payload_hash)
        event = create_visit(request_payload_hash)

        TraitFactory.new.create_traits_for_visit_events [ event ]

        event
      end

      private

      def create_visit(request_payload_hash)
        request_payload_hash.symbolize_keys!

        event = Visit::Event.new \
          vid:       request_payload_hash[:vid],
          user_id:   request_payload_hash[:user_id],
          remote_ip: request_payload_hash[:remote_ip]

        event.url_id        = payload_to_source_value_id request_payload_hash, :url
        event.user_agent_id = payload_to_source_value_id request_payload_hash, :user_agent
        event.referer_id    = payload_to_source_value_id request_payload_hash, :referer
        event.http_method   = request_payload_hash[:http_method]
        event.created_at    = request_payload_hash[:created_at] # prem reminder re: flippa PHP app
        event.save!

        # Manage::log "Arrival::create_visit saved event: #{event.to_yaml}"

        request_payload_hash[:cookies].each do |k,v|
          vs = Visit::Source.new
          vs.visit_event_id = event.id
          vs.k_id = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(k)
          vs.v_id = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(v)
          vs.created_at = request_payload_hash[:created_at]
          vs.save!
        end

        event
      end

      def payload_to_source_value_id(h, key)
        value = h[key]

        value.nil? ?
          nil :
          Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(value)
      end
    end
  end
end
