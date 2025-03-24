mkdir /opt/cloudera-manager
tar -zxvf cm6.3.1-redhat7.tar.gz
cd cm6.3.1/RPMS/x86_64/
mv cloudera-manager-agent-6.3.1-1466458.el7.x86_64.rpm /opt/cloudera-manager/
mv cloudera-manager-server-6.3.1-1466458.el7.x86_64.rpm /opt/cloudera-manager/
mv cloudera-manager-daemons-6.3.1-1466458.el7.x86_64.rpm /opt/cloudera-manager/
cd /opt/cloudera-manager/