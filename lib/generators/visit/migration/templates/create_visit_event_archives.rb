class CreateVisitEventArchives < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'postgresql'
      execute "CREATE TABLE visit_event_archives ( LIKE visit_events INCLUDING DEFAULTS )"
    else
      # ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      execute "CREATE TABLE visit_event_archives LIKE visit_events"
    end
  end

  def down
    drop_table :visit_event_archives
  end
end
