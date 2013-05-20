class CreateVisitSourceValues < ActiveRecord::Migration
  def change
    create_table :visit_source_values do |t|
      t.string :v, :null => false

      t.timestamp :created_at
    end

    add_index :visit_source_values, :v
  end
end
