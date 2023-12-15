set termout OFF
set define '^'
set concat on
set concat .
set linesize 132
set pagesize 999
 
Rem
Rem    Title:  apex_ws_schema.sql
Rem
Rem    Description:  This script will setup the basic workspaces, db users, apex users, tablespaces for our base apex installation
Rem
Rem    Notes:  It is assumed that this script is run as a dba user.
Rem 1 - SCHEMA
Rem 2 - Workspace NAME
Rem 3 - email address
Rem
 
column foo1 new_val LOG1
select 'apex_ws_schema_'||to_char(sysdate,'YYYY-MM-DD_HH24-MI-SS')||'.log' as foo1 from sys.dual;
spool ^LOG1
 
timing start "Create tablespaces, schemas and workspaces"
 
column usr new_val USR
column ws new_val WS
column email new_val EMAIL
column ts new_val TS
select lower('^1') usr,lower('^1')||'_data' ts, lower('^2') ws,lower('^3') email from sys.dual;

--
-- Step 1:  Create the Tablespaces
--
create bigfile tablespace ^TS;
 
--
-- Step 2:  Create the Database Users (Schemas)
--
create user ^USR identified by "^USR" default tablespace ^TS quota unlimited on ^TS temporary tablespace temp;
grant create session, CREATE PROCEDURE, CREATE TABLE, CREATE TRIGGER, CREATE VIEW, create sequence, create materialized view to ^USR;

--
-- Step 3:  Create the APEX Workspaces
--
-- Create the APEX workspaces and associate a default schema with each
--
begin
    apex_instance_admin.add_workspace(
     p_workspace_id   => null,
     p_workspace      => '^WS',
     p_primary_schema => '^USR');
end;
/
 
--
-- Step 5:  Create an administrator account and a developer account in each worskpace
--
--
begin
    -- We must set the APEX workspace security group ID in our session before we can call create_user
    apex_util.set_security_group_id( apex_util.find_security_group_id( p_workspace => '^WS'));
 
    apex_util.create_user( 
        p_user_name               => 'ADMIN',
        p_email_address           => '^EMAIL',
        p_default_schema          => '^USR',
        p_allow_access_to_schemas => '^USR',
        p_web_password            => '^USR',
        p_developer_privs         => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' );  -- workspace administrator
 
    apex_util.create_user( 
        p_user_name               => '^USR',
        p_email_address           => '^EMAIL',
        p_default_schema          => '^USR',
        p_allow_access_to_schemas => '^USR',
        p_web_password            => '^USR',
        p_developer_privs         => 'CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' );  -- developer
 
    commit;
end;
/
 
set termout on
--
-- Show a quick summary of the workspaces and schemas
--
PROMPT APEX WORKSPACES
column workspace_name format a20
column schema         format a20
select workspace_name, schema from apex_workspace_schemas;
 
-- 
-- Show a quick summary of the APEX users
--
PROMPT APEX USERS
column workspace_name           format a20
column user_name                format a20
column email                    format a25
column is_admin                 format a5 heading "Admin"
column is_application_developer format a7 heading "Developer"
select workspace_name, user_name, email, is_admin, is_application_developer from apex_workspace_apex_users order by 1,2;
 
timing stop
spool off