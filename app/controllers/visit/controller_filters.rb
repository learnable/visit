module Visit
  module ControllerFilters
    extend ActiveSupport::Concern

    included do
      before_filter :set_visit_token
      before_filter :on_every_visit_request
    end

    protected

    def create_visit_event(path = nil)
      Onboarder.accept_unless_ignorable \
        RailsRequestContext.new \
          request,
          cookies,
          session,
          Configurable.current_user_id.call(self),
          false,
          path
    end

    private

    def set_visit_token
      if !RailsRequestContext::get_token cookies, session
        if Configurable.is_token_cookie_set_in.call :application_controller
          cookies["token"] = random_visit_token
        else
          session["token"] = random_visit_token
        end
      end
    end

    def on_every_visit_request
      Onboarder.accept_unless_ignorable \
        RailsRequestContext.new \
          request,
          cookies,
          session,
          Configurable.current_user_id.call(self),
          true,
          nil
    end

    def random_visit_token
      SecureRandom.base64(Visit::Event::TOKEN_LENGTH).slice(0,Visit::Event::TOKEN_LENGTH)
    end

  end
end
