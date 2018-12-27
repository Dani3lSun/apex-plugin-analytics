-- Create table
create table CUSTOM_ANALYTIC_QUERIES
(
  id                   number default custom_analytic_queries_seq.nextval not null,
  query_name           varchar2(200) not null,
  custom_query         clob not null
);
-- Create/Recreate primary, unique and foreign key constraints 
alter table CUSTOM_ANALYTIC_QUERIES
  add constraint CUSTOM_ANALYTIC_QUERIES_PK primary key (id);
  
