class CreateVisitAttributeValues < ActiveRecord::Migration
  def change
    create_table :visit_attribute_values do |t|
      t.string :v, :null => false

      t.timestamp :created_at
    end

    add_index :visit_attribute_values, :v, :unique => true
  end
end
