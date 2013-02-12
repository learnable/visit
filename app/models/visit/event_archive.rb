module Visit
  class EventArchive < ActiveRecord::Base
    self.table_name_prefix = 'visit_'
  end
end
