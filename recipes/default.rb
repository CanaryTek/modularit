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

# Initialize names
node.set['rasca']['node_name']=Chef::Config[:node_name]
node.set['nagios_name']=Chef::Config[:node_name]

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

# Setup needed repos
include_recipe 'modularit::repos'

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
  # epel7 has no denyhosts package
  unless node['platform_family'] == "rhel" and node['platform_version'].to_i >= 7
    unless node.run_list.roles.include?("not_ssh_exposed")
      include_recipe "modularit::denyhosts"
    end
  end
  include_recipe "modularit::tripwire"
  include_recipe "modularit::security"
end

##
## NTP
##
# Xen guests does not need NTP because it uses the host's clock
unless node['virtualization']['system']=='xen' and node['virtualization']['role']=='guest'
  include_recipe "ntp"
  # FIXME: activar clock_sync para lanzar ntpdate (ver attributes del cookbook)
  #include_recipe "ntp::ntpdate"
end

##
## Backups
##
unless node.run_list.roles.include?("not_backup")
    include_recipe "modularit::backup"
end

if node['virtualization']['role'] == "host" and (node['virtualization']['system']=="xen" or node['virtualization']['system']=="kvm")
  # ohai plugin to export virsh data
  cookbook_file "#{node['chef_packages']['ohai']['ohai_root']}/plugins/virsh.rb" do
    source "virsh.rb"
    owner "root"
    group "root"
    mode 00755
    action :create
  end
end

# New modularit-backup cookbook
#include_recipe "modularit-backup::git_client"

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



