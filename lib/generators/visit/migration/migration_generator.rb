require "rails/generators/active_record/migration"

class Visit::MigrationGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path("../templates", __FILE__)

  def create_migration_file
    %w{
      visit_source_values
      visit_events
      visit_event_archives
      visit_sources
      visit_trait_values
      visit_traits
      visit_event_views
    }.each do |name|
      migration_template "create_#{name}.rb", "db/migrate/create_#{name}.rb"
      sleep 1
    end
  end

  def self.next_migration_number(dirname)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

end
