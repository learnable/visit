module Visit
  module ControllerFilters
    extend ActiveSupport::Concern

    included do
      before_filter :set_visit_vid
      before_filter :create_visit_event
    end

    private

    # Maximum unsigned INT in MySQL
    # http://dev.mysql.com/doc/refman/5.1/en/numeric-types.html
    #
    MAX = 4294967295

    def set_visit_vid
      if !get_visit_vid
        session[:vid] = rand(MAX)
      end
      Rails.logger.debug "AMHERE set_visit_id: session[:vid]: #{session[:vid]}"
    end

    def create_visit_event
      Rails.logger.debug "AMHERE create_visit_event: TODO"
      return

      if !VisitEvent.ignore? request.path

        begin
          ve = VisitEvent.create! \
            http_method: request.method,
            url: request.url,
            vid: get_visit_vid,
            user_id: current_user ? current_user.id : nil,
            user_agent: request.env["HTTP_USER_AGENT"],
            remote_ip: request.remote_ip
        rescue
          CrashLog.notify $!
        end
      end
    end

    def get_visit_vid
      cookies["vid"] || session[:vid]
    end

  end
end
