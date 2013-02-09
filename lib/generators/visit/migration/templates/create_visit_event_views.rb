class CreateVisitEventViews < ActiveRecord::Migration
  def up

    stmt = <<-EOS
SELECT visit_events.id as id,
  http_method_vsv.v as http_method,
  url_vsv.v as url,
  user_id,
  vid,
  label_vav.v as label,
  sublabel_vav.v as sublabel,
  visit_events.created_at as created_at
FROM visit_events

LEFT OUTER JOIN visit_sources http_method_vs
ON visit_events.id = http_method_vs.visit_event_id
   AND http_method_vs.k_id = (select id from visit_source_values where v = 'http_method')
LEFT OUTER JOIN visit_source_values http_method_vsv
ON http_method_vsv.id = http_method_vs.v_id

LEFT OUTER JOIN visit_sources url_vs
ON visit_events.id = url_vs.visit_event_id
   AND url_vs.k_id = (select id from visit_source_values where v = 'url')
LEFT OUTER JOIN visit_source_values url_vsv
ON url_vsv.id = url_vs.v_id

LEFT OUTER JOIN visit_sources user_agent_vs
ON visit_events.id = user_agent_vs.visit_event_id
   AND user_agent_vs.k_id = (select id from visit_source_values where v = 'user_agent')
LEFT OUTER JOIN visit_source_values user_agent_vsv
ON user_agent_vsv.id = user_agent_vs.v_id

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
