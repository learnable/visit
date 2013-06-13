module Visit
  class DestroyUnused
    def initialize(opts = {})
      @dry_run = opts[:dry_run]
    end

    def rows!
      sources!
      events!
      source_values!
    end

    def sources!
      Source.includes([:key, :value]).find_in_batches do |sources|
        sources_in_use = sources.select { |source| source.in_use? }

        Source.delete sources_in_use.map(&:id) if !dry_run?

        yield sources_in_use if block_given?
      end
    end

    def events!
      Event.includes(:visit_source_values_url).find_in_batches do |events|
        ignorable_events  = events.select { |event| event.ignorable? }

        if !dry_run?
          ids = ignorable_events.map(&:id)

          Source.delete_all(visit_event_id: ids)
          Event.delete ids
        end

        yield ignorable_events if block_given?
      end
    end

    def source_values!
      # The temporary table has fk references to the visit_source_values we want to keep.
      # visit_source_values that aren't pointed to by a fk reference are deleted.
      #
      CreateSourceValueRefererences.up

      Event.includes(:visit_sources).find_in_batches do |events|
        h = {}.tap do |h|
          events.each do |event|
            event.source_value_ids.each { |id| h[id] = true }
          end
        end

        models = h.keys.map do |id|
          SourceValueReference.new visit_source_value_id: id
        end

        SourceValueReference.import models
      end

      condition = "id NOT IN (SELECT DISTINCT visit_source_value_id from visit_source_value_references)"

      SourceValue.delete_all(condition) if !dry_run?

      if block_given?
        SourceValue.where(condition).find_each do |source_values|
          yield source_values
        end
      end

      CreateSourceValueRefererences.down
    end

    private

    def dry_run?
      @dry_run
    end

    class CreateSourceValueRefererences < ActiveRecord::Migration
      def self.up
        ActiveRecord::Migration.verbose = false
        create_table :visit_source_value_references, :temporary => true do |t|
          t.references :visit_source_value, :null => false
        end
      end

      def self.down
        drop_table :visit_source_value_references
        ActiveRecord::Migration.verbose = true
      end
    end

    class SourceValueReference < ActiveRecord::Base
      self.table_name_prefix = 'visit_'
    end
  end
end
