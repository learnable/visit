module Visit
  module ControllerFilters
    extend ActiveSupport::Concern

    included do
      before_filter :set_visit_token
      before_filter :on_every_visit_request
    end

    protected

    def must_insert_visit_event(path = nil)
      Onboarder.new.accept_unless_ignorable \
        RailsRequestContext.new \
          request,
          cookies,
          session,
          Configurable.current_user_id.call(self),
          true,
          path
    end

    private

    def set_visit_token
      if !RailsRequestContext::get_token cookies, session
        if Configurable.token_cookie_mutator == :application_controller
          cookies["token"] = Helper.random_token
        else
          session["token"] = Helper.random_token
        end
      end
    end

    def on_every_visit_request
      Onboarder.new.accept_unless_ignorable \
        RailsRequestContext.new \
          request,
          cookies,
          session,
          Configurable.current_user_id.call(self),
          false,
          nil
    end
  end
end
