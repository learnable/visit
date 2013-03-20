module Visit
  class Arrival
    class << self

      def create_if_interesting h

        o = get_visit_event_hash h

        if o
          begin
            ve = create_delegator o
          rescue
            # TODO: Put this back in.
            #CrashLog.notify $!
            puts $!
          end
        end
      end

      def get_vid cookies, session
        cookies["vid"] || session[:vid]
      end

      def create_delegator o
        # Visit::Manage::log "Visit::Arrival::create_delegator"
        create_delegate o
      end

      def create_delegate o
        ve = Visit::Event.new \
          vid:       o[:vid],
          user_id:   o[:user_id],
          remote_ip: o[:remote_ip]

        ve.url_id        = Visit::SourceValue.find_or_create_by_v(o[:url]).id
        ve.user_agent_id = Visit::SourceValue.find_or_create_by_v(o[:user_agent]).id
        ve.referer_id    = Visit::SourceValue.find_or_create_by_v(o[:referer]).id
        ve.http_method   = o[:http_method]
        ve.save!

        # Visit::Manage::log "Visit::Arrival::create_delegator saved ve: #{ve.to_yaml}"

        o[:cookies].each do |k,v|
          vs = Visit::Source.new
          vs.visit_event_id = ve.id
          vs.k_id = Visit::SourceValue.find_or_create_by_v(k).id
          vs.v_id = Visit::SourceValue.find_or_create_by_v(v).id
          vs.save!
        end

        ve
      end

      private

      def get_visit_event_hash h
        path = h[:path] || h[:request].path
        url  = h[:path] ? (h[:request].host + "/" + h[:path]) : h[:request].url
        ret    = nil

        if !h[:is_request_ignorable] || !Visit::Event.ignore?(path)
          ret = {}.tap do |o|
            o[:http_method] = h[:request].method
            o[:url]         = url
            o[:vid]         = get_vid(h[:cookies], h[:session])
            o[:user_id]     = h[:current_user] ? h[:current_user].id : nil
            o[:user_agent]  = h[:request].env["HTTP_USER_AGENT"]
            o[:remote_ip]   = h[:request].remote_ip
            o[:referer]     = h[:request].referer
            o[:cookies]     = get_visit_event_cookies h[:cookies]
          end
        end

        ret
      end

      def get_visit_event_cookies cookies
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
