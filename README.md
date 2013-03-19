visit
=====

Record visits to a site so that they're easy to analyse afterward

Assumed Models
--------------

Visit assumes there is a table 'users' existing in the database.

Development
-----------

Via <code>psql</code>
```psql
CREATE USER visit CREATEDB;
```

Then:
```bash
bundle
cd spec/dummy
bundle exec rake db:create
bundle exec rake db:migrate
```
