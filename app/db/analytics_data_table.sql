-- Create table
create table ANALYTICS_DATA
(
  id                   number default analytics_data_seq.nextval not null,
  analytics_id         varchar2(128) not null,
  agent_name           varchar2(100) not null,
  agent_version        varchar2(100) not null,
  os_name              varchar2(100) not null,
  os_version           varchar2(100) not null,
  has_touch_support    varchar2(3) not null,
  page_load_time       number default 0 not null,
  screen_width         number not null,
  screen_height        number not null,
  apex_app_id          number not null,
  apex_page_id         number not null,
  apex_event_name      varchar2(100) not null,
  additional_info      varchar2(4000),
  anonymous_ip_address varchar2(100),
  date_created         date default sysdate not null
);
-- Create/Recreate primary, unique and foreign key constraints 
alter table ANALYTICS_DATA
  add constraint ANALYTICS_DATA_PK primary key (id);
-- Create indexes
create index AD_ANALYTICS_ID_I      on ANALYTICS_DATA (analytics_id);
create index AD_AGENT_NAME_I        on ANALYTICS_DATA (agent_name);
create index AD_AGENT_VERSION_I     on ANALYTICS_DATA (agent_version);
create index AD_OS_NAME_I           on ANALYTICS_DATA (os_name);
create index AD_OS_VERSION_I        on ANALYTICS_DATA (os_version);
create index AD_HAS_TOUCH_SUPPORT_I on ANALYTICS_DATA (has_touch_support);
create index AD_PAGE_LOAD_TIME_I    on ANALYTICS_DATA (page_load_time);
create index AD_SCREEN_WIDTH_I      on ANALYTICS_DATA (screen_width);
create index AD_SCREEN_HEIGHT_I     on ANALYTICS_DATA (screen_height);
create index AD_APEX_APP_ID_I       on ANALYTICS_DATA (apex_app_id);
create index AD_APEX_PAGE_ID_I      on ANALYTICS_DATA (apex_page_id);
create index AD_APEX_EVENT_NAME_I   on ANALYTICS_DATA (apex_event_name);
create index AD_DATE_CREATED_I      on ANALYTICS_DATA (date_created);
  
