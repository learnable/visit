module Visit
  class Arrival
    class << self

      def create_if_interesting(request_payload)
        if !request_payload.is_ignorable || !Visit::Event.ignore?(request_payload.get_path)
          begin
            Configurable.create.call request_payload.to_h
          rescue
            Configurable.notify.call $!
          end
        end
      end

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

        event.url_id        = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(request_payload_hash[:url])
        event.user_agent_id = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(request_payload_hash[:user_agent])
        event.referer_id    = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(request_payload_hash[:referer])
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

    end
  end
end
