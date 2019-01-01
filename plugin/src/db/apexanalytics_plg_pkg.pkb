CREATE OR REPLACE PACKAGE BODY apexanalytics_plg_pkg IS
  --
  -- Plug-in Render Function
  -- #param p_dynamic_action
  -- #param p_plugin
  -- #return apex_plugin.t_dynamic_action_render_result
  FUNCTION render_apexanalytics(p_dynamic_action IN apex_plugin.t_dynamic_action,
                                p_plugin         IN apex_plugin.t_plugin)
    RETURN apex_plugin.t_dynamic_action_render_result IS
    --
    l_result apex_plugin.t_dynamic_action_render_result;
    --
    -- plugin attributes
    l_analytics_rest_url p_plugin.attribute_01%TYPE := p_plugin.attribute_01;
    --
    l_additional_info_item   p_dynamic_action.attribute_01%TYPE := p_dynamic_action.attribute_01;
    l_encode_webservice_call VARCHAR2(5) := nvl(p_dynamic_action.attribute_02,
                                                'N');
    l_stop_on_max_error      NUMBER := nvl(p_dynamic_action.attribute_03,
                                           3);
    l_respect_donottrack     VARCHAR2(5) := nvl(p_dynamic_action.attribute_04,
                                                'N');
    --
    -- other vars
    l_analytics_id_string   VARCHAR2(500);
    l_analytics_id          VARCHAR2(128);
    l_component_config_json CLOB := empty_clob();
    --
    -- SHA256 Hash (from OOS_UTILS: https://github.com/OraOpenSource/oos-utils/blob/master/source/packages/oos_util_crypto.pkb)
    FUNCTION sha256(p_msg IN VARCHAR2) RETURN RAW IS
      --
      bmax32 CONSTANT NUMBER := power(2,
                                      32) - 1;
      bmax64 CONSTANT NUMBER := power(2,
                                      64) - 1;
      --
      l_msg       RAW(32767);
      t_md        VARCHAR2(128);
      fmt1        VARCHAR2(10) := 'xxxxxxxx';
      fmt2        VARCHAR2(10) := 'fm0xxxxxxx';
      t_len       PLS_INTEGER;
      t_pad_len   PLS_INTEGER;
      t_pad       VARCHAR2(144);
      t_msg_buf   VARCHAR2(32766);
      t_idx       PLS_INTEGER;
      t_chunksize PLS_INTEGER := 16320; -- 255 * 64
      t_block     VARCHAR2(128);
      TYPE tp_tab IS TABLE OF NUMBER;
      ht    tp_tab;
      k     tp_tab;
      w     tp_tab;
      h_str VARCHAR2(64);
      k_str VARCHAR2(512);
      a     NUMBER;
      b     NUMBER;
      c     NUMBER;
      d     NUMBER;
      e     NUMBER;
      f     NUMBER;
      g     NUMBER;
      h     NUMBER;
      s0    NUMBER;
      s1    NUMBER;
      maj   NUMBER;
      ch    NUMBER;
      t1    NUMBER;
      t2    NUMBER;
      tmp   NUMBER;
      --
      FUNCTION bitor(x NUMBER,
                     y NUMBER) RETURN NUMBER IS
      BEGIN
        RETURN x + y - bitand(x,
                              y);
      END;
      --
      FUNCTION bitxor(x NUMBER,
                      y NUMBER) RETURN NUMBER IS
      BEGIN
        RETURN x + y - 2 * bitand(x,
                                  y);
      END;
      --
      FUNCTION shl(x NUMBER,
                   b PLS_INTEGER) RETURN NUMBER IS
      BEGIN
        RETURN x * power(2,
                         b);
      END;
      --
      FUNCTION shr(x NUMBER,
                   b PLS_INTEGER) RETURN NUMBER IS
      BEGIN
        RETURN trunc(x / power(2,
                               b));
      END;
      --
      FUNCTION bitor32(x INTEGER,
                       y INTEGER) RETURN INTEGER IS
      BEGIN
        RETURN bitand(x + y - bitand(x,
                                     y),
                      bmax32);
      END;
      --
      FUNCTION bitxor32(x INTEGER,
                        y INTEGER) RETURN INTEGER IS
      BEGIN
        RETURN bitand(x + y - 2 * bitand(x,
                                         y),
                      bmax32);
      END;
      --
      FUNCTION ror32(x NUMBER,
                     b PLS_INTEGER) RETURN NUMBER IS
        t NUMBER;
      BEGIN
        t := bitand(x,
                    bmax32);
        RETURN bitand(bitor(shr(t,
                                b),
                            shl(t,
                                32 - b)),
                      bmax32);
      END;
      --
      FUNCTION rol32(x NUMBER,
                     b PLS_INTEGER) RETURN NUMBER IS
        t NUMBER;
      BEGIN
        t := bitand(x,
                    bmax32);
        RETURN bitand(bitor(shl(t,
                                b),
                            shr(t,
                                32 - b)),
                      bmax32);
      END;
      --
      FUNCTION ror64(x NUMBER,
                     b PLS_INTEGER) RETURN NUMBER IS
        t NUMBER;
      BEGIN
        t := bitand(x,
                    bmax64);
        RETURN bitand(bitor(shr(t,
                                b),
                            shl(t,
                                64 - b)),
                      bmax64);
      END;
      --
      FUNCTION rol64(x NUMBER,
                     b PLS_INTEGER) RETURN NUMBER IS
        t NUMBER;
      BEGIN
        t := bitand(x,
                    bmax64);
        RETURN bitand(bitor(shl(t,
                                b),
                            shr(t,
                                64 - b)),
                      bmax64);
      END;
      --
    BEGIN
      l_msg     := utl_raw.cast_to_raw(p_msg);
      t_len     := nvl(utl_raw.length(l_msg),
                       0);
      t_pad_len := 64 - MOD(t_len,
                            64);
      IF t_pad_len < 9 THEN
        t_pad_len := 64 + t_pad_len;
      END IF;
      t_pad := rpad('8',
                    t_pad_len * 2 - 8,
                    '0') || to_char(t_len * 8,
                                    'fm0XXXXXXX');
      --
      h_str := '6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19';
      ht    := tp_tab();
      ht.extend(8);
      FOR i IN 1 .. 8 LOOP
        ht(i) := to_number(substr(h_str,
                                  i * 8 - 7,
                                  8),
                           fmt1);
      END LOOP;
      --
      k_str := '428a2f9871374491b5c0fbcfe9b5dba53956c25b59f111f1923f82a4ab1c5ed5' ||
               'd807aa9812835b01243185be550c7dc372be5d7480deb1fe9bdc06a7c19bf174' ||
               'e49b69c1efbe47860fc19dc6240ca1cc2de92c6f4a7484aa5cb0a9dc76f988da' ||
               '983e5152a831c66db00327c8bf597fc7c6e00bf3d5a7914706ca635114292967' ||
               '27b70a852e1b21384d2c6dfc53380d13650a7354766a0abb81c2c92e92722c85' ||
               'a2bfe8a1a81a664bc24b8b70c76c51a3d192e819d6990624f40e3585106aa070' ||
               '19a4c1161e376c082748774c34b0bcb5391c0cb34ed8aa4a5b9cca4f682e6ff3' ||
               '748f82ee78a5636f84c878148cc7020890befffaa4506cebbef9a3f7c67178f2';
      k     := tp_tab();
      k.extend(64);
      FOR i IN 1 .. 64 LOOP
        k(i) := to_number(substr(k_str,
                                 i * 8 - 7,
                                 8),
                          fmt1);
      END LOOP;
      --
      t_idx := 1;
      WHILE t_idx <= t_len + t_pad_len LOOP
        IF t_len - t_idx + 1 >= t_chunksize THEN
          t_msg_buf := utl_raw.substr(l_msg,
                                      t_idx,
                                      t_chunksize);
          t_idx     := t_idx + t_chunksize;
        ELSE
          IF t_idx <= t_len THEN
            t_msg_buf := utl_raw.substr(l_msg,
                                        t_idx);
            t_idx     := t_len + 1;
          ELSE
            t_msg_buf := '';
          END IF;
          IF nvl(length(t_msg_buf),
                 0) + t_pad_len * 2 <= 32766 THEN
            t_msg_buf := t_msg_buf || t_pad;
            t_idx     := t_idx + t_pad_len;
          END IF;
        END IF;
        --
        FOR i IN 1 .. length(t_msg_buf) / 128 LOOP
          --
          a := ht(1);
          b := ht(2);
          c := ht(3);
          d := ht(4);
          e := ht(5);
          f := ht(6);
          g := ht(7);
          h := ht(8);
          --
          t_block := substr(t_msg_buf,
                            i * 128 - 127,
                            128);
          w       := tp_tab();
          w.extend(64);
          FOR j IN 1 .. 16 LOOP
            w(j) := to_number(substr(t_block,
                                     j * 8 - 7,
                                     8),
                              fmt1);
          END LOOP;
          --
          FOR j IN 17 .. 64 LOOP
            tmp := w(j - 15);
            s0 := bitxor(bitxor(ror32(tmp,
                                      7),
                                ror32(tmp,
                                      18)),
                         shr(tmp,
                             3));
            tmp := w(j - 2);
            s1 := bitxor(bitxor(ror32(tmp,
                                      17),
                                ror32(tmp,
                                      19)),
                         shr(tmp,
                             10));
            w(j) := bitand(w(j - 16) + s0 + w(j - 7) + s1,
                           bmax32);
          END LOOP;
          --
          FOR j IN 1 .. 64 LOOP
            s0  := bitxor(bitxor(ror32(a,
                                       2),
                                 ror32(a,
                                       13)),
                          ror32(a,
                                22));
            maj := bitxor(bitxor(bitand(a,
                                        b),
                                 bitand(a,
                                        c)),
                          bitand(b,
                                 c));
            t2  := bitand(s0 + maj,
                          bmax32);
            s1  := bitxor(bitxor(ror32(e,
                                       6),
                                 ror32(e,
                                       11)),
                          ror32(e,
                                25));
            ch  := bitxor(bitand(e,
                                 f),
                          bitand(-e - 1,
                                 g));
            t1  := h + s1 + ch + k(j) + w(j);
            h   := g;
            g   := f;
            f   := e;
            e   := d + t1;
            d   := c;
            c   := b;
            b   := a;
            a   := t1 + t2;
          END LOOP;
          --
          ht(1) := bitand(ht(1) + a,
                          bmax32);
          ht(2) := bitand(ht(2) + b,
                          bmax32);
          ht(3) := bitand(ht(3) + c,
                          bmax32);
          ht(4) := bitand(ht(4) + d,
                          bmax32);
          ht(5) := bitand(ht(5) + e,
                          bmax32);
          ht(6) := bitand(ht(6) + f,
                          bmax32);
          ht(7) := bitand(ht(7) + g,
                          bmax32);
          ht(8) := bitand(ht(8) + h,
                          bmax32);
          --
        END LOOP;
      END LOOP;
      FOR i IN 1 .. 8 LOOP
        t_md := t_md || to_char(ht(i),
                                fmt2);
      END LOOP;
      RETURN t_md;
    END sha256;
    --
    -- Get DA internal event name
    FUNCTION get_da_event_name(p_action_id IN NUMBER) RETURN VARCHAR2 IS
      --
      l_da_event_name apex_application_page_da.when_event_internal_name%TYPE;
      l_app_id        NUMBER;
      --
      CURSOR l_cur_da_event IS
        SELECT aapd.when_event_internal_name
          FROM apex_application_page_da      aapd,
               apex_application_page_da_acts aapda
         WHERE aapd.dynamic_action_id = aapda.dynamic_action_id
           AND aapd.application_id = l_app_id
           AND aapda.action_id = p_action_id;
      --
    BEGIN
      --
      l_app_id := nv('APP_ID');
      --
      OPEN l_cur_da_event;
      FETCH l_cur_da_event
        INTO l_da_event_name;
      CLOSE l_cur_da_event;
      --
      RETURN nvl(l_da_event_name,
                 'ready');
      --
    END get_da_event_name;
    --
  BEGIN
    --
    l_analytics_id_string := v('INSTANCE_ID') || ':' || v('WORKSPACE_ID') || ':' || v('APP_ID') || ':' || v('APP_USER');
    l_analytics_id        := sha256(p_msg => l_analytics_id_string);
    -- build component config json
    apex_json.initialize_clob_output;
    apex_json.open_object();
    -- general
    apex_json.write('analyticsId',
                    l_analytics_id);
    apex_json.write('eventName',
                    get_da_event_name(p_action_id => p_dynamic_action.id));
    -- app wide attributes
    apex_json.write('analyticsRestUrl',
                    l_analytics_rest_url);
    -- component attributes
    apex_json.write('additionalInfoItem',
                    l_additional_info_item);
    apex_json.write('encodeWebserviceCall',
                    l_encode_webservice_call);
    apex_json.write('stopOnMaxError',
                    l_stop_on_max_error);
    apex_json.write('respectDoNotTrack',
                    l_respect_donottrack);
    apex_json.close_object();
    --
    l_component_config_json := apex_json.get_clob_output;
    apex_json.free_output;
    -- DA javascript function
    l_result.javascript_function := 'function() { apex.da.apexAnalytics.pluginHandler(' || l_component_config_json ||
                                    '); }';
    --
    RETURN l_result;
    --
  END render_apexanalytics;
  --
END apexanalytics_plg_pkg;
/
