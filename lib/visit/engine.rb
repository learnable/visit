module Visit
  class Engine < ::Rails::Engine
    isolate_namespace Visit

    initializer "visits" do |app|
      if Visit::Configurable.requests_interceptor_enabled
        ActionController::Base.send(:include, Visit::ControllerFilters)
      end
    end

  end
end
