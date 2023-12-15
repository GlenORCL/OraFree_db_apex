#!/bin/bash
# 1 - SCHEMA
# 2 - password
# 3 - db service
# 4 - Workspace NAME

cd /opt/oracle/extras/apex_samples/apex-*/sample-apps

for i in $(ls */*.sql)
do
  sqlplus /nolog <<SQLEOF >> install.log
    conn $1/$2@$3
    exec apex_application_install.set_workspace('$4');
    exec apex_application_install.set_schema( '$1' );
    exec apex_application_install.generate_application_id;
    exec apex_application_install.generate_offset;
    exec apex_application_install.set_application_alias('SAMP_'||apex_application_install.get_application_id);
    exec apex_application_install.set_auto_install_sup_obj( p_auto_install_sup_obj => true );
    @${i}
SQLEOF
done
