-- Create table
create table LANGUAGE_LIST
(
  id    VARCHAR2(20) not null,
  value VARCHAR2(100) not null
);
-- Create/Recreate primary, unique and foreign key constraints 
alter table LANGUAGE_LIST
  add constraint LANGUAGE_LIST_PK primary key (id);
