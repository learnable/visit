module Visit
  class RequestPayload < Struct.new(:request, :cookies, :session, :user_id, :is_ignorable, :path)

    def self.get_vid(cookies, session)
      cookies["vid"] || session[:vid]
    end

    def get_path
      path || request.path
    end

    def get_url
      path ? "#{request.scheme}://#{request.host}/#{path}" : request.url
    end

    def get_vid
      RequestPayload.get_vid cookies, session
    end

    def to_h
      {}.tap do |h|
        h[:http_method] = request.method
        h[:url]         = get_url
        h[:vid]         = get_vid
        h[:user_id]     = user_id
        h[:user_agent]  = request.env["HTTP_USER_AGENT"]
        h[:remote_ip]   = request.remote_ip
        h[:referer]     = request.referer
        h[:cookies]     = Configurable.cookies_to_hash.call cookies
        h[:created_at]  = Time.now
      end
    end
  end
end
