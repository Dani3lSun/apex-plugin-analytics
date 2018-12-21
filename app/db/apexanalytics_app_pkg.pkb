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
  PROCEDURE insert_analytics_data(p_analytics_id      IN analytics_data.analytics_id%TYPE,
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
                                  p_apex_event_name   IN analytics_data.apex_event_name%TYPE,
                                  p_additional_info   IN analytics_data.additional_info%TYPE) IS
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
  -- Process REST web service call
  -- #param p_json_clob
  PROCEDURE process_rest_post_call(p_json_clob IN CLOB) IS
    --
    l_analytics_id      analytics_data.analytics_id%TYPE;
    l_agent_name        analytics_data.agent_name%TYPE;
    l_agent_version     analytics_data.agent_version%TYPE;
    l_os_name           analytics_data.os_name%TYPE;
    l_os_version        analytics_data.os_version%TYPE;
    l_has_touch_support analytics_data.has_touch_support%TYPE;
    l_page_load_time    analytics_data.page_load_time%TYPE;
    l_screen_width      analytics_data.screen_width%TYPE;
    l_screen_height     analytics_data.screen_height%TYPE;
    l_apex_app_id       analytics_data.apex_app_id%TYPE;
    l_apex_page_id      analytics_data.apex_page_id%TYPE;
    l_apex_event_name   analytics_data.apex_event_name%TYPE;
    l_additional_info   analytics_data.additional_info%TYPE;
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
      apexanalytics_app_pkg.insert_analytics_data(p_analytics_id      => l_analytics_id,
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
END apexanalytics_app_pkg;
/
