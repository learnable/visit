module Visit
  module HasPath
    def path
      uri = Addressable::URI.parse(url)

      ret = url

      if uri.host
        ret = uri.path
        ret += "?#{uri.query}" if uri.query
        ret += "##{uri.fragment}" if uri.fragment
      end

      ret
    end
  end
end
