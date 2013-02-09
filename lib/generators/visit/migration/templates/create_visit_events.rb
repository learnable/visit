class CreateVisitEvents < ActiveRecord::Migration
  def change
    create_table :visit_events do |t|
      t.integer  "vid", :limit => 8
      t.integer  "user_id", :references => :users
      t.integer  "remote_ip"

      t.timestamp :created_at
    end

    add_index :visit_events, :vid
  end
end
