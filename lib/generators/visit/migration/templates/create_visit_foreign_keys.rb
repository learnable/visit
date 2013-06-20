class CreateVisitForeignKeys < ActiveRecord::Migration
  def up
    if !indexes_exist?
      add_indexes!
    end
  end

  def down
    all_indexes.each do |h|
      execute "DROP FOREIGN KEY #{foreign_key_symbol(h)}"
    end
  end

  def indexes_exist?
    keys = [ "fk__visit_events_user_agent_id", "fk_visit_events_user_agent_id" ]

    keys.map { |k| index_exists? :visit_events, :user_agent_id, :name => k }.include? true
  end

  def add_indexes!
    grouped_indexes.each do |table, indexes|
      execute [
        "ALTER TABLE #{table}",
        indexes.map{|h|
          %Q{
            ADD CONSTRAINT #{foreign_key_symbol(h)}
            FOREIGN KEY (#{h[:foreign_key]})
            REFERENCES #{h[:references]}(id)
          }
        }.join(",\n")
      ].join("\n")
    end
  end

  def all_indexes
    [
      { table: "visit_events",  foreign_key: "url_id",         references: "visit_source_values" },
      { table: "visit_events",  foreign_key: "referer_id",     references: "visit_source_values" },
      { table: "visit_events",  foreign_key: "user_agent_id",  references: "visit_source_values" },
      { table: "visit_sources", foreign_key: "k_id",           references: "visit_source_values" },
      { table: "visit_sources", foreign_key: "v_id",           references: "visit_source_values" },
      { table: "visit_sources", foreign_key: "visit_event_id", references: "visit_events"        },
      { table: "visit_traits",  foreign_key: "k_id",           references: "visit_trait_values"  },
      { table: "visit_traits",  foreign_key: "v_id",           references: "visit_trait_values"  },
      { table: "visit_traits",  foreign_key: "visit_event_id", references: "visit_events"        },
    ]
  end

  def grouped_indexes
    all_indexes.reduce({}) do |acc, h|
      acc.merge(h[:table] => [h]){|k, v1, v2| v1 + v2}
    end
  end

  def foreign_key_symbol(h)
    "fk_#{h[:table]}_#{h[:foreign_key]}"
  end

end
