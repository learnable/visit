module Visit
  module ControllerFilters
    extend ActiveSupport::Concern

    included do
      before_filter :set_visit_vid
      before_filter :on_every_request
    end

    protected

    def create_visit_event path = nil
      Visit::Arrival::create_visit_event \
        request: request,
        path: path,
        cookies: cookies,
        session: session,
        current_user: current_user,
        is_request_ignorable: false
    end

    private

    MAX = 9223372036854775807 # see: http://dev.mysql.com/doc/refman/5.1/en/numeric-types.html

    def set_visit_vid
      if !Visit::Arrival::get_vid cookies, session
        session[:vid] = rand(MAX)
      end
    end

    def on_every_request
      Visit::Arrival::create_visit_event \
        request: request,
        cookies: cookies,
        session: session,
        current_user: current_user,
        is_request_ignorable: true
    end

  end
end
