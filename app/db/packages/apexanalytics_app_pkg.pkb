CREATE OR REPLACE PACKAGE BODY apexanalytics_app_pkg IS
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
                                  p_anonymous_ip_address IN analytics_data.anonymous_ip_address%TYPE) IS
    --
  BEGIN
    --
    INSERT INTO analytics_data
      (analytics_id,
       agent_name,
       agent_version,
       agent_language,
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
       p_agent_language,
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
        raise_application_error(error_rest_json_parse,
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
        raise_application_error(error_rest_missing_values,
                                'Missing required values in JSON payload.');
      END IF;
      l_string_values := apex_string.split(p_str => l_decoded_string,
                                           p_sep => l_divider);
      --
      p_analytics_id      := l_string_values(1);
      p_agent_name        := l_string_values(2);
      p_agent_version     := l_string_values(3);
      p_agent_language    := l_string_values(4);
      p_os_name           := l_string_values(5);
      p_os_version        := l_string_values(6);
      p_has_touch_support := nvl(l_string_values(7),
                                 'N');
      p_page_load_time    := nvl(to_number(l_string_values(8),
                                           '999D999',
                                           'NLS_NUMERIC_CHARACTERS=''.,'''),
                                 0);
      p_screen_width      := to_number(l_string_values(9));
      p_screen_height     := to_number(l_string_values(10));
      p_apex_app_id       := to_number(l_string_values(11));
      p_apex_page_id      := to_number(l_string_values(12));
      p_apex_event_name   := l_string_values(13);
      p_additional_info   := l_string_values(14);
      --                                        
      -- values are directly in JSON payload
    ELSIF l_encoded_call = 'N' THEN
      p_analytics_id      := apex_json.get_varchar2(p_path   => 'analyticsId',
                                                    p_values => l_json_values);
      p_agent_name        := apex_json.get_varchar2(p_path   => 'agentName',
                                                    p_values => l_json_values);
      p_agent_version     := apex_json.get_varchar2(p_path   => 'agentVersion',
                                                    p_values => l_json_values);
      p_agent_language    := apex_json.get_varchar2(p_path   => 'agentLanguage',
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
      raise_application_error(error_rest_missing_values,
                              'Missing required values in JSON payload.');
    END IF;
    --
  END parse_analytics_data_json;
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
                                  p_apex_event_name   IN analytics_data.apex_event_name%TYPE) IS
    --
  BEGIN
    --
    IF p_analytics_id IS NULL
       OR p_agent_name IS NULL
       OR p_agent_version IS NULL
       OR p_agent_language IS NULL
       OR p_os_name IS NULL
       OR p_os_version IS NULL
       OR p_has_touch_support IS NULL
       OR p_page_load_time IS NULL
       OR p_screen_width IS NULL
       OR p_screen_height IS NULL
       OR p_apex_app_id IS NULL
       OR p_apex_page_id IS NULL
       OR p_apex_event_name IS NULL THEN
      raise_application_error(error_rest_missing_values,
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
    l_agent_language       analytics_data.agent_language%TYPE;
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
      BEGIN
        apexanalytics_app_pkg.parse_analytics_data_json(p_json_clob         => p_json_clob,
                                                        p_analytics_id      => l_analytics_id,
                                                        p_agent_name        => l_agent_name,
                                                        p_agent_version     => l_agent_version,
                                                        p_agent_language    => l_agent_language,
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
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(error_rest_json_parse,
                                  'JSON payload cannot be parsed.');
      END;
      -- check required values
      apexanalytics_app_pkg.check_required_values(p_analytics_id      => l_analytics_id,
                                                  p_agent_name        => l_agent_name,
                                                  p_agent_version     => l_agent_version,
                                                  p_agent_language    => l_agent_language,
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
      BEGIN
        apexanalytics_app_pkg.insert_analytics_data(p_analytics_id         => l_analytics_id,
                                                    p_agent_name           => l_agent_name,
                                                    p_agent_version        => l_agent_version,
                                                    p_agent_language       => l_agent_language,
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
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(error_rest_insert,
                                  'Cannot insert received data.');
      END;
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
      raise_application_error(error_rest_empty_body,
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
  -- Check if background image on login page is enabled
  -- #param p_app_id
  -- #return BOOLEAN
  FUNCTION is_login_background_enabled(p_app_id IN NUMBER) RETURN BOOLEAN IS
    --
    l_is_enabled BOOLEAN := FALSE;
    --
  BEGIN
    --
    IF apexanalytics_app_pkg.get_app_settings_value(p_app_id => p_app_id,
                                                    p_name   => 'SHOW_LOGIN_BACKGROUND_IMAGE') = 'Y' THEN
      l_is_enabled := TRUE;
    ELSE
      l_is_enabled := FALSE;
    END IF;
    --
    RETURN l_is_enabled;
    --
  END is_login_background_enabled;
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
  -- Ckeck if error object is returned by REST API from ipstack (throw exception)
  -- #param p_response_clob
  PROCEDURE check_error_ipstack_call(p_response_clob IN CLOB) IS
    --
    l_exception_message VARCHAR2(4000);
    l_response_xml      xmltype;
    -- cursor xmltable on json for error object
    CURSOR l_cur_error IS
      SELECT to_number(err_code) AS err_code,
             err_type,
             err_info
        FROM xmltable('/json/error' passing l_response_xml columns err_code path 'code',
                      err_type path 'type',
                      err_info path 'info');
    --
    l_rec_error l_cur_error%ROWTYPE;
    --
  BEGIN
    -- check response clob for error and code/type string
    IF p_response_clob LIKE '%error%'
       AND p_response_clob LIKE '%code%'
       AND p_response_clob LIKE '%type%' THEN
      -- json to xml
      l_response_xml := apex_json.to_xmltype(p_response_clob);
      -- open xml cursor
      OPEN l_cur_error;
      FETCH l_cur_error
        INTO l_rec_error;
      CLOSE l_cur_error;
      -- Throw error
      IF l_rec_error.err_code IS NOT NULL THEN
        l_exception_message := 'Error-Code: ' || l_rec_error.err_code || chr(10) || 'Error-Type: ' ||
                               l_rec_error.err_type || chr(10) || 'Error-Info: ' || l_rec_error.err_info;
        raise_application_error(error_ipstack_generic,
                                l_exception_message);
      END IF;
    END IF;
  END check_error_ipstack_call;
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
    -- check for ipstack REST API error
    apexanalytics_app_pkg.check_error_ipstack_call(p_response_clob => l_response_json);
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
    l_prepared_ip         analytics_data.anonymous_ip_address%TYPE;
    -- all ip addresses which are not already stored + only process 150 at once (e.g. dbms_scheduler)
    CURSOR l_cur_analytics_data_ip IS
      SELECT iv2_analytics_data.prepared_ip
        FROM (SELECT iv_analytics_data.prepared_ip,
                     rownum AS row_num
                FROM (SELECT DISTINCT apexanalytics_app_pkg.get_prepared_ip_address(p_ip_address => analytics_data.anonymous_ip_address) AS prepared_ip
                        FROM analytics_data
                       WHERE analytics_data.anonymous_ip_address IS NOT NULL
                         AND analytics_data.id NOT IN (SELECT analytics_data_geolocation.analytics_data_id
                                                         FROM analytics_data_geolocation)) iv_analytics_data) iv2_analytics_data
       WHERE iv2_analytics_data.row_num <= 150;
    -- get ids for distinct ip addresses from above
    CURSOR l_cur_analytics_data_ids IS
      SELECT analytics_data.id
        FROM analytics_data
       WHERE analytics_data.anonymous_ip_address IS NOT NULL
         AND analytics_data.id NOT IN (SELECT analytics_data_geolocation.analytics_data_id
                                         FROM analytics_data_geolocation)
         AND (SELECT apexanalytics_app_pkg.get_prepared_ip_address(p_ip_address => analytics_data.anonymous_ip_address)
                FROM dual) = l_prepared_ip;
  
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
        -- loop over distinct ip addresses
        FOR l_rec_analytics_data_ip IN l_cur_analytics_data_ip LOOP
          -- REST call to ipstack
          apexanalytics_app_pkg.get_ipstack_geolocation(p_base_url       => l_ipstack_base_url,
                                                        p_ip_address     => l_rec_analytics_data_ip.prepared_ip,
                                                        p_api_key        => l_ipstack_api_key,
                                                        p_wallet_path    => l_ipstack_wallet_path,
                                                        p_wallet_pwd     => l_ipstack_wallet_pwd,
                                                        p_continent_code => l_continent_code,
                                                        p_continent_name => l_continent_name,
                                                        p_country_code   => l_country_code,
                                                        p_country_name   => l_country_name);
          --
          l_prepared_ip := l_rec_analytics_data_ip.prepared_ip;
          -- loop over ids for particular ip address and insert
          FOR l_rec_analytics_data_ids IN l_cur_analytics_data_ids LOOP
            -- only insert if REST call returned some data
            IF l_continent_code IS NOT NULL
               AND l_continent_name IS NOT NULL
               AND l_country_code IS NOT NULL
               AND l_country_name IS NOT NULL THEN
              --
              apexanalytics_app_pkg.insert_ad_geolocation(p_analytics_data_id => l_rec_analytics_data_ids.id,
                                                          p_continent_code    => l_continent_code,
                                                          p_continent_name    => l_continent_name,
                                                          p_country_code      => l_country_code,
                                                          p_country_name      => l_country_name);
            
              -- if not all information are provided, empty anonymous_ip_address --> so it is not processed in next run
            ELSE
              UPDATE analytics_data
                 SET analytics_data.anonymous_ip_address = NULL
               WHERE analytics_data.id = l_rec_analytics_data_ids.id;
            END IF;
          END LOOP;
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
  -- Insert data into CUSTOM_ANALYTIC_QUERIES table
  -- #param p_query_name
  -- #param p_custom_query
  PROCEDURE insert_custom_analytic_queries(p_query_name   IN custom_analytic_queries.query_name%TYPE,
                                           p_custom_query IN custom_analytic_queries.custom_query%TYPE) IS
    --
  BEGIN
    --
    INSERT INTO custom_analytic_queries
      (query_name,
       custom_query)
    VALUES
      (p_query_name,
       p_custom_query);
    --
  END insert_custom_analytic_queries;
  --
  -- Update data from CUSTOM_ANALYTIC_QUERIES table
  -- #param p_id
  -- #param p_query_name
  -- #param p_custom_query
  PROCEDURE update_custom_analytic_queries(p_id           IN custom_analytic_queries.id%TYPE,
                                           p_query_name   IN custom_analytic_queries.query_name%TYPE,
                                           p_custom_query IN custom_analytic_queries.custom_query%TYPE) IS
    --
  BEGIN
    --
    UPDATE custom_analytic_queries
       SET query_name   = p_query_name,
           custom_query = p_custom_query
     WHERE custom_analytic_queries.id = p_id;
    --
  END update_custom_analytic_queries;
  --
  -- Check if a SQL query is valid
  -- #param p_query
  -- #return BOOLEAN
  FUNCTION is_query_valid(p_query IN CLOB) RETURN BOOLEAN IS
    --
    l_cursor NUMBER := dbms_sql.open_cursor;
    l_return BOOLEAN := FALSE;
    --
  BEGIN
    -- Check if query starts with SELECT Keyword
    IF substr(upper(ltrim(p_query)),
              1,
              6) != 'SELECT' THEN
      RETURN FALSE;
    END IF;
    -- Check if query contains DML keywords
    IF upper(p_query) LIKE '%INSERT%'
       OR upper(p_query) LIKE '%UPDATE%'
       OR upper(p_query) LIKE '%DELETE%'
       OR upper(p_query) LIKE '%MERGE%' THEN
      RETURN FALSE;
    END IF;
    -- Check SQL query
    BEGIN
      EXECUTE IMMEDIATE 'alter session set cursor_sharing=force';
      dbms_sql.parse(l_cursor,
                     p_query,
                     dbms_sql.native);
      EXECUTE IMMEDIATE 'alter session set cursor_sharing=exact';
      l_return := TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        EXECUTE IMMEDIATE 'alter session set cursor_sharing=exact';
        dbms_sql.close_cursor(l_cursor);
        l_return := FALSE;
    END;
    --
    RETURN l_return;
    --
  END is_query_valid;
  --
  -- Check if used tables in query are allowed to select
  -- #param p_query
  -- #param p_allowed_tables (comma separated)
  -- #return BOOLEAN
  FUNCTION is_table_access_allowed(p_query          IN CLOB,
                                   p_allowed_tables IN VARCHAR2) RETURN BOOLEAN IS
    --
    l_is_query_valid BOOLEAN := FALSE;
    l_return         BOOLEAN := FALSE;
    --
    CURSOR l_cur_xplan_tables IS
      SELECT iv_xplan_tables.table_name,
             iv_xplan_tables.plan_id
        FROM (SELECT DISTINCT CASE
                                WHEN pt.object_type = 'INDEX' THEN
                                 ai.table_owner
                                ELSE
                                 pt.object_owner
                              END AS owner,
                              CASE
                                WHEN pt.object_type = 'INDEX' THEN
                                 ai.table_name
                                ELSE
                                 pt.object_name
                              END AS table_name,
                              pt.plan_id
                FROM plan_table pt
                LEFT JOIN all_indexes ai
                  ON ai.owner = pt.object_owner
                 AND ai.index_name = pt.object_name
               WHERE pt.object_type IN ('TABLE',
                                        'INDEX')) iv_xplan_tables
       WHERE iv_xplan_tables.table_name IN (SELECT column_value
                                              FROM TABLE(apex_string.split(upper(p_allowed_tables),
                                                                           ',')));
    l_rec_xplan_tables l_cur_xplan_tables%ROWTYPE;
    --
  BEGIN
    -- check if query is valid
    l_is_query_valid := apexanalytics_app_pkg.is_query_valid(p_query => p_query);
    --
    IF l_is_query_valid THEN
      -- generate explain plan for query
      EXECUTE IMMEDIATE 'explain plan for ' || p_query;
      -- check if table names or index names referencing to tables are used in plan_table
      OPEN l_cur_xplan_tables;
      FETCH l_cur_xplan_tables
        INTO l_rec_xplan_tables;
      --
      IF l_cur_xplan_tables%FOUND THEN
        --
        DELETE plan_table
         WHERE plan_id = l_rec_xplan_tables.plan_id;
        --
        l_return := TRUE;
      ELSE
        l_return := FALSE;
      END IF;
      CLOSE l_cur_xplan_tables;
    END IF;
    --
    RETURN l_return;
    --
  END is_table_access_allowed;
  --
  -- Get column names from SQL query
  -- #param p_query
  -- #return VARCHAR2
  FUNCTION get_query_columns(p_query IN CLOB) RETURN VARCHAR2 IS
    --
    l_cursor         NUMBER;
    l_col_cnt        NUMBER;
    l_columns        dbms_sql.desc_tab;
    l_is_query_valid BOOLEAN := FALSE;
    l_query_columns  apex_t_varchar2;
    --
  BEGIN
    -- check if query is valid
    l_is_query_valid := apexanalytics_app_pkg.is_query_valid(p_query => p_query);
    --
    IF l_is_query_valid THEN
      -- parse SQL and describe columns
      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor,
                     p_query,
                     dbms_sql.native);
      dbms_sql.describe_columns(l_cursor,
                                l_col_cnt,
                                l_columns);
      -- loop over columns
      FOR i IN 1 .. l_columns.count LOOP
        apex_string.push(l_query_columns,
                         l_columns(i).col_name);
      END LOOP;
      -- close cursor
      IF dbms_sql.is_open(l_cursor) THEN
        dbms_sql.close_cursor(l_cursor);
      END IF;
    END IF;
    --
    RETURN apex_string.join(p_table => l_query_columns,
                            p_sep   => ',');
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- close cursor
      IF dbms_sql.is_open(l_cursor) THEN
        dbms_sql.close_cursor(l_cursor);
      END IF;
      --
      RAISE;
  END get_query_columns;
  --
  -- Check if custom query exceeds max allowed columns (default: 20)
  -- #param p_query
  -- #param p_max_allowed_columns
  -- #return BOOLEAN
  FUNCTION is_column_count_allowed(p_query               IN CLOB,
                                   p_max_allowed_columns IN NUMBER := 20) RETURN BOOLEAN IS
    --
    l_column_string VARCHAR2(4000);
    l_columns       apex_t_varchar2;
    l_return        BOOLEAN := FALSE;
    --
  BEGIN
    -- get columns comma separated
    l_column_string := apexanalytics_app_pkg.get_query_columns(p_query => p_query);
    l_columns       := apex_string.split(p_str => l_column_string,
                                         p_sep => ',');
    --
    IF l_columns.count <= nvl(p_max_allowed_columns,
                              20) THEN
      l_return := TRUE;
    ELSE
      l_return := FALSE;
    END IF;
    --
    RETURN l_return;
    --
  END is_column_count_allowed;
  --
  -- Create APEX collection from custom query from CUSTOM_ANALYTIC_QUERIES table
  -- #param p_id
  PROCEDURE create_custom_analytic_coll(p_id IN custom_analytic_queries.id%TYPE) IS
    --
    l_custom_query CLOB;
    --
  BEGIN
    --
    SELECT custom_analytic_queries.custom_query
      INTO l_custom_query
      FROM custom_analytic_queries
     WHERE custom_analytic_queries.id = p_id;
    --
    apex_collection.create_collection_from_query_b(p_collection_name    => 'CUSTOM_ANALYTIC_QUERY',
                                                   p_query              => l_custom_query,
                                                   p_truncate_if_exists => 'YES');
    --
  END create_custom_analytic_coll;
  --
  -- Get header labels for custom analytic query and APEX collection
  -- #param p_id
  -- #param p_col_header_01
  -- #param p_col_header_02
  -- #param p_col_header_03
  -- #param p_col_header_04
  -- #param p_col_header_05
  -- #param p_col_header_06
  -- #param p_col_header_07
  -- #param p_col_header_08
  -- #param p_col_header_09
  -- #param p_col_header_10
  -- #param p_col_header_11
  -- #param p_col_header_12
  -- #param p_col_header_13
  -- #param p_col_header_14
  -- #param p_col_header_15
  -- #param p_col_header_16
  -- #param p_col_header_17
  -- #param p_col_header_18
  -- #param p_col_header_19
  -- #param p_col_header_20
  PROCEDURE get_custom_analytic_col_header(p_id            IN custom_analytic_queries.id%TYPE,
                                           p_col_header_01 OUT VARCHAR2,
                                           p_col_header_02 OUT VARCHAR2,
                                           p_col_header_03 OUT VARCHAR2,
                                           p_col_header_04 OUT VARCHAR2,
                                           p_col_header_05 OUT VARCHAR2,
                                           p_col_header_06 OUT VARCHAR2,
                                           p_col_header_07 OUT VARCHAR2,
                                           p_col_header_08 OUT VARCHAR2,
                                           p_col_header_09 OUT VARCHAR2,
                                           p_col_header_10 OUT VARCHAR2,
                                           p_col_header_11 OUT VARCHAR2,
                                           p_col_header_12 OUT VARCHAR2,
                                           p_col_header_13 OUT VARCHAR2,
                                           p_col_header_14 OUT VARCHAR2,
                                           p_col_header_15 OUT VARCHAR2,
                                           p_col_header_16 OUT VARCHAR2,
                                           p_col_header_17 OUT VARCHAR2,
                                           p_col_header_18 OUT VARCHAR2,
                                           p_col_header_19 OUT VARCHAR2,
                                           p_col_header_20 OUT VARCHAR2) IS
    --
    l_count         NUMBER := 0;
    l_col_header_01 VARCHAR2(100);
    l_col_header_02 VARCHAR2(100);
    l_col_header_03 VARCHAR2(100);
    l_col_header_04 VARCHAR2(100);
    l_col_header_05 VARCHAR2(100);
    l_col_header_06 VARCHAR2(100);
    l_col_header_07 VARCHAR2(100);
    l_col_header_08 VARCHAR2(100);
    l_col_header_09 VARCHAR2(100);
    l_col_header_10 VARCHAR2(100);
    l_col_header_11 VARCHAR2(100);
    l_col_header_12 VARCHAR2(100);
    l_col_header_13 VARCHAR2(100);
    l_col_header_14 VARCHAR2(100);
    l_col_header_15 VARCHAR2(100);
    l_col_header_16 VARCHAR2(100);
    l_col_header_17 VARCHAR2(100);
    l_col_header_18 VARCHAR2(100);
    l_col_header_19 VARCHAR2(100);
    l_col_header_20 VARCHAR2(100);
    --
    CURSOR l_cur_column_header IS
      SELECT iv_query_columns.column_value
        FROM TABLE(apex_string.split(apexanalytics_app_pkg.get_query_columns(p_query => (SELECT custom_analytic_queries.custom_query
                                                                                           FROM custom_analytic_queries
                                                                                          WHERE custom_analytic_queries.id = p_id)),
                                     ',')) iv_query_columns;
    --
  BEGIN
    --
    FOR l_rec_column_header IN l_cur_column_header LOOP
      l_count := l_count + 1;
      --
      IF l_count = 1 THEN
        l_col_header_01 := l_rec_column_header.column_value;
      ELSIF l_count = 2 THEN
        l_col_header_02 := l_rec_column_header.column_value;
      ELSIF l_count = 3 THEN
        l_col_header_03 := l_rec_column_header.column_value;
      ELSIF l_count = 4 THEN
        l_col_header_04 := l_rec_column_header.column_value;
      ELSIF l_count = 5 THEN
        l_col_header_05 := l_rec_column_header.column_value;
      ELSIF l_count = 6 THEN
        l_col_header_06 := l_rec_column_header.column_value;
      ELSIF l_count = 7 THEN
        l_col_header_07 := l_rec_column_header.column_value;
      ELSIF l_count = 8 THEN
        l_col_header_08 := l_rec_column_header.column_value;
      ELSIF l_count = 9 THEN
        l_col_header_09 := l_rec_column_header.column_value;
      ELSIF l_count = 10 THEN
        l_col_header_10 := l_rec_column_header.column_value;
      ELSIF l_count = 11 THEN
        l_col_header_11 := l_rec_column_header.column_value;
      ELSIF l_count = 12 THEN
        l_col_header_12 := l_rec_column_header.column_value;
      ELSIF l_count = 13 THEN
        l_col_header_13 := l_rec_column_header.column_value;
      ELSIF l_count = 14 THEN
        l_col_header_14 := l_rec_column_header.column_value;
      ELSIF l_count = 15 THEN
        l_col_header_15 := l_rec_column_header.column_value;
      ELSIF l_count = 16 THEN
        l_col_header_16 := l_rec_column_header.column_value;
      ELSIF l_count = 17 THEN
        l_col_header_17 := l_rec_column_header.column_value;
      ELSIF l_count = 18 THEN
        l_col_header_18 := l_rec_column_header.column_value;
      ELSIF l_count = 19 THEN
        l_col_header_19 := l_rec_column_header.column_value;
      ELSIF l_count = 20 THEN
        l_col_header_20 := l_rec_column_header.column_value;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    --
    p_col_header_01 := nvl(l_col_header_01,
                           'C01');
    p_col_header_02 := nvl(l_col_header_02,
                           'C02');
    p_col_header_03 := nvl(l_col_header_03,
                           'C03');
    p_col_header_04 := nvl(l_col_header_04,
                           'C04');
    p_col_header_05 := nvl(l_col_header_05,
                           'C05');
    p_col_header_06 := nvl(l_col_header_06,
                           'C06');
    p_col_header_07 := nvl(l_col_header_07,
                           'C07');
    p_col_header_08 := nvl(l_col_header_08,
                           'C08');
    p_col_header_09 := nvl(l_col_header_09,
                           'C09');
    p_col_header_10 := nvl(l_col_header_10,
                           'C10');
    p_col_header_11 := nvl(l_col_header_11,
                           'C11');
    p_col_header_12 := nvl(l_col_header_12,
                           'C12');
    p_col_header_13 := nvl(l_col_header_13,
                           'C13');
    p_col_header_14 := nvl(l_col_header_14,
                           'C14');
    p_col_header_15 := nvl(l_col_header_15,
                           'C15');
    p_col_header_16 := nvl(l_col_header_16,
                           'C16');
    p_col_header_17 := nvl(l_col_header_17,
                           'C17');
    p_col_header_18 := nvl(l_col_header_18,
                           'C18');
    p_col_header_19 := nvl(l_col_header_19,
                           'C19');
    p_col_header_20 := nvl(l_col_header_20,
                           'C20');
    --
  END get_custom_analytic_col_header;
  --
  -- Get real language name from browsers ISO language code
  -- #param p_language_code
  -- #param p_main_lang_only
  -- #return VARCHAR2
  FUNCTION get_language_name(p_language_code  IN VARCHAR2,
                             p_main_lang_only IN VARCHAR2 := 'N') RETURN VARCHAR2 IS
    --
    l_language_code VARCHAR2(20);
    l_language_name VARCHAR2(100);
    --
    CURSOR l_cur_language IS
      SELECT language_list.value
        FROM language_list
       WHERE language_list.id = l_language_code;
    --
  BEGIN
    --
    IF p_main_lang_only = 'Y' THEN
      l_language_code := substr(lower(p_language_code),
                                1,
                                2);
    ELSE
      l_language_code := lower(p_language_code);
    END IF;
    --
    OPEN l_cur_language;
    FETCH l_cur_language
      INTO l_language_name;
    CLOSE l_cur_language;
    --
    RETURN l_language_name;
    --
  END get_language_name;
  --
END apexanalytics_app_pkg;
/
