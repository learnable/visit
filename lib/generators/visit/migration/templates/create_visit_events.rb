class CreateVisitEvents < ActiveRecord::Migration
  def change
    create_table :visit_events do |t|
      t.string   "http_method", :limit => 10
      t.string   "url"
      t.integer  "vid", :limit => 8
      t.integer  "user_id", :references => :users
      t.integer  "coupon"
      t.string   "user_agent"
      t.integer  "remote_ip"

      t.timestamp :created_at
    end

    add_index :visit_events, :vid
  end
end
