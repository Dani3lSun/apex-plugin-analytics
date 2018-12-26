SPOOL install.log

-- create sequences
@analytics_data_seq.sql
@analytics_data_geolocation_seq.sql
@apex_app_pages_seq.sql

-- create tables
@analytics_data_table.sql
@analytics_data_geolocation_table.sql
@apex_apps_table.sql
@apex_app_pages_table.sql

-- create packages
@apexanalytics_app_pkg.pks
@apexanalytics_app_pkg.pkb

-- create jobs
@create_geolocation_scheduler_job.sql

SPOOL OFF
