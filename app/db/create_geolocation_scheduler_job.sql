BEGIN
  dbms_scheduler.create_job(job_name        => 'GET_GEOLOCATION_DATA',
                            job_type        => 'PLSQL_BLOCK',
                            job_action      => 'begin apexanalytics_app_pkg.process_ad_geolocation(p_app_id => 280); end;',
                            start_date      => systimestamp,
                            repeat_interval => 'FREQ=MINUTELY;INTERVAL=15;',
                            enabled         => TRUE);
END;
/
COMMIT;
