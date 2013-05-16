module Visit
  module ControllerFilters
    extend ActiveSupport::Concern

    included do
      before_filter :set_visit_vid
      before_filter :on_every_request
    end

    protected

    def create_visit_event(path = nil)
      Arrival::create_if_interesting \
        RequestPayload.new \
          request,
          cookies,
          session,
          Configurable.current_user_id.call(self),
          false,
          path
    end

    private

    MAX = 9223372036854775807 # see: http://dev.mysql.com/doc/refman/5.1/en/numeric-types.html

    def set_visit_vid
      if !RequestPayload::get_vid cookies, session
        session[:vid] = rand(MAX)
      end
    end

    def on_every_request
      Arrival::create_if_interesting \
        RequestPayload.new \
          request,
          cookies,
          session,
          Configurable.current_user_id.call(self),
          true,
          nil
    end

  end
end
