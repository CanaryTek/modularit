# Cookbook Name:: modularit
# Recipe:: default
#
# Copyright 2012, CanaryTek
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

## Disable update-motd on amazon
if node['platform'] == "amazon"
  execute "disable-update-motd" do
    command "update-motd --disable"
    creates "/var/lib/update-motd/disabled"
  end
end

## Some propaganda
file "/etc/motd" do
  content <<EOF
*****************************************************
    This host is managed using ModularIT v2 NOC
              <www.modularit.com>
*****************************************************
EOF
  mode "0644"
end

##
## YUM Repos
##
include_recipe "yum::epel"

##
## Rasca
##
include_recipe "rasca"

##
## SSH
##
# openssh recipe is evil!!! Can't use most advanced options like MatchGroup
#include_recipe "openssh"

##
## Modularit Users
##
# Create sysadmin group and users in that group (from databad "users")
include_recipe "users::sysadmins"

##
## sudo management
##
include_recipe "sudo"

##
## Chef client
##
include_recipe "chef-client"
## ProcChk object for chef-client
rasca_object "ProcChk-chef-client" do
  check "ProcChk"
  content <<_EOF_
chef-client:
  :ensure: started
  :cmd: /etc/init.d/chef-client restart
_EOF_
end

##
## Security Checks
##
unless node.run_list.roles.include?("not_exposed")
  include_recipe "modularit::tripwire"
  include_recipe "modularit::security"
  unless node.run_list.roles.include?("not_ssh_exposed")
    include_recipe "modularit::denyhosts"
  end
end

##
## NTP
##
# Xen guests does not need NTP because it uses the host's clock
unless node['virtualization']['system']=='xen' and node['virtualization']['role']=='guest'
  include_recipe "ntp"
  # FIXME: ntp::ntpdate does not work with centos
  include_recipe "ntp::ntpdate"
end

##
## Basckups
##
unless node.run_list.roles.include?("not_backup")
  include_recipe "modularit::backup"
end
# New modularit-backup cookbook
include_recipe "modularit-backup::git_client"

##
## Add recipes based on node's roles
##
["postfix_server","postgresql_server","mysql_server","apache_server","nginx_server","vsftp_server","libvirt_server","shorewall","ipsec","mailgw","zimbra"].each do |role|
  if node.run_list.roles.include? role
    include_recipe "modularit::#{role}"
  end
end

##
## FIXME: Remove when we remove dirvish
##
if node.run_list.roles.include?("dirvish_server")
  rasca_check "DirvishChk" do
    priority "Urgent"
  end
end
if node.run_list.roles.include?("dirvish_client")
  rasca_check "BackupChk" do
    priority "Urgent"
  end
end

##
## FIXME: Delete when all hosts are in chef
##
# Remove puppet
service "puppetd" do
  action [ :stop, :disable ]
end
package "puppet" do
  action :remove
end
file "/var/lib/modularit/obj/ProcChk/puppet.obj" do
  action :delete
end
file "/var/lib/modularit/alarms/Urgent/Puppet-picacaller" do
  action :delete
end
file "/etc/cron.d/pifia" do
  action :delete
end
file "/etc/cron.d/rasca" do
  action :delete
end

# Eliminar rubygem-json por los problemas del simbolos, ahora usamos json_pure
package "rubygem-json" do
  action :remove
end

# Rename /var/lib/modularit/obj/CheckDuplicity to /var/lib/modularit/obj/backup
bash "rename-CheckDuplicity_obj" do
  code <<-EOH
    [ -d /var/lib/modularit/obj/CheckDuplicity ] && mv /var/lib/modularit/obj/{CheckDuplicity,backup}
  EOH
  creates "/var/lib/modularit/obj/backup"
end

