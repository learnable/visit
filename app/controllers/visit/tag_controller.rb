module Visit
  class TagController < ::ApplicationController

    def create
      unless cookies["vid"]
        cookies["vid"] = session["vid"]
        session["vid"] = nil
      end

      head :ok, :content_type => "image/gif"
    end
  end
end
