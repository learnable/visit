module Visit
  class ValueDeduper
    class << self
      def run
        {
          Visit::Source => Visit::SourceValue,
          Visit::Trait => Visit::TraitValue
        }.each do |model_class_pair, model_class_value|
          Query::DuplicateValue.new(model_class_value).scoped.pluck(:v).each do |v|
            for_each_duplicate(model_class_pair, model_class_value, v) do |id_primary, id_duplicates|
              change_references_in_table_pair model_class_pair, id_primary, id_duplicates

              change_references_in_table_event id_primary, id_duplicates if model_class_pair == Visit::Source

              destroy_values model_class_value, id_duplicates
            end
          end
        end
      end

      def for_each_duplicate(model_class_pair, model_class_value, v)
        id_duplicates = model_class_value.select(:id).where(v: v).order("id ASC").pluck(:id)

        id_primary = id_duplicates.delete_at(0)

        yield id_primary, id_duplicates
      end

      def save_model_after_updating_attributes(row, attributes, id_new, ids_old)
        attributes.each do |attribute|
          row[attribute] = id_new if ids_old.include? row[attribute]
        end
        row.save!
      end

      private

      def change_references_in_table_pair(model_class_pair, id_primary, id_duplicates)
        Query::PairsReferencingValues.new(model_class_pair, id_duplicates).scoped.each do |row|
          ValueDeduper.save_model_after_updating_attributes(row, [:k_id, :v_id], id_primary, id_duplicates)
        end
      end

      def change_references_in_table_event(id_primary, id_duplicates)
        Query::EventsReferencingValues.new(id_duplicates).scoped.each do |row|
          ValueDeduper.save_model_after_updating_attributes(row, [:url_id, :user_agent_id, :referer_id], id_primary, id_duplicates)
        end
      end

      def destroy_values(model_class_value, id_duplicates)
        model_class_value.delete_all(id: id_duplicates)
      end
    end
  end
end
