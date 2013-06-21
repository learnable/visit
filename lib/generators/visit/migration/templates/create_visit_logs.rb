class CreateVisitLogs < ActiveRecord::Migration
  def self.up
    create_table :visit_logs do |t|
      t.string :category
      t.text :message, :null => false
    end
    add_index :visit_logs, :category
  end

  def self.down
    drop_table :visit_logs
  end
end
