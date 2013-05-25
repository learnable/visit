module Visit
  class TagController < ::ApplicationController

    def create
      if !cookies["token"]
        cookies["token"] = session[:token]
        session["token"] = nil
      end

      head :ok, :content_type => "image/gif"
    end
  end
end
