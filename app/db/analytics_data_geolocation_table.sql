-- Create table
create table ANALYTICS_DATA_GEOLOCATION
(
  id                   number default analytics_data_geolocation_seq.nextval not null,
  analytics_data_id    number not null,
  continent_code       varchar2(50) not null,
  continent_name       varchar2(100) not null,
  country_code         varchar2(50) not null,
  country_name         varchar2(100) not null
);
-- Create/Recreate primary, unique and foreign key constraints 
alter table ANALYTICS_DATA_GEOLOCATION
  add constraint ANALYTICS_DATA_GEOLOCATION_PK primary key (id);
alter table ANALYTICS_DATA_GEOLOCATION
  add constraint ADG_ANALYTICS_DATA_ID_FK foreign key (analytics_data_id)
  references ANALYTICS_DATA (id) on delete cascade;
-- Create indexes
create index ADG_ANALYTICS_DATA_ID_I on ANALYTICS_DATA_GEOLOCATION (analytics_data_id);
create index ADG_CONTINENT_CODE_I    on ANALYTICS_DATA_GEOLOCATION (continent_code);
create index ADG_CONTINENT_NAME_I    on ANALYTICS_DATA_GEOLOCATION (continent_name);
create index ADG_COUNTRY_CODE_I      on ANALYTICS_DATA_GEOLOCATION (country_code);
create index ADG_COUNTRY_NAME_I      on ANALYTICS_DATA_GEOLOCATION (country_name);
  
