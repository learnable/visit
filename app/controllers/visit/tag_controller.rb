module Visit
  class TagController < ::ApplicationController

    def create
      if !cookies["vid"]
        cookies["vid"] = session[:vid]
        session["vid"] = nil
        Rails.logger.debug "AMHERE setting cookie vid: #{cookies['vid']}"
      end

      head :ok, :content_type => "image/gif"
    end
  end
end
