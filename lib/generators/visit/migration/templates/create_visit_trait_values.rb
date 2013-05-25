class CreateVisitTraitValues < ActiveRecord::Migration
  def change
    create_table :visit_trait_values do |t|
      t.string :v, :null => false, :limit => 2048

      t.timestamp :created_at
    end

    add_index :visit_trait_values, :v
  end
end
