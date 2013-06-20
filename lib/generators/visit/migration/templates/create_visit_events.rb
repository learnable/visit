class CreateVisitEvents < ActiveRecord::Migration
  def up
    create_table :visit_events do |t|
      t.integer  "http_method_enum"
      t.integer  "url_id", :references => :visit_source_values
      t.binary   "token"
      t.integer  "user_id"
      t.integer  "user_agent_id", :references => :visit_source_values
      t.integer  "referer_id", :references => :visit_source_values
      t.integer  "remote_ip", :limit => 8

      t.timestamp :created_at
    end

    # execute "ALTER TABLE visit_events DROP FOREIGN KEY fk_visit_events_user_id"

    # In Rails 3, t.binary maps to mysql BLOB, which is not what we want, we alter that below.
    # In Rails 4, t.binary maps to mysql VARCHAR.
    #
    # When all the gem's apps are on Rails 4, delete this ALTER TABLE.

    if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      execute "ALTER TABLE visit_events change token token VARBINARY(16) DEFAULT NULL"
    end

    add_index :visit_events, :user_id
    add_index :visit_events, :token
    add_index :visit_events, :created_at
  end


  def down
    drop_table :visit_events
  end
end
