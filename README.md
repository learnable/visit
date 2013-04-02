visit
=====

Record visits to a site so that they're easy to analyse afterward

Usage
-----

Parent app must override the 'labels' and 'ignorable' class methods of
Visit::Configurable

Assumed Models
--------------

Visit assumes there is a table 'users' existing in the database, and the
existence of a <code>current_user</code> controller helper.

Development
-----------

The main model is the model Visit::Event, which represents an HTTP request. The
various HTTP headers are stored as references into the visit_source_values
table. For example, the User Agent for a particular request may be
<code>"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.2 (KHTML,
like Gecko) Safari/125.8"</code>. This string is stored at the 'v' attribute in
a visit_source_values row, and the user_agent_id attribute of this model stores
the id of that row.

The vid attribute is the 'visit id', or can be thought of as the 'visitor id'.
It aims to be a basic identification method, linking together requests by the
same user.

The vid is persisted across requests via a cookie.

Via <code>psql</code>
```psql
CREATE USER visit CREATEDB;
```

Then:
```bash
bundle
cd spec/dummy
rails g visit:migration
bundle exec rake db:create
bundle exec rake db:migrate
RACK_ENV=test bundle exec rake db:migrate
```

visit_event_view
----------------

    CREATE VIEW visit_event_views
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
