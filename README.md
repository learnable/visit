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

    Visit::Configurable.configure do |c|

      c.bulk_insert_batch_size = 100 # cache requests in redis and bulk insert when cache size == 100

      c.cookies_match = [
        /flip_.*/, # save cookies set via the flip gem
      ]

      c.create = ->(request_payload_hashes) do
        # write to the db in a worker (don't slow down the Rails request cycle)
        # It's advised to implement this as some kind of async worker when using
        # the bulk_insert_batch_size option, otherwise event insertion will be
        # done during a request.
        VisitFactoryWorker.perform_async(request_payload_hashes)
      end

      c.current_user_id = -> (controller) do
        controller.instance_eval { current_user ? current_user.id : nil }
      end

      c.ignorable = [
          /^\/api/, # don't store requests to /api
        ]

      c.is_token_cookie_set_in = ->(sym) do
        sym == :visit_tag_controller # :application_controller or :visit_tag_controller
      end

      c.labels_match_first = [
          [ :get, /^\/contact/, :contact_prompt ]
        ]

      c.notify = ->(e) do
        Airbrake.notify e # our app uses Airbrake for exception handling
      end

      # lighten the load on the db (far fewer SELECTs)
      c.cache = Visit::Cache::Dalli.new \
        ActiveSupport::Cache.lookup_store \
          :dalli_store,
          "127.0.0.1:11211",
          { :namespace => "#{Rails.application.class.parent_name}::visit", :expires_in => 28.days }
    end

Sample implementation of `VisitFactoryWorker`:
```
class VisitFactoryWorker
  include Sidekiq::Worker

  def perform(request_payload_hashes)
    Visit::Factory.new.run(request_payload_hashes)
  end
end
```

Label and captures
------------------
Visit::Configurable.labels allows the app to associate labels (and regexp captures) with URL paths.

Which in turn supports queries like this:

    Visit::Query::LabelledEvent.new.scoped.
      where("label_vtv.v = 'dashboard'").
      where(created_at: (1.day.ago..Time.now)).
      count

Value Deduper
-------------
For internal consistency, the gem requires each row in tables visit_source_values and visit_trait_values 
to have a unique value of 'v'.

But because mysql indexes can only cover the first 255 chars of a VARCHAR column
(ignoring <code>innodb_large_prefix</code>), the 'v' columns have non-unique indexes.

So your app should periodically run Visit::ValueDeduper.run
(eg. daily) to eliminate duplicate values of 'v' and fix any references to those duplicates.

Here's what a sidekiq worker looks like:

    require "visit"

    class VisitValueDeduperWorker < BaseWorker
      def perform
        begin
          Visit::ValueDeduper.run
        rescue
          Airbrake.notify $!
        end
      end
    end

MySQL users: if you are happy to increase <code>innodb_large_prefix</code>, you can then
increase the index :length limits in the CreateVisitSourceValues and CreateVisitTraitValues migrations.
It might give you a little more lookup performance - when there are strings that are the
same in the first 255 chars and different after that.

Users
-----
The `visit_events` table has a column:  
    t.integer  "user_id", :references => :users

If your database doesn't have a `users` table, search for `user_id` in the `*_visit_*` migrations and
remove any foreign key reference to `users`.  Add an index on the `visit_events.user_id` column instead.

My app is part Rails and part non-Rails
---------------------------------------
<code>Onboarder.accept_unless_ignorable</code> decides whether an http request should be ignored and if not,
queues it to eventually create a Visit::Event.

In a Rails app, <code>Onboarder.accept_unless_ignorable</code> is called witin the Rails request cycle.

If you serve http requests via a non-Rails app (eg PHP), you can:
* shove all requests into redis, and
* in a Rails worker, take the request from redis and pass it to <code>Onboarder.accept_unless_ignorable</code>.

Deleting unused rows
--------------------
There are a number of ways you can be storing data you don't need:
* you don't set Configurable.ignorable,
* after using the gem for a while you narrow the set of cookies you're interested in (`Configurable.cookies_match`)

If you then want to save space in your database:

    bundle exec rails console
    > Visit::DestroyUnused.new(dry_run: true).sources! { |sources| puts sources.to_yaml }
    > Visit::DestroyUnused.new(dry_run: true).events! { |events| puts events.to_yaml }
    > Visit::DestroyUnused.new(dry_run: true).source_values! { |source_values| puts source_values.to_yaml }
    # ok, looks good, I'm now going to irrevocably delete!
    > Visit::DestroyUnused.new.irrevocable!

Developing the gem
------------------
    git clone git@github.com:learnable/visit.git

### mysql

    $ mysql -u root

    CREATE DATABASE visit;
    CREATE DATABASE visit_test;
    GRANT usage on *.* TO visit@localhost IDENTIFIED BY 'visit';
    GRANT ALL PRIVILEGES on visit.* to visit@localhost;
    GRANT ALL PRIVILEGES on visit_test.* to visit@localhost;

### postgres

Via <code>psql</code>
```psql
CREATE USER visit CREATEDB;
```

### Then
```bash
bundle
cd spec/dummy
bundle exec rake db:create
rails g visit:migration
bundle exec rake db:migrate
bundle exec rake db:migrate RAILS_ENV=test
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
      token,
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

MODERATE
* implement archiving - zip up everying over 3 months old and send to S3?

MINOR
* refactoring: SerializedList should become SerializedList::Redis
  (with 'require' in the initializer) with the gem defaulting to a new class: SerializedList::Memory
