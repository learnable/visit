class CreateVisitForeignKeys < ActiveRecord::Migration
  def up
    if !visit_indexes_exist?
      add_indexes
    else
      puts "Indexes exist - doing nothing"
    end
  end

  def down
    visit_indexes.each do |h|
      execute "DROP FOREIGN KEY #{foreign_key_symbol(h)}"
    end
  end

  def visit_indexes_exist?
    keys = [ "fk__visit_events_user_id", "fk_visit_events_user_id" ]

    keys.map { |k| index_exists? :visit_events, :user_id, :name => k }.include? true
  end

  def add_indexes
    visit_indexes.each do |h|
      execute %Q{
        ALTER TABLE #{h[:table]}
        ADD CONSTRAINT #{foreign_key_symbol(h)}
        FOREIGN KEY (#{h[:foreign_key]})
        REFERENCES #{h[:references]}(id)
      }
    end
  end

  def foreign_key_symbol(h)
    "fk_#{h[:table]}_#{h[:foreign_key]}"
  end

  def visit_indexes
    [
      { table: "visit_events",  foreign_key: "user_id",        references: "users"               },
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
end
