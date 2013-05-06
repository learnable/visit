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
      unless RequestPayload.extract_vid(cookies, session)
        session["vid"] = rand(MAX)
      end
    end

    def on_every_request
      Arrival.create_with_async(
        RequestPayload.new(
          request,
          cookies,
          session,
          visit_current_user,
          true
        ).formatted_hash
      )
    end

    def visit_current_user
      send(Configurable.current_user_alias)
    end
  end
end
