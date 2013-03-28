module Visit
  # Taken from the Schema Plus gem. This is the only thing we needed.
  module AbstractAdapter
    # Create a view given the SQL definition.  Specify :force => true
    # to first drop the view if it already exists.
    def create_view(view_name, definition, options={})
      definition = definition.to_sql if definition.respond_to? :to_sql
      execute "DROP VIEW IF EXISTS #{quote_table_name(view_name)}" if options[:force]
      execute "CREATE VIEW #{quote_table_name(view_name)} AS #{definition}"
    end

    # Drop the named view
    def drop_view(view_name)
      execute "DROP VIEW #{quote_table_name(view_name)}"
    end
  end
end

