module Visit
  module ControllerFilters
    extend ActiveSupport::Concern

    included do
      before_filter :set_visit_vid
      before_filter :on_every_request
    end

    private

    MAX = 9223372036854775807 # see: http://dev.mysql.com/doc/refman/5.1/en/numeric-types.html

    def set_visit_vid
      unless Visit::RequestPayload.extract_vid(cookies, session)
        session["vid"] = rand(MAX)
      end
    end

    def on_every_request
      Visit::Arrival::create_if_interesting \
        Visit::RequestPayload.new \
          request,
          cookies,
          session,
          current_user,
          true,
          nil
    end

    def current_user
      eval(Configurable.current_user_alias.to_s)
    end
  end
end
