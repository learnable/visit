module Visit
  class Arrival
    class << self

      def create_if_interesting h

        o = get_visit_event_hash h

        if o
          begin
            ve = create o
          rescue
            CrashLog.notify $!
          end
        end
      end

      def get_vid cookies, session
        cookies["vid"] || session[:vid]
      end

      def create o
        Visit::VisitEvent.create! o
      end

      private

      def get_visit_event_hash h
        path = h[:path] || h[:request].path
        url  = h[:path] ? (h[:request].host + "/" + h[:path]) : h[:request].url
        ret    = nil

        if !h[:is_request_ignorable] || !Visit::VisitEvent.ignore?(path)

          ret = {}.tap do |o|
            [ :coupon ].each do |k|
              o[k.to_sym] = h[:cookies].has_key?(k) ? h[:cookies][k] : nil
            end

            o[:http_method] = h[:request].method
            o[:url]         = url
            o[:vid]         = get_vid(h[:cookies], h[:session])
            o[:user_id]     = h[:current_user] ? h[:current_user].id : nil
            o[:user_agent]  = h[:request].env["HTTP_USER_AGENT"]
            o[:remote_ip]   = h[:request].remote_ip
          end
        end

        ret
      end

    end
  end
end
