# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation
  To initialize database, run the following command in your terminal:
```
  .../ANC-3$./bin/initial_database_setup.sh <ENVIRONMENT> <SITE_CODE>
```
  Then load an openmrs_metadate from db folder. The command below should help
  you;
```
  .../ANC-3$mysql -u root -p openmrs_development_anc <
  db/openmrs_metadata_1_7.sql
```
  Enter mysql password when prompted.

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
