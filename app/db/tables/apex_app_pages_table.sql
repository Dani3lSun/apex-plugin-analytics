-- Create table
create table APEX_APP_PAGES
(
  id          number default apex_app_pages_seq.nextval not null,
  app_id      number not null,
  page_id     number not null,
  page_title  varchar2(200) not null
);
-- Create/Recreate primary, unique and foreign key constraints 
alter table APEX_APP_PAGES
  add constraint APEX_APP_PAGES_PK primary key (id);
alter table APEX_APP_PAGES
  add constraint APEX_APP_PAGES_APP_ID_FK foreign key (app_id)
  references APEX_APPS (app_id) on delete cascade;
-- Create indexes
create index APEX_APP_PAGES_APP_ID_I on APEX_APP_PAGES (app_id);
