module Visit
  class Engine < ::Rails::Engine

  initializer "visit.blah" do |app|
    ActionController::Base.send(:include, Visit::ControllerFilters)
  end

  end
end
