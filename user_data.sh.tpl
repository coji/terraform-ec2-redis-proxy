#!/bin/bash
export HOME="/root"
hostnamectl set-hostname "ec2-redis-proxy"
yum -y update
yum install -y git
### redis ##################################################
amazon-linux-extras install redis6
systemctl enable redis.service
systemctl start redis.service
### nginx ##################################################
amazon-linux-extras install -y nginx1
yum install -y nginx-mod-stream
systemctl enable nginx.service
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.org
cat <<'EOT' > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

stream {
        upstream redis {
                server localhost:6379;
        }

        server {
                listen          16379;
                proxy_pass      redis;
        }
}
EOT
systemctl start nginx.service
systemctl status nginx.service
