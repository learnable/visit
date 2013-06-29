module Visit
  class Engine < ::Rails::Engine
    isolate_namespace Visit

    initializer "visit.blah" do |app|
      ActionController::Base.send(:include, Visit::ControllerFilters)
    end
  end
end
