module Visit
  class DestroyUnused
    class << self

      def rows!
        sources!
        events!
        source_values!
      end

      def events!
        Event.includes(:visit_source_values_url).find_in_batches do |events|
          ids  = events.select { |event| event.ignorable? }.map(&:id)

          Source.delete_all(visit_event_id: ids)
          Event.delete ids

          yield ids if block_given?
        end
      end

      def sources!
        Source.includes([:key, :value]).find_in_batches do |sources|
          ids = sources.select { |source| source.in_use? }.map(&:id)

          Source.delete ids

          yield ids if block_given?
        end
      end

      def source_values!
        CreateSourceValueIds.up

        Event.find_each do |event|
          models = event.source_value_ids.map do |id|
            SourceValueId.new visit_source_value_id: id
          end

          SourceValueId.import models, :validate => false
        end

        SourceValue.delete_all("id NOT IN (SELECT visit_source_value_id from visit_source_value_ids)")

        CreateSourceValueIds.down
      end

    end

    class CreateSourceValueIds < ActiveRecord::Migration
      def self.up
        ActiveRecord::Migration.verbose = false
        create_table :visit_source_value_ids, :temporary => true do |t|
          t.references :visit_source_value, :null => false
        end
      end
      def self.down
        drop_table :visit_source_value_ids
        ActiveRecord::Migration.verbose = true
      end
    end

    class SourceValueId < ActiveRecord::Base
      self.table_name_prefix = 'visit_'
    end
  end
end
