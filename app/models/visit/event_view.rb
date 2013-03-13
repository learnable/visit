module Visit
  class EventView < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    self.primary_key = "id"

    include Visit::StoresIpAddress
    stores_ip_address :remote_ip

    scope :with_label, where("label IS NOT NULL")

    scope :with_distinct_vids_for_user , ->(user_id) { select("distinct vid").where(user_id: user_id) }

    scope :with_visit_by_user, ->(user_id) { where(vid: with_distinct_vids_for_user(user_id)) }

    def self.newer_than_row row
      row.nil? ? self : where("created_at > ?", row.created_at)
    end

  end
end
