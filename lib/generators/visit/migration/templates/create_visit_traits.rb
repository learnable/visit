class CreateVisitTraits < ActiveRecord::Migration
  def change
    create_table :visit_traits do |t|
      t.integer :k_id, :null => false, :references => :visit_trait_values # :references is the schemaplus gem
      t.integer :v_id, :null => false, :references => :visit_trait_values

      t.references :visit_event, :null => false

      t.timestamp :created_at
    end
  end
end
