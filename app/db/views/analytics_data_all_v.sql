CREATE OR REPLACE FORCE VIEW analytics_data_all_v AS
SELECT analytics_data.id,
       analytics_data.analytics_id,
       analytics_data.agent_name,
       analytics_data.agent_version,
       analytics_data.agent_language,
       analytics_data.os_name,
       analytics_data.os_version,
       analytics_data.has_touch_support,
       analytics_data.page_load_time,
       analytics_data.screen_width,
       analytics_data.screen_height,
       analytics_data.apex_app_id,
       analytics_data.apex_page_id,
       analytics_data.apex_event_name,
       analytics_data.additional_info,
       analytics_data.date_created,
       analytics_data.anonymous_ip_address,
       analytics_data_geolocation.continent_code,
       analytics_data_geolocation.continent_name,
       analytics_data_geolocation.country_code,
       analytics_data_geolocation.country_name,
       (SELECT apex_apps.app_name
          FROM apex_apps
         WHERE apex_apps.app_id = analytics_data.apex_app_id) AS apex_app_name,
       (SELECT apex_app_pages.page_title
          FROM apex_app_pages
         WHERE apex_app_pages.app_id = analytics_data.apex_app_id
           AND apex_app_pages.page_id = analytics_data.apex_page_id) AS apex_page_title,
       (SELECT language_list.value
          FROM language_list
         WHERE language_list.id = lower(analytics_data.agent_language)) AS agent_language_name,
       (SELECT language_list.value
          FROM language_list
         WHERE language_list.id = substr(lower(analytics_data.agent_language),
                                         1,
                                         2)) AS agent_language_main_name,
       CASE
         WHEN (analytics_data.os_name = 'iOS' OR analytics_data.os_name = 'Android' OR
              analytics_data.os_name = 'Windows Phone' OR analytics_data.os_name = 'BlackBerry')
              AND analytics_data.has_touch_support = 'Y' THEN
          'Y'
         ELSE
          'N'
       END AS is_mobile_device
  FROM analytics_data,
       analytics_data_geolocation
 WHERE analytics_data.id = analytics_data_geolocation.analytics_data_id(+);
