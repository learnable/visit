class CreateVisitEventViews < ActiveRecord::Migration
  def up

    stmt = <<-EOS
SELECT visit_events.id as id,
  visit_events.http_method_enum as http_method_enum,
  url_vsv.v as url,
  user_id,
  vid,
  label_vav.v as label,
  sublabel_vav.v as sublabel,
  user_agent_vsv.v as user_agent,
  visit_events.created_at as created_at
FROM visit_events

INNER JOIN visit_source_values url_vsv
  ON visit_events.url_id = url_vsv.id

INNER JOIN visit_source_values user_agent_vsv
  ON visit_events.user_agent_id = user_agent_vsv.id

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
        t.column :http_method_enum
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
