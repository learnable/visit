visit
=====

Store some subset (or all) of an app's http requests in a database.

Get the data out using Active Record Query Interface.

Install the gem into your app
-----------------------------

    # add to Gemfile
    bundle
    rails generate visit:install
    rake db:migrate

Customise
---------

To customise, create a config/initializers/visit.rb, eg:

    class Visit::Configurable
      def self.ignorable
        [
          /^\/api/, # don't store requests to /api
        ]
      end
      def self.labels
        [
          [ :get, /^\/contact/, :contact_prompt, false ]
        ]
      end
      def self.create_visit o
        MySidekiqWorker.perform_async o # write to the db in a worker (don't slow down the Rails request cycle)
      end
    end

Assumed Models
--------------

Visit assumes there is a table 'users' existing in the database, and the
existence of a <code>current_user</code> controller helper.

Label and sublabels
-------------------
Visit::Configurable.labels allows the app to associate labels (and sublabels) with URL paths.

Which in turn supports queries like this:

    Visit::LabelledEventQuery.new.scoped.
      where("label_vtv.v = 'contact_prompt'").
      where(:created_at => (1.day.ago..Time.now)).
      count

Developing the gem
------------------

    git clone git@github.com:learnable/visit.git

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

This sql query creates a database view that denormalises (some of) the data that the gem is storing.
Look at this view through SequelPro to get a sense of what is being stored.

    CREATE VIEW visit_event_views AS
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

