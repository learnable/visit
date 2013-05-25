class CreateVisitEvents < ActiveRecord::Migration
  def change
    create_table :visit_events do |t|
      t.integer  "http_method_enum"
      t.integer  "url_id", :references => :visit_source_values
      t.integer  "user_id", :references => :users
      t.integer  "user_agent_id", :references => :visit_source_values
      t.integer  "referer_id", :references => :visit_source_values
      t.integer  "remote_ip", :limit => 8

      t.timestamp :created_at
    end

    execute "ALTER TABLE visit_events ADD token VARBINARY(16) DEFAULT NULL AFTER url_id"

    add_index :visit_events, :token
    add_index :visit_events, :created_at
  end
end
