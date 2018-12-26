CREATE OR REPLACE PACKAGE apexanalytics_app_pkg IS
  --
  -- Insert data into ANALYTCIS_DATA table
  -- #param p_analytics_id
  -- #param p_agent_name
  -- #param p_agent_version
  -- #param p_agent_language
  -- #param p_os_name
  -- #param p_os_version
  -- #param p_has_touch_support
  -- #param p_page_load_time
  -- #param p_screen_width
  -- #param p_screen_height
  -- #param p_apex_app_id
  -- #param p_apex_page_id
  -- #param p_apex_event_name
  -- #param p_additional_info
  -- #param p_anonymous_ip_address
  PROCEDURE insert_analytics_data(p_analytics_id         IN analytics_data.analytics_id%TYPE,
                                  p_agent_name           IN analytics_data.agent_name%TYPE,
                                  p_agent_version        IN analytics_data.agent_version%TYPE,
                                  p_agent_language       IN analytics_data.agent_language%TYPE,
                                  p_os_name              IN analytics_data.os_name%TYPE,
                                  p_os_version           IN analytics_data.os_version%TYPE,
                                  p_has_touch_support    IN analytics_data.has_touch_support%TYPE,
                                  p_page_load_time       IN analytics_data.page_load_time%TYPE,
                                  p_screen_width         IN analytics_data.screen_width%TYPE,
                                  p_screen_height        IN analytics_data.screen_height%TYPE,
                                  p_apex_app_id          IN analytics_data.apex_app_id%TYPE,
                                  p_apex_page_id         IN analytics_data.apex_page_id%TYPE,
                                  p_apex_event_name      IN analytics_data.apex_event_name%TYPE,
                                  p_additional_info      IN analytics_data.additional_info%TYPE,
                                  p_anonymous_ip_address IN analytics_data.anonymous_ip_address%TYPE);
  --
  -- Parse input JSON and output to single out-params
  -- #param p_json_clob
  -- #param p_analytics_id
  -- #param p_agent_name
  -- #param p_agent_version
  -- #param p_agent_language
  -- #param p_os_name
  -- #param p_os_version
  -- #param p_has_touch_support
  -- #param p_page_load_time
  -- #param p_screen_width
  -- #param p_screen_height
  -- #param p_apex_app_id
  -- #param p_apex_page_id
  -- #param p_apex_event_name
  -- #param p_additional_info
  PROCEDURE parse_analytics_data_json(p_json_clob         IN CLOB,
                                      p_analytics_id      OUT analytics_data.analytics_id%TYPE,
                                      p_agent_name        OUT analytics_data.agent_name%TYPE,
                                      p_agent_version     OUT analytics_data.agent_version%TYPE,
                                      p_agent_language    OUT analytics_data.agent_language%TYPE,
                                      p_os_name           OUT analytics_data.os_name%TYPE,
                                      p_os_version        OUT analytics_data.os_version%TYPE,
                                      p_has_touch_support OUT analytics_data.has_touch_support%TYPE,
                                      p_page_load_time    OUT analytics_data.page_load_time%TYPE,
                                      p_screen_width      OUT analytics_data.screen_width%TYPE,
                                      p_screen_height     OUT analytics_data.screen_height%TYPE,
                                      p_apex_app_id       OUT analytics_data.apex_app_id%TYPE,
                                      p_apex_page_id      OUT analytics_data.apex_page_id%TYPE,
                                      p_apex_event_name   OUT analytics_data.apex_event_name%TYPE,
                                      p_additional_info   OUT analytics_data.additional_info%TYPE);
  --
  -- Check if required values are present in JSON payload
  -- #param p_analytics_id
  -- #param p_agent_name
  -- #param p_agent_version
  -- #param p_agent_language
  -- #param p_os_name
  -- #param p_os_version
  -- #param p_has_touch_support
  -- #param p_page_load_time
  -- #param p_screen_width
  -- #param p_screen_height
  -- #param p_apex_app_id
  -- #param p_apex_page_id
  -- #param p_apex_event_name
  PROCEDURE check_required_values(p_analytics_id      IN analytics_data.analytics_id%TYPE,
                                  p_agent_name        IN analytics_data.agent_name%TYPE,
                                  p_agent_version     IN analytics_data.agent_version%TYPE,
                                  p_agent_language    IN analytics_data.agent_language%TYPE,
                                  p_os_name           IN analytics_data.os_name%TYPE,
                                  p_os_version        IN analytics_data.os_version%TYPE,
                                  p_has_touch_support IN analytics_data.has_touch_support%TYPE,
                                  p_page_load_time    IN analytics_data.page_load_time%TYPE,
                                  p_screen_width      IN analytics_data.screen_width%TYPE,
                                  p_screen_height     IN analytics_data.screen_height%TYPE,
                                  p_apex_app_id       IN analytics_data.apex_app_id%TYPE,
                                  p_apex_page_id      IN analytics_data.apex_page_id%TYPE,
                                  p_apex_event_name   IN analytics_data.apex_event_name%TYPE);
  --
  -- Process ORDS REST web service call
  -- #param p_json_clob
  -- #param p_app_id
  PROCEDURE process_rest_post_call(p_json_clob IN CLOB,
                                   p_app_id    IN NUMBER);
  --
  -- Get anonymous IP address from CGI env (removed last byte)
  -- #param p_remove_ip_bytes
  -- #return VARCHAR2
  FUNCTION get_anonymous_remote_ip(p_remove_ip_bytes IN NUMBER := 1) RETURN VARCHAR2;
  --
  -- Check if anonymous IP tracking is enabled in App-Settings
  -- #param p_app_id
  -- #return BOOLEAN
  FUNCTION is_anonym_ip_tracking_enabled(p_app_id IN NUMBER) RETURN BOOLEAN;
  --
  -- Get prepared IP address, xxx is replaces with 1 --> 8.8.xxx.xxx > 8.8.1.1
  -- #param p_ip_address
  -- #return VARCHAR2
  FUNCTION get_prepared_ip_address(p_ip_address IN VARCHAR2) RETURN VARCHAR2;
  --
  -- Get value of specific APP_SETTINGS entry for specific APP_ID
  -- #param p_app_id
  -- #param p_name
  -- #return VARCHAR2
  FUNCTION get_app_settings_value(p_app_id IN NUMBER,
                                  p_name   IN VARCHAR2) RETURN VARCHAR2;
  --
  -- Get geolocation of IP address using REST API from ipstack
  -- #param p_base_url
  -- #param p_ip_address
  -- #param p_api_key
  -- #param p_wallet_path
  -- #param p_wallet_pwd
  -- #param p_continent_code
  -- #param p_continent_name
  -- #param p_country_code
  -- #param p_country_name
  PROCEDURE get_ipstack_geolocation(p_base_url       IN VARCHAR2,
                                    p_ip_address     IN VARCHAR2,
                                    p_api_key        IN VARCHAR2,
                                    p_wallet_path    IN VARCHAR2 := NULL,
                                    p_wallet_pwd     IN VARCHAR2 := NULL,
                                    p_continent_code OUT VARCHAR2,
                                    p_continent_name OUT VARCHAR2,
                                    p_country_code   OUT VARCHAR2,
                                    p_country_name   OUT VARCHAR2);
  --
  -- Insert data into ANALYTCIS_DATA_GEOLOCATION table
  -- #param p_analytics_data_id
  -- #param p_continent_code
  -- #param p_continent_name
  -- #param p_country_code
  -- #param p_country_name
  PROCEDURE insert_ad_geolocation(p_analytics_data_id IN analytics_data_geolocation.analytics_data_id%TYPE,
                                  p_continent_code    IN analytics_data_geolocation.continent_code%TYPE,
                                  p_continent_name    IN analytics_data_geolocation.continent_name%TYPE,
                                  p_country_code      IN analytics_data_geolocation.country_code%TYPE,
                                  p_country_name      IN analytics_data_geolocation.country_name%TYPE);
  --
  -- Process geolocation REST call and insert into ANALYTCIS_DATA_GEOLOCATION
  -- #param p_app_id
  PROCEDURE process_ad_geolocation(p_app_id IN NUMBER);
  --
END apexanalytics_app_pkg;
/
