require 'visit/has_ignorable.rb'

module Visit
  class RailsRequestContext < Struct.new(:request, :cookies, :session, :user_id, :must_insert, :hardcoded_path)
    include Visit::HasIgnorable

    def self.get_token(cookies, session)
      cookies["token"] || session[:token]
    end

    def path
      hardcoded_path || request.path
    end

    def get_token
      RailsRequestContext.get_token cookies, session
    end

    def to_h
      {}.tap do |h|
        h[:http_method] = request.method
        h[:url]         = get_url
        h[:token]       = get_token
        h[:user_id]     = user_id
        h[:user_agent]  = request.env["HTTP_USER_AGENT"]
        h[:referer]     = request.referer
        h[:remote_ip]   = request.remote_ip
        h[:cookies]     = RequestPayload.cookie_filter(cookies)
        h[:must_insert] = true if must_insert
        h[:created_at]  = Time.now
      end
    end

    private

    def get_url
      hardcoded_path.nil? ? request.url : hardcoded_path_to_url
    end

    def hardcoded_path_to_url
      request.url.sub(/\?.*/, "").sub(/(.*)#{request.path}/, '\1') + hardcoded_path
    end
  end
end
