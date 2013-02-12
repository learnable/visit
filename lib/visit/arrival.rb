module Visit
  class Arrival
    class << self

      def create_if_interesting h

        o = get_visit_event_hash h

        if o
          begin
            ve = create_delegator o
          rescue
            CrashLog.notify $!
          end
        end
      end

      def get_vid cookies, session
        cookies["vid"] || session[:vid]
      end

      def create_delegator o
        Visit::Manage::log "Visit::Arrival::create_delegator"
        create_delegate o
      end

      def create_delegate o
        Visit::Manage::log "Visit::Arrival::create_delegate"

        ve = Visit::Event.new \
          vid:       o[:vid],
          user_id:   o[:user_id],
          remote_ip: o[:remote_ip]

        ve.url_id        = Visit::SourceValue.find_or_create_by_v(o[:url]).id
        ve.user_agent_id = Visit::SourceValue.find_or_create_by_v(o[:user_agent]).id
        ve.http_method   = o[:http_method]

        Visit::Manage::log "Visit::Arrival::create_delegator about to save ve: #{ve.to_yaml}"
          
        ve.save!

        # AMHERE TODO - use visit_cookies
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
            o[:cookies]     = h[:cookies].select { |k,v| [ :coupon ].include?(k) }
          end
        end

        ret
      end

    end
  end
end
