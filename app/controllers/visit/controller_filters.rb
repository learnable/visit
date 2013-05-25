module Visit
  module ControllerFilters
    extend ActiveSupport::Concern

    included do
      before_filter :set_visit_token
      before_filter :on_every_request
    end

    protected

    def create_visit_event(path = nil)
      create_if_interesting \
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

    def set_visit_token
      if !RequestPayload::get_token cookies, session
        session[:token] = rand(MAX)
      end
    end

    def on_every_request
      create_if_interesting \
        RequestPayload.new \
          request,
          cookies,
          session,
          Configurable.current_user_id.call(self),
          true,
          nil
    end

    def create_if_interesting(request_payload)
      if !request_payload.is_ignorable || !Visit::Event.ignore?(request_payload.get_path)
        begin
          Configurable.create.call request_payload.to_h
        rescue
          Configurable.notify.call $!
        end
      end
    end

  end
end
