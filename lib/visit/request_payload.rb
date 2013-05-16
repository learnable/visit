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

  end
end
