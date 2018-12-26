CREATE OR REPLACE PACKAGE BODY apexanalytics_app_pkg IS
  --
  -- Insert data into ANALYTCIS_DATA table
  -- #param p_analytics_id
  -- #param p_agent_name
  -- #param p_agent_version
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
                                  p_anonymous_ip_address IN analytics_data.anonymous_ip_address%TYPE) IS
    --
  BEGIN
    --
    INSERT INTO analytics_data
      (analytics_id,
       agent_name,
       agent_version,
       os_name,
       os_version,
       has_touch_support,
       page_load_time,
       screen_width,
       screen_height,
       apex_app_id,
       apex_page_id,
       apex_event_name,
       additional_info,
       anonymous_ip_address,
       date_created)
    VALUES
      (p_analytics_id,
       p_agent_name,
       p_agent_version,
       p_os_name,
       p_os_version,
       p_has_touch_support,
       nvl(p_page_load_time,
           0),
       p_screen_width,
       p_screen_height,
       p_apex_app_id,
       p_apex_page_id,
       p_apex_event_name,
       p_additional_info,
       p_anonymous_ip_address,
       SYSDATE);
    --
  END insert_analytics_data;
  --
  -- Parse input JSON and output to single out-params
  -- #param p_json_clob
  -- #param p_analytics_id
  -- #param p_agent_name
  -- #param p_agent_version
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
                                      p_os_name           OUT analytics_data.os_name%TYPE,
                                      p_os_version        OUT analytics_data.os_version%TYPE,
                                      p_has_touch_support OUT analytics_data.has_touch_support%TYPE,
                                      p_page_load_time    OUT analytics_data.page_load_time%TYPE,
                                      p_screen_width      OUT analytics_data.screen_width%TYPE,
                                      p_screen_height     OUT analytics_data.screen_height%TYPE,
                                      p_apex_app_id       OUT analytics_data.apex_app_id%TYPE,
                                      p_apex_page_id      OUT analytics_data.apex_page_id%TYPE,
                                      p_apex_event_name   OUT analytics_data.apex_event_name%TYPE,
                                      p_additional_info   OUT analytics_data.additional_info%TYPE) IS
    --
    l_json_values    apex_json.t_values;
    l_encoded_call   VARCHAR2(10);
    l_encoded_string VARCHAR2(32767);
    l_decoded_string VARCHAR2(32767);
    l_divider        VARCHAR2(10) := ':::';
    l_string_values  apex_t_varchar2;
    --
    -- Helper function base64decode
    FUNCTION base64_decode(p_base64_string IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(p_base64_string)));
    END base64_decode;
    --
  BEGIN
    --
    BEGIN
      apex_json.parse(p_values => l_json_values,
                      p_source => p_json_clob);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20003,
                                'JSON payload cannot be parsed.');
    END;
    --
    l_encoded_call := apex_json.get_varchar2(p_path   => 'encodeWebserviceCall',
                                             p_values => l_json_values);
    --
    -- values are base64 encoded in JSON payload
    IF l_encoded_call = 'Y' THEN
      l_encoded_string := apex_json.get_varchar2(p_path   => 'encodedString',
                                                 p_values => l_json_values);
      IF l_encoded_string IS NOT NULL THEN
        l_decoded_string := base64_decode(p_base64_string => l_encoded_string);
      ELSE
        raise_application_error(-20001,
                                'Missing required values in JSON payload.');
      END IF;
      l_string_values := apex_string.split(p_str => l_decoded_string,
                                           p_sep => l_divider);
      --
      p_analytics_id      := l_string_values(1);
      p_agent_name        := l_string_values(2);
      p_agent_version     := l_string_values(3);
      p_os_name           := l_string_values(4);
      p_os_version        := l_string_values(5);
      p_has_touch_support := nvl(l_string_values(6),
                                 'N');
      p_page_load_time    := nvl(l_string_values(7),
                                 0);
      p_screen_width      := l_string_values(8);
      p_screen_height     := l_string_values(9);
      p_apex_app_id       := l_string_values(10);
      p_apex_page_id      := l_string_values(11);
      p_apex_event_name   := l_string_values(12);
      p_additional_info   := l_string_values(13);
      --                                        
      -- values are directly in JSON payload
    ELSIF l_encoded_call = 'N' THEN
      p_analytics_id      := apex_json.get_varchar2(p_path   => 'analyticsId',
                                                    p_values => l_json_values);
      p_agent_name        := apex_json.get_varchar2(p_path   => 'agentName',
                                                    p_values => l_json_values);
      p_agent_version     := apex_json.get_varchar2(p_path   => 'agentVersion',
                                                    p_values => l_json_values);
      p_os_name           := apex_json.get_varchar2(p_path   => 'osName',
                                                    p_values => l_json_values);
      p_os_version        := apex_json.get_varchar2(p_path   => 'osVersion',
                                                    p_values => l_json_values);
      p_has_touch_support := nvl(apex_json.get_varchar2(p_path   => 'hasTouchSupport',
                                                        p_values => l_json_values),
                                 'N');
      p_page_load_time    := nvl(apex_json.get_number(p_path   => 'pageLoadTime',
                                                      p_values => l_json_values),
                                 0);
      p_screen_width      := apex_json.get_number(p_path   => 'screenWidth',
                                                  p_values => l_json_values);
      p_screen_height     := apex_json.get_number(p_path   => 'screenHeight',
                                                  p_values => l_json_values);
      p_apex_app_id       := apex_json.get_number(p_path   => 'apexAppId',
                                                  p_values => l_json_values);
      p_apex_page_id      := apex_json.get_number(p_path   => 'apexPageId',
                                                  p_values => l_json_values);
      p_apex_event_name   := apex_json.get_varchar2(p_path   => 'eventName',
                                                    p_values => l_json_values);
      p_additional_info   := apex_json.get_varchar2(p_path   => 'additionalInfo',
                                                    p_values => l_json_values);
    ELSE
      raise_application_error(-20001,
                              'Missing required values in JSON payload.');
    END IF;
    --
  END parse_analytics_data_json;
  --
  -- Check if required values are present in JSON payload
  -- #param p_analytics_id
  -- #param p_agent_name
  -- #param p_agent_version
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
                                  p_os_name           IN analytics_data.os_name%TYPE,
                                  p_os_version        IN analytics_data.os_version%TYPE,
                                  p_has_touch_support IN analytics_data.has_touch_support%TYPE,
                                  p_page_load_time    IN analytics_data.page_load_time%TYPE,
                                  p_screen_width      IN analytics_data.screen_width%TYPE,
                                  p_screen_height     IN analytics_data.screen_height%TYPE,
                                  p_apex_app_id       IN analytics_data.apex_app_id%TYPE,
                                  p_apex_page_id      IN analytics_data.apex_page_id%TYPE,
                                  p_apex_event_name   IN analytics_data.apex_event_name%TYPE) IS
    --
  BEGIN
    --
    IF p_analytics_id IS NULL
       OR p_agent_name IS NULL
       OR p_agent_version IS NULL
       OR p_os_name IS NULL
       OR p_os_version IS NULL
       OR p_has_touch_support IS NULL
       OR p_page_load_time IS NULL
       OR p_screen_width IS NULL
       OR p_screen_height IS NULL
       OR p_apex_app_id IS NULL
       OR p_apex_page_id IS NULL
       OR p_apex_event_name IS NULL THEN
      raise_application_error(-20001,
                              'Missing required values in JSON payload.');
    END IF;
    --
  END check_required_values;
  --
  -- Process ORDS REST web service call
  -- #param p_json_clob
  -- #param p_app_id
  PROCEDURE process_rest_post_call(p_json_clob IN CLOB,
                                   p_app_id    IN NUMBER) IS
    --
    l_analytics_id         analytics_data.analytics_id%TYPE;
    l_agent_name           analytics_data.agent_name%TYPE;
    l_agent_version        analytics_data.agent_version%TYPE;
    l_os_name              analytics_data.os_name%TYPE;
    l_os_version           analytics_data.os_version%TYPE;
    l_has_touch_support    analytics_data.has_touch_support%TYPE;
    l_page_load_time       analytics_data.page_load_time%TYPE;
    l_screen_width         analytics_data.screen_width%TYPE;
    l_screen_height        analytics_data.screen_height%TYPE;
    l_apex_app_id          analytics_data.apex_app_id%TYPE;
    l_apex_page_id         analytics_data.apex_page_id%TYPE;
    l_apex_event_name      analytics_data.apex_event_name%TYPE;
    l_additional_info      analytics_data.additional_info%TYPE;
    l_anonymous_ip_address analytics_data.anonymous_ip_address%TYPE;
    l_remove_ip_bytes      NUMBER := 1;
    --
  BEGIN
    --
    IF nvl(dbms_lob.getlength(p_json_clob),
           0) > 0 THEN
      -- parse JSON
      apexanalytics_app_pkg.parse_analytics_data_json(p_json_clob         => p_json_clob,
                                                      p_analytics_id      => l_analytics_id,
                                                      p_agent_name        => l_agent_name,
                                                      p_agent_version     => l_agent_version,
                                                      p_os_name           => l_os_name,
                                                      p_os_version        => l_os_version,
                                                      p_has_touch_support => l_has_touch_support,
                                                      p_page_load_time    => l_page_load_time,
                                                      p_screen_width      => l_screen_width,
                                                      p_screen_height     => l_screen_height,
                                                      p_apex_app_id       => l_apex_app_id,
                                                      p_apex_page_id      => l_apex_page_id,
                                                      p_apex_event_name   => l_apex_event_name,
                                                      p_additional_info   => l_additional_info);
      -- check required values
      apexanalytics_app_pkg.check_required_values(p_analytics_id      => l_analytics_id,
                                                  p_agent_name        => l_agent_name,
                                                  p_agent_version     => l_agent_version,
                                                  p_os_name           => l_os_name,
                                                  p_os_version        => l_os_version,
                                                  p_has_touch_support => l_has_touch_support,
                                                  p_page_load_time    => l_page_load_time,
                                                  p_screen_width      => l_screen_width,
                                                  p_screen_height     => l_screen_height,
                                                  p_apex_app_id       => l_apex_app_id,
                                                  p_apex_page_id      => l_apex_page_id,
                                                  p_apex_event_name   => l_apex_event_name);
      -- insert data
      -- anonymous ip only if enabled in app_settings
      IF apexanalytics_app_pkg.is_anonym_ip_tracking_enabled(p_app_id => p_app_id) THEN
        l_remove_ip_bytes      := to_number(apexanalytics_app_pkg.get_app_settings_value(p_app_id => p_app_id,
                                                                                         p_name   => 'REMOVE_LAST_IP_BYTES'));
        l_anonymous_ip_address := apexanalytics_app_pkg.get_anonymous_remote_ip(p_remove_ip_bytes => l_remove_ip_bytes);
      END IF;
      --
      apexanalytics_app_pkg.insert_analytics_data(p_analytics_id         => l_analytics_id,
                                                  p_agent_name           => l_agent_name,
                                                  p_agent_version        => l_agent_version,
                                                  p_os_name              => l_os_name,
                                                  p_os_version           => l_os_version,
                                                  p_has_touch_support    => l_has_touch_support,
                                                  p_page_load_time       => l_page_load_time,
                                                  p_screen_width         => l_screen_width,
                                                  p_screen_height        => l_screen_height,
                                                  p_apex_app_id          => l_apex_app_id,
                                                  p_apex_page_id         => l_apex_page_id,
                                                  p_apex_event_name      => l_apex_event_name,
                                                  p_additional_info      => l_additional_info,
                                                  p_anonymous_ip_address => l_anonymous_ip_address);
      -- htp output JSON
      htp.init;
      apex_json.open_object;
      apex_json.write('success',
                      TRUE);
      apex_json.write('message',
                      '',
                      TRUE);
      apex_json.close_object;
    ELSE
      raise_application_error(-20002,
                              'Please provide a JSON payload - Body is empty.');
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- htp output JSON
      htp.init;
      apex_json.open_object;
      apex_json.write('success',
                      FALSE);
      apex_json.write('message',
                      SQLERRM);
      apex_json.close_object;
      --
  END process_rest_post_call;
  --
  -- Get anonymous IP address from CGI env (removed last byte)
  -- #param p_remove_ip_bytes
  -- #return VARCHAR2
  FUNCTION get_anonymous_remote_ip(p_remove_ip_bytes IN NUMBER := 1) RETURN VARCHAR2 IS
    --
    l_remote_ip           VARCHAR2(100);
    l_anonymous_remote_ip VARCHAR2(100);
    l_remove_ip_bytes     NUMBER := 1;
    --
  BEGIN
    -- how much bytes should be removed from real IP
    l_remove_ip_bytes := nvl(p_remove_ip_bytes,
                             1);
    -- max 2 bytes got removed
    IF l_remove_ip_bytes > 2 THEN
      l_remove_ip_bytes := 2;
    END IF;
    IF l_remove_ip_bytes < 1 THEN
      l_remove_ip_bytes := 1;
    END IF;
    -- get real IPv4 from cgi_env
    l_remote_ip := owa_util.get_cgi_env(param_name => 'REMOTE_ADDR');
    -- remove last IP address bytes and replace with xxx
    IF l_remove_ip_bytes = 1 THEN
      l_anonymous_remote_ip := substr(l_remote_ip,
                                      1,
                                      instr(l_remote_ip,
                                            '.',
                                            -1)) || 'xxx';
    ELSIF l_remove_ip_bytes = 2 THEN
      l_anonymous_remote_ip := substr(l_remote_ip,
                                      1,
                                      instr(l_remote_ip,
                                            '.',
                                            -1,
                                            2)) || 'xxx.xxx';
    END IF;
    --
    RETURN l_anonymous_remote_ip;
    --
  END get_anonymous_remote_ip;
  --
  -- Check if anonymous IP tracking is enabled in App-Settings
  -- #param p_app_id
  -- #return BOOLEAN
  FUNCTION is_anonym_ip_tracking_enabled(p_app_id IN NUMBER) RETURN BOOLEAN IS
    --
    l_is_enabled BOOLEAN := FALSE;
    --
  BEGIN
    --
    IF apexanalytics_app_pkg.get_app_settings_value(p_app_id => p_app_id,
                                                    p_name   => 'ENABLE_ANONYMOUS_IP_TRACKING') = 'Y' THEN
      l_is_enabled := TRUE;
    ELSE
      l_is_enabled := FALSE;
    END IF;
    --
    RETURN l_is_enabled;
    --
  END is_anonym_ip_tracking_enabled;
  --
  -- Get prepared IP address, xxx is replaces with 1 --> 8.8.xxx.xxx > 8.8.1.1
  -- #param p_ip_address
  -- #return VARCHAR2
  FUNCTION get_prepared_ip_address(p_ip_address IN VARCHAR2) RETURN VARCHAR2 IS
    --
    l_ip_address VARCHAR2(100);
    --
  BEGIN
    --
    IF instr(p_ip_address,
             'xxx') > 0 THEN
      l_ip_address := REPLACE(REPLACE(p_ip_address,
                                      'xxx.xxx',
                                      '1.1'),
                              'xxx',
                              '1');
    ELSE
      l_ip_address := p_ip_address;
    END IF;
    --
    RETURN l_ip_address;
    --
  END get_prepared_ip_address;
  --
  -- Get value of specific APP_SETTINGS entry for specific APP_ID
  -- #param p_app_id
  -- #param p_name
  -- #return VARCHAR2
  FUNCTION get_app_settings_value(p_app_id IN NUMBER,
                                  p_name   IN VARCHAR2) RETURN VARCHAR2 IS
    --
    l_app_settings_value VARCHAR2(4000);
    --
    CURSOR l_cur_app_settings IS
      SELECT aas.value
        FROM apex_application_settings aas
       WHERE aas.application_id = p_app_id
         AND aas.name = p_name;
    --
  BEGIN
    --
    OPEN l_cur_app_settings;
    FETCH l_cur_app_settings
      INTO l_app_settings_value;
    CLOSE l_cur_app_settings;
    --
    RETURN l_app_settings_value;
    --
  END get_app_settings_value;
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
                                    p_country_name   OUT VARCHAR2) IS
    --
    l_is_ssl_call   BOOLEAN := FALSE;
    l_url           VARCHAR2(2000);
    l_response_json CLOB;
    l_response_xml  xmltype;
    --
    CURSOR l_cur_geolocation IS
      SELECT continent_code,
             continent_name,
             country_code,
             country_name
        FROM xmltable('/json' passing l_response_xml columns continent_code path 'continent_code',
                      continent_name path 'continent_name',
                      country_code path 'country_code',
                      country_name path 'country_name');
    --
  BEGIN
    -- check if its a SSL call
    IF p_base_url LIKE 'https:%' THEN
      l_is_ssl_call := TRUE;
    ELSE
      l_is_ssl_call := FALSE;
    END IF;
    --
    l_url := rtrim(p_base_url,
                   '/') || '/' || p_ip_address;
    -- issue REST call and get JSON
    IF l_is_ssl_call THEN
      l_response_json := apex_web_service.make_rest_request(p_url         => l_url,
                                                            p_http_method => 'GET',
                                                            p_parm_name   => apex_util.string_to_table('access_key:fields'),
                                                            p_parm_value  => apex_util.string_to_table(p_api_key ||
                                                                                                       ':continent_code,continent_name,country_code,country_name'),
                                                            p_wallet_path => p_wallet_path,
                                                            p_wallet_pwd  => p_wallet_pwd);
    ELSE
      l_response_json := apex_web_service.make_rest_request(p_url         => l_url,
                                                            p_http_method => 'GET',
                                                            p_parm_name   => apex_util.string_to_table('access_key:fields'),
                                                            p_parm_value  => apex_util.string_to_table(p_api_key ||
                                                                                                       ':continent_code,continent_name,country_code,country_name'));
    END IF;
    -- json to xml
    l_response_xml := apex_json.to_xmltype(l_response_json);
    -- get values and pass out
    OPEN l_cur_geolocation;
    FETCH l_cur_geolocation
      INTO p_continent_code,
           p_continent_name,
           p_country_code,
           p_country_name;
    CLOSE l_cur_geolocation;
    --
  END get_ipstack_geolocation;
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
                                  p_country_name      IN analytics_data_geolocation.country_name%TYPE) IS
    --
  BEGIN
    --
    INSERT INTO analytics_data_geolocation
      (analytics_data_id,
       continent_code,
       continent_name,
       country_code,
       country_name)
    VALUES
      (p_analytics_data_id,
       p_continent_code,
       p_continent_name,
       p_country_code,
       p_country_name);
  
    --
  END insert_ad_geolocation;
  --
  -- Process geolocation REST call and insert into ANALYTCIS_DATA_GEOLOCATION
  -- #param p_app_id
  PROCEDURE process_ad_geolocation(p_app_id IN NUMBER) IS
    --
    l_ipstack_base_url    VARCHAR2(500);
    l_ipstack_api_key     VARCHAR2(100);
    l_ipstack_wallet_path VARCHAR2(2000);
    l_ipstack_wallet_pwd  VARCHAR2(500);
    l_continent_code      analytics_data_geolocation.continent_code%TYPE;
    l_continent_name      analytics_data_geolocation.continent_name%TYPE;
    l_country_code        analytics_data_geolocation.country_code%TYPE;
    l_country_name        analytics_data_geolocation.country_name%TYPE;
    -- all ip addresses which are not already stored + only process 100 at once (e.g. dbms_scheduler)
    CURSOR l_cur_analytics_data_ip IS
      SELECT iv_analytics_data.id,
             iv_analytics_data.prepared_ip
        FROM (SELECT analytics_data.id,
                     apexanalytics_app_pkg.get_prepared_ip_address(p_ip_address => analytics_data.anonymous_ip_address) AS prepared_ip,
                     rownum AS row_num
                FROM analytics_data
               WHERE analytics_data.anonymous_ip_address IS NOT NULL
                 AND analytics_data.id NOT IN (SELECT analytics_data_geolocation.analytics_data_id
                                                 FROM analytics_data_geolocation)
               ORDER BY analytics_data.id) iv_analytics_data
       WHERE iv_analytics_data.row_num <= 100;
    --
  BEGIN
    -- check if ip tracking is enabled
    IF apexanalytics_app_pkg.is_anonym_ip_tracking_enabled(p_app_id => p_app_id) THEN
      -- get required settings for REST call to ipstack
      l_ipstack_base_url    := apexanalytics_app_pkg.get_app_settings_value(p_app_id => p_app_id,
                                                                            p_name   => 'IPSTACK_GEOLOCATION_BASE_URL');
      l_ipstack_api_key     := apexanalytics_app_pkg.get_app_settings_value(p_app_id => p_app_id,
                                                                            p_name   => 'IPSTACK_GEOLOCATION_API_KEY');
      l_ipstack_wallet_path := apexanalytics_app_pkg.get_app_settings_value(p_app_id => p_app_id,
                                                                            p_name   => 'IPSTACK_GEOLOCATION_WALLET_PATH');
      l_ipstack_wallet_pwd  := apexanalytics_app_pkg.get_app_settings_value(p_app_id => p_app_id,
                                                                            p_name   => 'IPSTACK_GEOLOCATION_WALLET_PWD');
      -- only process if settings are there
      IF l_ipstack_base_url IS NOT NULL
         AND l_ipstack_api_key IS NOT NULL THEN
        --
        FOR l_rec_analytics_data_ip IN l_cur_analytics_data_ip LOOP
          -- REST call
          apexanalytics_app_pkg.get_ipstack_geolocation(p_base_url       => l_ipstack_base_url,
                                                        p_ip_address     => l_rec_analytics_data_ip.prepared_ip,
                                                        p_api_key        => l_ipstack_api_key,
                                                        p_wallet_path    => l_ipstack_wallet_path,
                                                        p_wallet_pwd     => l_ipstack_wallet_pwd,
                                                        p_continent_code => l_continent_code,
                                                        p_continent_name => l_continent_name,
                                                        p_country_code   => l_country_code,
                                                        p_country_name   => l_country_name);
          -- only insert if REST call returned some data
          IF l_continent_code IS NOT NULL
             AND l_continent_name IS NOT NULL
             AND l_country_code IS NOT NULL
             AND l_country_name IS NOT NULL THEN
            --
            apexanalytics_app_pkg.insert_ad_geolocation(p_analytics_data_id => l_rec_analytics_data_ip.id,
                                                        p_continent_code    => l_continent_code,
                                                        p_continent_name    => l_continent_name,
                                                        p_country_code      => l_country_code,
                                                        p_country_name      => l_country_name);
          END IF;
        END LOOP;
      END IF;
    END IF;
    --
    COMMIT;
    --
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --
  END process_ad_geolocation;
  --
END apexanalytics_app_pkg;
/
