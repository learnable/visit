module Visit
  class Engine < ::Rails::Engine
    isolate_namespace Visit

    initializer "visit.blah" do |app|
      ActionController::Base.send(:include, Visit::ControllerFilters)
      SchemaPlus.setup do |config|
        config.foreign_keys.auto_create = false;
        config.foreign_keys.auto_index = false;
      end
    end

  end
end
