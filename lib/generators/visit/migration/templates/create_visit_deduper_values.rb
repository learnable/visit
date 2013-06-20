class CreateVisitDeduperValues < ActiveRecord::Migration
  def self.up
    create_table :visit_deduper_values do |t|
      # this doesn't use t.references :visit_source_value because of http://bugs.mysql.com/bug.php?id=15324
      t.integer :fk, :null => false
    end
    add_index :visit_deduper_values, :fk
  end

  def self.down
    drop_table :visit_deduper_values
  end
end
