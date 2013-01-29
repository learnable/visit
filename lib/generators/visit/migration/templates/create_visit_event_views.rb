class CreateVisitEventViews < ActiveRecord::Migration
  def up

    stmt = <<-EOS
SELECT visit_events.id as id,
  http_method,
  url,
  user_id,
  vid,
  label_vav.v as label,
  sublabel_vav.v as sublabel,
  visit_events.created_at as created_at
FROM visit_events

LEFT OUTER JOIN visit_attributes label_va
ON visit_events.id = label_va.visit_event_id AND label_va.k_id = (select id from visit_attribute_values where v = 'label')
LEFT OUTER JOIN visit_attribute_values label_vav
ON label_vav.id = label_va.v_id

LEFT OUTER JOIN visit_attributes sublabel_va
ON visit_events.id = sublabel_va.visit_event_id AND sublabel_va.k_id = (select id from visit_attribute_values where v = 'sublabel')
LEFT OUTER JOIN visit_attribute_values sublabel_vav
ON sublabel_vav.id = sublabel_va.v_id
EOS

      create_view :visit_event_views, stmt do |t|
        t.column :id
        t.column :http_method
        t.column :url
        t.column :user_id
        t.column :label
        t.column :sublabel
        t.column :vid
        t.column :user_agent
        t.column :remote_ip
        t.column :created_at
      end
  end

  def down
    drop_view :visit_event_views
  end
end
