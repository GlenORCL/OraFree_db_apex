# ORACLE FREE DB 23c and ORDS/APEX setup

My DEV setup for APEX and Oracle DB and ORDS using Oracle Container Registry images

Steps to setup everything and get working :
1. Download into a directory (ora would be fine)
2. optionally edit config_DEV.env - put in a sys password, and if you want to edit other values appropriately
5. run ORCLENV.sh DESTROY_AND_SETUP [ENV] - env defaults to DEV - this downloads all required software and sets up directories, sets up the db, ords, configures everthing and starts it up

You then have a new docker network (ENV_ora_network) with these machines:

A) ENV_ora_db - oracle free 23 database
- listens on 1521
- pdb = FREEPDB1
- apex installed inside the pdb (by the ORDS startup)
- by default, this also creates a new workspace (play_ws), new db user (play, pw=play) and installs all apex samples into that schema/workspace
- edit custom_devapex to modify or create additional workspaces and schemas

B) ENV_ora_ords : an ords server
- listens on 8181 (https)
- configured within the db pdb and ready to use APEX
- you might want to copy the ssl/cert.crt into your browser and trust it

Later use:
1. ORCLENV.sh stop [ENV] - ENV default to DEV, to stop all running servers
2. ORCLENV.sh start [ENV] - ENV defaults to DEV, to start the servers
3. ORCLENV.sh DESTROY_AND_SETUP [ENV] - destroys all data and recreates the servers
4. Another environment/machine setup :
  * copy config_DEV.env to config_TST.env
  * edit appropriately - IMPORTANT - change local port for DB and ORDS - they must be different to DEV local ports
  * you can comment out samples url and zip, and they won't be done in this environment
  * ORCLENV.sh DESTROY_AND_SETUP TST
  * ORCLENV.sh stop TST
  * ORCLENV.sh start TST

Advanced use:
1. add files to vm_scripts/oradb/scripts/setup/
    - put in here the standard things you want to do when the db is created (executes before apex is installed and before custom_DEV is invokved)
2. edit custom_ENV
    - if this file exists, it will be executed as by DESTROY_AND_SETUP.sh after everyting is built/setup
    - the custom_DEV supplied by default, will create play schema and play_ws workspace (with play/play as apex user/pw) and install ALL apex samples into this
    - this file can be left as is, or 
    - put in here the db schema, apex workspace that you want to create and include the apex samples into that workspace if you want
