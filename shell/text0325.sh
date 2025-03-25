###安装Docker
yum install gcc
yum install gcc-c++
yum install -y yum-utils
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin

###安装MinIo
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio-20241107005220.0.0-1.x86_64.rpm -O minio.rpm
yum install dnf -y
dnf update
dnf install minio.rpm -y
mkdir /data/minio-data-vol

