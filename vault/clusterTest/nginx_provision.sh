#!/bin/bash

# Install nginx:
apt-get update
apt-get install -y nginx

# Set nginx config
cp /vagrant/nginx.conf /etc/nginx/nginx.conf
chmod 644 /etc/nginx/nginx.conf

# Start nginx
systemctl enable nginx
systemctl restart nginx