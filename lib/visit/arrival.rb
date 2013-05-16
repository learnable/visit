module Visit
  class Arrival
    class << self

      def create_if_interesting(request_payload)
        o = get_visit_event_hash request_payload

        if o
          begin
            ve = Configurable.create.call o
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

      def get_visit_event_hash(request_payload)
        if !request_payload.is_ignorable || !Visit::Event.ignore?(request_payload.get_path)
          {}.tap do |o|
            o[:http_method] = request_payload.request.method
            o[:url]         = request_payload.get_url
            o[:vid]         = request_payload.get_vid
            o[:user_id]     = request_payload.user_id
            o[:user_agent]  = request_payload.request.env["HTTP_USER_AGENT"]
            o[:remote_ip]   = request_payload.request.remote_ip
            o[:referer]     = request_payload.request.referer
            o[:cookies]     = Configurable.cookies_to_hash request_payload.cookies
            o[:created_at]  = Time.now
          end
        else
          nil
        end
      end

    end
  end
end
