module Visit
  class RequestPayload < Struct.new(:request, :cookies, :session, :current_user, :is_ignorable)

    class << self

      def extract_vid(cookies, session)
        cookies["vid"] || session["vid"]
      end
    end

    def url
      url = request.url || "#{request.scheme}://#{request.host}/#{request.path}"
    end

    def vid
      self.class.extract_vid(cookies, session)
    end

    def formatted_hash
      {
        http_method: request.method,
        url:         url,
        vid:         vid,
        user_id:     current_user.present? ? current_user.id : nil,
        user_agent:  request.env["HTTP_USER_AGENT"],
        remote_ip:   request.remote_ip,
        referer:     request.referer,
        cookies:     visit_event_cookies(cookies)
      }
    end

    def path
      request.path
    end

    private

    def visit_event_cookies(cookies)
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
