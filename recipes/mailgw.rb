# Cookbook Name:: modularit
# Recipe:: mailgw
# Description:: Mail Gateway with AntiSPAM/Antivirus (Postfix+Amavis-new+SpamAssassin+ClamAV)
#
# Copyright 2013, CanaryTek
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Needed packages
include_recipe "modularit::postfix_server"

# install postfix amavisd-new spamassassin clamd 
pkgs=node['modularit']['mailgw']['packages']
pkgs.each do |pkg|
  package pkg
end

services=node['modularit']['mailgw']['services']
services.each do |srv|
  service srv do
    action [ :enable, :start ]
  end
end

## Postfix master.cf to interact with amavis
template "/etc/postfix/master.cf" do
  source "mailgw/master.cf.erb"
  cookbook "modularit"
  owner "root"
  group "root"
  mode 00644
  if node['modularit']['bootstrap']
    action :create
  else
    action :create_if_missing
  end
  notifies :restart, "service[postfix]", :delayed
end

## Postfix main.cf 
template "/etc/postfix/main.cf" do
  source "mailgw/main.cf.erb"
  cookbook "modularit"
  owner "root"
  group "root"
  mode 00644
  if node['modularit']['bootstrap']
    action :create
  else
    action :create_if_missing
  end
  notifies :restart, "service[postfix]", :delayed
end

# Access
file "/etc/postfix/access" do
  content <<EOF
# IP to allow relay
#1.1.1.1   OK
EOF
  action :create_if_missing
end
# bogus_mx
file "/etc/postfix/bogus_mx" do
  content <<EOF
# Bogus MX
0.0.0.0/8 550 Mail server in broadcast
10.0.0.0/8  550 No route to your RFC 1918 network
127.0.0.0/8 550 Mail server in loopback network
240.0.0.0/4 550 Mail server in class D multicast network
192.168.0.0/26  550 No route to your RFC 1918 network
EOF
  action :create_if_missing
end
# rhsbl_sender_exceptions
file "/etc/postfix/rhsbl_sender_exceptions" do
  content <<EOF
# Accept mail from these domains, even if they are listed in rhsbl black lists
#example.com    OK
EOF
  action :create_if_missing
end
# transport
file "/etc/postfix/transport" do
  content <<EOF
# Send mail to these domains to these servers/ip (do not look MX in DNS)
#mydomain1.com esmtp:[myrelay.mydomain1.com]
#mydomain2.com esmtp:[IP_of_relay]
EOF
  action :create_if_missing
end
# virtual
file "/etc/postfix/virtual" do
  content <<EOF
# If you uncomment this line, mail to mydomain.com will only accept mails to addresses defined here
#mydomain.com virtual

# Redirect mail, to a different address@domain
#info@mydomain.com  info@otherdomain.com
EOF
  action :create_if_missing
end
# relaydomains
file "/etc/postfix/relaydomains" do
  content <<EOF
# Domains for which we act as relay. One per line
#mydomain1.com
#mydomain2.com
EOF
  action :create_if_missing
  notifies :restart, "service[postfix]", :delayed
end

# Create maps
["access","bogus_mx","rhsbl_sender_exceptions","transport","virtual"].each do |map|
  execute "postmap-#{map}" do
    command "postmap /etc/postfix/#{map}" 
    not_if { ::File.exists?("/etc/postfix/#{map}.db")}
    notifies :restart, "service[postfix]", :delayed
  end
end

# TLS Certs
bash "Create Mail TLS Certificates" do
  cwd node['modularit']['mailgw']['certs_dir']
  code <<-EOH
  umask 077
  openssl genrsa 2048 > smtp.key
  openssl req -subj "#{node['modularit']['mailgw']['ssl_req']}" -new -x509 -nodes -sha1 -days 3650 -key smtp.key > smtp.crt
  cat smtp.key smtp.crt > smtp.pem
  EOH
  not_if { ::File.exists?("#{node['modularit']['mailgw']['certs_dir']}/smtp.pem") }
end

