class CreateVisitEvents < ActiveRecord::Migration
  def change
    create_table :visit_events do |t|
      t.integer  "http_method_enum"
      t.integer  "url_id", :references => :visit_source_values
      t.integer  "vid", :limit => 8
      t.integer  "user_id", :references => :users
      t.integer  "user_agent_id", :references => :visit_source_values
      t.integer  "remote_ip", :limit => 8

      t.timestamp :created_at
    end

    add_index :visit_events, :vid
  end
end
