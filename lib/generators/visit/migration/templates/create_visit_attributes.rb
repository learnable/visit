class CreateVisitAttributes < ActiveRecord::Migration
  def change
    create_table :visit_attributes do |t|
      t.integer :k_id, :null => false, :references => :visit_attribute_values # :references is the schemaplus gem
      t.integer :v_id, :null => false, :references => :visit_attribute_values

      t.references :visit_event, :null => false

      t.timestamp :created_at
    end
    
  end
end
