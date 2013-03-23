module Visit
  class RequestPayload < Struct.new(:request, :cookies, :session, :current_user, :is_ignorable, :path)

    def get_path
      path || request.path
    end

    def get_url
      path ? (request.scheme + "://" + request.host + "/" + path) : request.url
    end

  end
end
