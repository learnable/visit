class CreateVisitLogs < ActiveRecord::Migration
  def self.up
    create_table :visit_logs do |t|
      t.string :category
      t.text :message, :null => false
      
      t.timestamp :created_at
    end
    add_index :visit_logs, :category
  end

  def self.down
    drop_table :visit_logs
  end
end
