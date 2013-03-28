class CreateVisitEventViews < ActiveRecord::Migration
  def up

    stmt = <<-EOS
SELECT
  DISTINCT visit_events.id as id,
  visit_events.http_method_enum as http_method_enum,
  url_vsv.v as url,
  user_id,
  vid,
  label_vtv.v as label,
  sublabel_vtv.v as sublabel,
  user_agent_vsv.v as user_agent,
  visit_events.created_at as created_at
FROM visit_events

INNER JOIN visit_source_values url_vsv
  ON visit_events.url_id = url_vsv.id

INNER JOIN visit_source_values user_agent_vsv
  ON visit_events.user_agent_id = user_agent_vsv.id

LEFT OUTER JOIN visit_traits label_vt
ON visit_events.id = label_vt.visit_event_id AND label_vt.k_id = (select id from visit_trait_values where v = 'label')
LEFT OUTER JOIN visit_trait_values label_vtv
ON label_vtv.id = label_vt.v_id

LEFT OUTER JOIN visit_traits sublabel_vt
ON visit_events.id = sublabel_vt.visit_event_id AND sublabel_vt.k_id = (select id from visit_trait_values where v = 'sublabel')
LEFT OUTER JOIN visit_trait_values sublabel_vtv
ON sublabel_vtv.id = sublabel_vt.v_id

ORDER BY id ASC
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
    if ActiveRecord::Base.connection.views.include?("visit_event_views")
      drop_view :visit_event_views
    end
  end
end
