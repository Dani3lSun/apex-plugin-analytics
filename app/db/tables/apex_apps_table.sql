-- Create table
create table APEX_APPS
(
  app_id    number not null,
  app_name  varchar2(200) not null
);
-- Create/Recreate primary, unique and foreign key constraints 
alter table APEX_APPS
  add constraint APEX_APPS_PK primary key (app_id);
