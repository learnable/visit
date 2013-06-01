module Visit
  module ControllerFilters
    extend ActiveSupport::Concern

    included do
      before_filter :set_visit_token
      before_filter :on_every_visit_request
    end

    protected

    def create_visit_event(path = nil)
      create_if_interesting_visit \
        RequestPayload.new \
          request,
          cookies,
          session,
          Configurable.current_user_id.call(self),
          false,
          path
    end

    private

    def set_visit_token
      if !RequestPayload::get_token cookies, session
        if Configurable.is_token_cookie_set_in.call :application_controller
          cookies["token"] = random_visit_token
        else
          session["token"] = random_visit_token
        end
      end
    end

    def on_every_visit_request
      create_if_interesting_visit \
        RequestPayload.new \
          request,
          cookies,
          session,
          Configurable.current_user_id.call(self),
          true,
          nil
    end

    def create_if_interesting_visit(request_payload)
      if !request_payload.is_ignorable || !Visit::Event.ignore?(request_payload.get_path)
        begin
          serialized_list = SerializedList.new("request_payload_hashes")

          serialized_list.append request_payload.to_h

          if serialized_list.length >= Configurable.bulk_insert_batch_size
            Configurable.create.call serialized_list.values

            serialized_list.clear
          end
        rescue
          Configurable.notify.call $!
        end
      end
    end

    def random_visit_token
      SecureRandom.base64(Visit::Event.token_length).slice(0,Visit::Event.token_length)
    end

  end
end
