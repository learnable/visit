module Visit
  class Arrival
    class << self

      def create_if_interesting(rp)
        o = get_visit_event_hash rp

        if o
          begin
            ve = Visit::Configurable.create.call o
          rescue
            Visit::Configurable.notify.call $!
          end
        end
      end

      def create(o)
        ve = create_visit(o)

        Visit::TraitFactory.new.create_traits_for_visit_events [ ve ]

        ve
      end

      private

      def create_visit(o)
        ve = Visit::Event.new \
          vid:       o[:vid],
          user_id:   o[:user_id],
          remote_ip: o[:remote_ip]

        ve.url_id        = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(o[:url])
        ve.user_agent_id = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(o[:user_agent])
        ve.referer_id    = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(o[:referer])
        ve.http_method   = o[:http_method]
        ve.created_at    = o[:created_at] # prem reminder re: flippa PHP app
        ve.save!

        # Visit::Manage::log "Visit::Arrival::create_visit saved ve: #{ve.to_yaml}"

        o[:cookies].each do |k,v|
          vs = Visit::Source.new
          vs.visit_event_id = ve.id
          vs.k_id = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(k)
          vs.v_id = Visit::SourceValue.get_id_from_optimistic_find_or_create_by_v(v)
          vs.created_at = o[:created_at] # prem reminder re: flippa PHP app
          vs.save!
        end

        ve
      end

      def get_visit_event_hash(rp)
        if !rp.is_ignorable || !Visit::Event.ignore?(rp.get_path)
          {}.tap do |o|
            o[:http_method] = rp.request.method
            o[:url]         = rp.get_url
            o[:vid]         = rp.get_vid
            o[:user_id]     = rp.user_id
            o[:user_agent]  = rp.request.env["HTTP_USER_AGENT"]
            o[:remote_ip]   = rp.request.remote_ip
            o[:referer]     = rp.request.referer
            o[:cookies]     = get_visit_event_cookies rp.cookies
            o[:created_at]  = Time.now
          end
        else
          nil
        end
      end

      def get_visit_event_cookies(cookies)
        {}.tap do |h|
          features = {}
          cookies.each do |k,v|
            if k == :coupon
              h[:coupon] = v
            elsif k =~ /flip_(.*?)_(.*$)/
              features[$2] = v
            end
          end
          h[:features] = features.to_json unless features.empty?
        end
      end

    end
  end
end
