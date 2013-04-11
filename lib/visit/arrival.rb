module Visit
  class Arrival
    class << self

      def create_if_interesting(rp)
        o = get_visit_event_hash rp

        if o
          begin
            ve = Visit::Configurable.create_visit o
          rescue
            # TODO: Put this back in.
            #CrashLog.notify $!
            puts $!
          end
        end
      end

      def create_visit(o)
        ve = Visit::Event.new \
          vid:       o[:vid],
          user_id:   o[:user_id],
          remote_ip: o[:remote_ip]

        ve.url_id        = Visit::SourceValue.optimistic_find_or_create_by_v(o[:url]).id
        ve.user_agent_id = Visit::SourceValue.optimistic_find_or_create_by_v(o[:user_agent]).id
        ve.referer_id    = Visit::SourceValue.optimistic_find_or_create_by_v(o[:referer]).id
        ve.http_method   = o[:http_method]
        ve.save!

        # Visit::Manage::log "Visit::Arrival::create_visit saved ve: #{ve.to_yaml}"

        o[:cookies].each do |k,v|
          vs = Visit::Source.new
          vs.visit_event_id = ve.id
          vs.k_id = Visit::SourceValue.optimistic_find_or_create_by_v(k).id
          vs.v_id = Visit::SourceValue.optimistic_find_or_create_by_v(v).id
          vs.save!
        end

        ve
      end

      private

      def get_visit_event_hash(rp)
        if !rp.is_ignorable || !Visit::Event.ignore?(rp.get_path)
          {}.tap do |o|
            o[:http_method] = rp.request.method
            o[:url]         = rp.get_url
            o[:vid]         = rp.get_vid
            o[:user_id]     = rp.current_user ? rp.current_user.id : nil
            o[:user_agent]  = rp.request.env["HTTP_USER_AGENT"]
            o[:remote_ip]   = rp.request.remote_ip
            o[:referer]     = rp.request.referer
            o[:cookies]     = get_visit_event_cookies rp.cookies
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
