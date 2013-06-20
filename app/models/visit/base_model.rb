module Visit
  class BaseModel < ActiveRecord::Base
    establish_connection(Configurable.db_connection) if Configurable.db_connection

    self.table_name_prefix = 'visit_'

    self.abstract_class = true
  end
end
