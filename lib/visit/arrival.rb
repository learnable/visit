module Visit
  class Arrival
    class << self

      def create_visit_event h

        path = h[:path] || h[:request].path
        url  = h[:path] ? (h[:request].host + "/" + h[:path]) : h[:request].url

        if !h[:is_request_ignorable] || !Visit::VisitEvent.ignore?(path)

          c = {}
          [ :coupon ].each do |k|
            c[k.to_sym] = h[:cookies].has_key?(k) ? h[:cookies][k] : nil
          end

          begin
            ve = Visit::VisitEvent.create! \
              http_method: h[:request].method,
              url: url,
              vid: get_vid(h[:cookies], h[:session]),
              user_id: h[:current_user] ? h[:current_user].id : nil,
              coupon: c[:coupon],
              user_agent: h[:request].env["HTTP_USER_AGENT"],
              remote_ip: h[:request].remote_ip
          rescue
            CrashLog.notify $!
          end
        else
          Rails.logger.debug "AMHERE: ignored #{path}" # remove me
        end

      end

      def get_vid cookies, session
        cookies["vid"] || session[:vid]
      end

    end
  end
end
