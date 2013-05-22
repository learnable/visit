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

    class Visit::Configurable.configure do |c|

      c.create = ->(o) do
        MySidekiqWorker.perform_async o # write to the db in a worker (don't slow down the Rails request cycle)
      end

      c.current_user_id = -> (controller) do
        controller.instance_eval { current_user ? current_user.id : nil }
      end

      c.ignorable = [
          /^\/api/, # don't store requests to /api
        ]

      c.labels_match_first = [
          [ :get, /^\/contact/, :contact_prompt ]
        ]

      c.notify = ->(e) do
        Airbrake.notify e # our app uses Airbrake for exception handling
      end

      c.current_user_id = ->(controller) do
        controller.instance_eval { current_user ? current_user.id : nil }
      end

      # lighten the load on the db (far fewer SELECTs)
      c.cache = Visit::Cache::Dalli.new \
        ActiveSupport::Cache.lookup_store \
          :dalli_store,
          "127.0.0.1:11211",
          { :namespace => "#{@app_name}::visit", :expires_in => 28.days }
    end

Assumed Models
--------------

The CreateVisitEvents migration has a foreign key reference to a 'users' table.
You can remove the foreign key reference and nothing will break.

Label and captures
------------------
Visit::Configurable.labels allows the app to associate labels (and regexp captures) with URL paths.

Which in turn supports queries like this:

    Visit::Query::LabelledEvent.new.scoped.
      where("label = 'contact_prompt'").
      where(created_at: (1.day.ago..Time.now)).
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

visit_event_views
-----------------
For debugging or ad-hoc sql queries it's sometimes nice to have a denormalised view of the data that the gem is storing.

This sql query creates a database view for that purpose.

    CREATE VIEW visit_event_views AS
    SELECT
      DISTINCT visit_events.id as id,
      visit_events.http_method_enum as http_method_enum,
      url_vsv.v as url,
      user_id,
      vid,
      label_vtv.v as label,
      capture1_vtv.v as capture1,
      capture2_vtv.v as capture2,
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
    
    LEFT OUTER JOIN visit_traits capture1_vt
      ON visit_events.id = capture1_vt.visit_event_id AND capture1_vt.k_id = (select id from visit_trait_values where v = 'capture1')
    LEFT OUTER JOIN visit_trait_values capture1_vtv
      ON capture1_vtv.id = capture1_vt.v_id
    
    LEFT OUTER JOIN visit_traits capture2_vt
      ON visit_events.id = capture2_vt.visit_event_id AND capture2_vt.k_id = (select id from visit_trait_values where v = 'capture2')
    LEFT OUTER JOIN visit_trait_values capture2_vtv
      ON capture2_vtv.id = capture2_vt.v_id

    ORDER BY visit_events.id ASC

TODO
----
MAJOR
* we've dropped the uniqueness validations and database constraints
  so we need a sweeper to fix duplicates

MODERATE
* support the visit_* tables living in separate db from the app
* Visit::Manage.archive_visit_events is broken
* created_at should correspond to Time.now in the Rails request cycle, not Time.now in the worker

MINOR
* don't hardcode 'users' as the 'users' table in the application - make it configurable
