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

      c.bulk_insert_batch_size = 100 # cache requests in a SerializedQueue (see below)

      # This method is called when requests are on the :available SerializedQueue
      # Your options are:
      # - don't override this method in your app, Visit::Factory.new.run will insert these
      #   requests (in the Rails request cycle)
      # - override this method in your app and delegate Visit::Factory.new.run to a worker
      # - override this method in your app, make it do nothing, because you have workers
      #   that pop directly from the :available queue
      #
      c.bulk_insert_now = ->() do
        Visit::Factory.new.run
      end

      c.cookies_match = [
        /^flip_/, # save cookies set via the flip gem
      ]

      c.current_user_id = -> (controller) do
        controller.instance_eval { current_user ? current_user.id : nil }
      end

      c.ignorable = [
          /^\/api/, # don't store requests to /api
        ]

      # Some slow-running parts of the gem are instrumented.
      # To get a sense of it, bundle exec rails console:
      # > puts Visit::Log.last.to_instrumenter_history.to_s
      #
      c.instrumenter_toggle = ->(category) do
        true # category == :deduper || category == :factory
      end

      c.is_token_cookie_set_in = ->(sym) do
        sym == :visit_tag_controller # :application_controller or :visit_tag_controller
      end

      c.labels_match_first = [
          [ :get, %r{^/contact}, :contact_prompt ]
        ]

      # urls containing ?invite=blah generate a trait: { :invite => :blah }
      #
      c.labels_match_all = c.labels_match_all.push *[
        [ :get, %r{[?&]invite=(\w+)}, :invite ]
      ]

      # If you set bulk_insert_batch_size > 1, you need a persistent SerializedQueue:
      # - in your app, add 'redis' to your Gemfile
      # - in your app, configure redis in config/initializers/redis.rb: $redis = Redis.connect(url: Settings.redis.url)
      #
      require 'redis'
      c.serialized_queue = ->() { Visit::SerializedQueue::Redis.new($redis) }

      # our app uses Airbrake for exception handling
      #
      c.notify = ->(e) { Airbrake.notify e } unless Rails.env.development?

      # lighten the load on the db (far fewer SELECTs)
      #
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

  def perform
    Visit::Factory.new.run
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

How it works
------------
In brief:
- a controller filter builds a request_payload_hash (containing everything interesting about a web request),
  and pushes it onto the :filling SerializedQueue
- when the :filling SerializedQueue is full? it is moved into an :available SerializedQueue
  and Configurable.bulk_insert_now is called
- the request_payload_hashes are removed from the :available SerializedQueue and inserted into the database.

Non Rails apps can push directly onto the :filling queue.

Deduper
-------
The gem supports [eventual consistency](http://en.wikipedia.org/wiki/Eventual_consistency)
of SourceValues and TraitValues for reasons of:
* performance (bulk insert of n requests is many times faster than n inserts),
* scalability (multiple workers can by bulk inserting at the same time), and
* mysql indexes can only cover the first 255 chars of a VARCHAR column
  (ignoring <code>innodb_large_prefix</code>), so the 'v' columns must have non-unique indexes.

When consistent, each row in tables visit_source_values and visit_trait_values have a unique value of 'v'.

To create consistency, your app should periodically run Visit::Deduper.new.run
(eg. daily) to eliminate duplicate values of 'v' and fix any references to those duplicates.

Here's what a sidekiq worker looks like:

    require "visit"

    class VisitDeduperWorker < BaseWorker
      def perform
        begin
          Visit::Deduper.new.run
        rescue
          Airbrake.notify $!
        end
      end
    end

MySQL users: if you are happy to increase <code>innodb_large_prefix</code>, you can then
increase the index :length limits in the CreateVisitSourceValues and CreateVisitTraitValues migrations.
It might give you a little more lookup performance - when there are strings that are the
same in the first 255 chars and different after that.

My app is part Rails and part non-Rails
---------------------------------------
If you serve http requests via a non-Rails app (eg PHP), you can
`rpush` directly into the :filling SerializedQueue.  To figure out:
- the format of the hash, see: rails_request_context.rb, and
- the redis key, run from the Rails console, `Visit::SerializedQueue::Redis.new($redis, :filling).send(:key)`

Destroying unused rows
----------------------
There are a number of ways you can be storing data you don't need:
* you don't set Configurable.ignorable,
* you narrow the set of cookies you're interested in (`Configurable.cookies_match`)

If you then want to save space in your database:

    bundle exec rails console
    > Visit::DestroyUnused.new(dry_run: true).sources! { |sources| puts sources.map { |source| [source.key.v, source.value.v] } }
    > Visit::DestroyUnused.new(dry_run: true).events! { |events| puts events.map { |event| event.url } }
    # oh, I want to keep a url that's ignored, because I created it via `create_visit_event`
    > Visit::DestroyUnused.new(dry_run: true, keep_urls: [ %r{/api} ]).events! { |events| puts events.map { |event| event.url } }
    > Visit::DestroyUnused.new(dry_run: true).source_values! { |source_values| puts source_values.map { |sv| sv.v } }
    # ok, looks good, I'm now going to irrevocably delete!
    > Visit::DestroyUnused.new(keep_urls: [ %r{/api} ]).irrevocable!

Flush Configurable.cache
---------------------------

    bundle exec rails console
    > Visit::Configurable.cache.has_key? Visit::Cache::Key.new("visit::traitvalue.find_by_v.id", "label")
    true
    > Visit::Configurable.cache.clear
    [true]
    > Visit::Configurable.cache.has_key? Visit::Cache::Key.new("visit::traitvalue.find_by_v.id", "label")
    false

Configure the gem to not use the default database
-------------------------------------------------
    Visit::Configurable.configure do |c|

      c.db_connect = "visit_database_for_#{Rails.env}"

    end

And in your database.yml:

    visit_database_for_development:
      database: visit_development

    visit_database_for_test:
      database: visit_test

    visit_database_for_production:
      database: visit_production

And of course you need to create those databases, set permissions, apply schemas etc.

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
* archiving - zip up everying over n months old and send to S3?
* support a use-case in which all an app has to do is shove a request payload into redis and it's done.    
