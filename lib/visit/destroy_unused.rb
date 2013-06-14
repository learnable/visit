require 'visit/has_temporary_cache'

module Visit
  class DestroyUnused

    include Visit::HasTemporaryCache

    def initialize(opts = {})
      @dry_run = opts[:dry_run]
      @keep_urls = opts[:keep_urls]
    end

    def irrevocable!
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
      temporary_cache_setup

      Event.includes(:visit_source_values_url).find_in_batches do |events|
        ignorable_events = events.select { |event| ignorable_event?(event) }

        if !dry_run?
          ids = ignorable_events.map(&:id)

          Source.delete_all(visit_event_id: ids)
          Event.delete ids
        end

        yield ignorable_events if block_given?
      end

      temporary_cache_teardown
    end

    def source_values!
      # The temporary table has fk references to the visit_source_values we want to keep.
      # visit_source_values that aren't pointed to by a fk reference are deleted.
      #
      CreateSourceValueRefererences.up

      Event.includes(:visit_sources).find_in_batches do |events|
        models = source_value_ids(events).map do |id|
          SourceValueReference.new fk: id
        end

        SourceValueReference.import models
      end

      condition = "id NOT IN (SELECT DISTINCT fk from visit_source_value_references)"

      SourceValue.delete_all(condition) if !dry_run?

      if block_given?
        SourceValue.where(condition).find_in_batches do |source_values|
          yield source_values
        end
      end

      CreateSourceValueRefererences.down
    end

    private

    def source_value_ids(events)
      {}.tap do |h|
        events.each do |event|
          if !dry_run? || !ignorable_event?(event)
            event.source_value_ids.each { |id| h[id] = true }
          end
        end
      end.keys
    end

    def dry_run?
      @dry_run
    end

    def keep_url?(event)
      @keep_urls && @keep_urls.any? { |re| event.url =~ re }
    end

    def ignorable_event?(event)
      !keep_url?(event) && event.ignorable?
    end

    class CreateSourceValueRefererences < ActiveRecord::Migration
      def self.up
        ActiveRecord::Migration.verbose = false
        create_table :visit_source_value_references, :temporary => true do |t|
          # this doesn't use t.references :visit_source_value because of http://bugs.mysql.com/bug.php?id=15324
          t.integer :fk, :null => false
        end
        add_index :visit_source_value_references, :fk
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
