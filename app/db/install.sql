SPOOL install.log

-- create sequences
@@sequences/analytics_data_seq.sql
@@sequences/analytics_data_geolocation_seq.sql
@@sequences/apex_app_pages_seq.sql
@@sequences/custom_analytic_queries_seq.sql

-- create tables
@@tables/analytics_data_table.sql
@@tables/analytics_data_geolocation_table.sql
@@tables/apex_apps_table.sql
@@tables/apex_app_pages_table.sql
@@tables/custom_analytic_queries_table.sql

-- create packages
@@packages/apexanalytics_app_pkg.pks
@@packages/apexanalytics_app_pkg.pkb

-- create jobs
@@jobs/create_geolocation_scheduler_job.sql

SPOOL OFF
