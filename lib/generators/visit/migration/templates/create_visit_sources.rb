class CreateVisitSources < ActiveRecord::Migration
  def change
    create_table :visit_sources do |t|
      t.integer :k_id, :null => false, :references => :visit_source_values # :references is the schemaplus gem
      t.integer :v_id, :null => false, :references => :visit_source_values

      t.references :visit_event, :null => false

      t.timestamp :created_at
    end
  end
end
