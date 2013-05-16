module Visit
  class Arrival
    class << self

      def create_if_interesting(request_payload)
        if !request_payload.is_ignorable || !Visit::Event.ignore?(request_payload.get_path)
          begin
            ve = Configurable.create.call request_payload.to_h
          rescue
            Configurable.notify.call $!
          end
        end
      end

      def create(o)
        ve = create_visit(o)

        TraitFactory.new.create_traits_for_visit_events [ ve ]

        ve
      end

      private

      def create_visit(o)
        ve = Visit::Event.new \
          vid:       o[:vid],
          user_id:   o[:user_id],
          remote_ip: o[:remote_ip]

        ve.url_id        = SourceValue.get_id_from_optimistic_find_or_create_by_v(o[:url])
        ve.user_agent_id = SourceValue.get_id_from_optimistic_find_or_create_by_v(o[:user_agent])
        ve.referer_id    = SourceValue.get_id_from_optimistic_find_or_create_by_v(o[:referer])
        ve.http_method   = o[:http_method]
        ve.created_at    = o[:created_at] # prem reminder re: flippa PHP app
        ve.save!

        # Manage::log "Arrival::create_visit saved ve: #{ve.to_yaml}"

        o[:cookies].each do |k,v|
          vs = Source.new
          vs.visit_event_id = ve.id
          vs.k_id = SourceValue.get_id_from_optimistic_find_or_create_by_v(k)
          vs.v_id = SourceValue.get_id_from_optimistic_find_or_create_by_v(v)
          vs.created_at = o[:created_at] # prem reminder re: flippa PHP app
          vs.save!
        end

        ve
      end

    end
  end
end
