module Visit
  class RailsRequestContext < Struct.new(:request, :cookies, :session, :user_id, :is_ignorable, :path)

    def self.get_token(cookies, session)
      cookies["token"] || session[:token]
    end

    def get_path
      path || request.path
    end

    def get_url
      path ? "#{request.scheme}://#{request.host}/#{path}" : request.url
    end

    def get_token
      RailsRequestContext.get_token cookies, session
    end

    def ignorable?
      is_ignorable && Visit::Event.ignore?(get_path)
    end

    def to_h
      {}.tap do |h|
        h[:http_method] = request.method
        h[:url]         = get_url
        h[:token]       = get_token
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
