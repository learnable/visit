require "rails/generators/active_record/migration"

module Visit
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("../templates", __FILE__)

    def create_migration_file
      %w{
        visit_source_values
        visit_events
        visit_sources
        visit_trait_values
        visit_traits
        visit_foreign_keys
        visit_deduper_values
      }.each do |name|
        migration_template "create_#{name}.rb", "db/migrate/create_#{name}.rb"
      end
    end

    def self.next_migration_number(dirname)
      if @prev_num
        @prev_num += 1
      else
        @prev_num = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
      end
    end

  end
end
