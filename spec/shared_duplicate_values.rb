class Duplicate
  class << self

    def setup
      Visit::Event.delete_all
      Visit::Source.delete_all
      Visit::SourceValue.delete_all
      Visit::Trait.delete_all
      Visit::TraitValue.delete_all

      run_requests_through_factory [
        { url: "http://e.org/articles" },
        { url: "http://e.org/articles/1" }
      ]
    end

    def create_duplicates_for_value(model_class)
      starting_point(model_class).each do |model|
        new_model = model_class.new(model.attributes)
        new_model.save!
      end
    end

    def create_duplicates_for_pair(model_class_pair, model_class_value)
      starting_point(model_class_value).map(&:id).each do |id|
        Visit::Query::PairsReferencingValues.new(model_class_pair, id).scoped.each do |model|
          new_model = model_class_pair.new(model.attributes)

          new_id = duplicate_corresponding_to(model_class_value, id)

          Visit::ValueDeduper.save_model_after_updating_attributes new_model, [:k_id, :v_id], new_id, [id]
        end
      end
    end

    def create_duplicates_for_event(model_class_value)
      starting_point(model_class_value).map(&:id).each do |id|
        Visit::Query::EventsReferencingValues.new(id).scoped.each do |model|
          new_model = Visit::Event.new
          [:http_method_enum, :url_id, :token, :user_id, :user_agent_id, :referer_id, :remote_ip].each do |attr|
            new_model[attr] = model[attr]
          end

          new_id = duplicate_corresponding_to(model_class_value, id)

          Visit::ValueDeduper.save_model_after_updating_attributes new_model, [:url_id, :user_agent_id, :referer_id], new_id, [id]
        end
      end
    end
    def starting_point(model_class)
      model_class.first(number_of_duplicates)
    end

    def duplicate_corresponding_to(model_class_value, id)
      model_class_value.where(v: model_class_value.find(id).v).last.id
    end

    def id_duplicates(model_class_value)
      Duplicate.starting_point(model_class_value).map(&:id).map do |id|
        Duplicate.duplicate_corresponding_to(model_class_value, id)
      end
    end

    def number_of_duplicates
      3
    end
  end
end
