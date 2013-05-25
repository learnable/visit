class CreateVisitEvents < ActiveRecord::Migration
  def up
    create_table :visit_events do |t|
      t.integer  "http_method_enum"
      t.integer  "url_id", :references => :visit_source_values
      t.integer  "user_id", :references => :users
      t.integer  "user_agent_id", :references => :visit_source_values
      t.integer  "referer_id", :references => :visit_source_values
      t.integer  "remote_ip", :limit => 8

      t.timestamp :created_at
    end

    # t.binary ought to do the job here, except that
    # in Rails 3, t.binary maps to BLOB.
    #
    # In Rails 4, t.binary maps to VARCHAR so when all the gem's apps are on Rails 4
    # this migration can be made more rails-y.
    #
    execute "ALTER TABLE visit_events ADD token VARBINARY(16) DEFAULT NULL AFTER url_id"

    add_index :visit_events, :token
    add_index :visit_events, :created_at
  end

  def down
    drop_table :visit_events
  end
end
