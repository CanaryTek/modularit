# Cookbook Name:: modularit
# Recipe:: backup
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
[ "duplicity","python-paramiko"].each do |pkg|
  package pkg
end

## Rasca alarm links
["CheckBackup","CheckDuplicity"].each do |check|
  rasca_check check do
    priority "Urgent"
  end
end

## Script to run backups
# FIXME: This should not be in /root/bin but in some modularit/bin
directory "/root/bin" do
  owner "root"
  group "root"
  mode 00755
  recursive true
  action :create
end
file "/root/bin/backup.sh" do
  content <<EOF
#!/bin/bash
export HOME=/root
. /root/.bashrc
. /root/.bash_profile
/usr/bin/rascaBackup --all \
   && /usr/bin/rascaBackup -r remove_old --all && /usr/bin/rascaBackup -r cleanup --all
EOF
  mode "0755"
end

## Backup cron
# Remove old cron
cron "rascaBackup" do
  hour "02"
  minute "00"
  command "/root/bin/backup.sh"
  action :delete
end
#
# Incremental from monday to friday
cron "rascaBackup-inc" do
  hour "00"
  minute "01"
  weekday "1-5"
  command '/bin/bash -l -c "/usr/bin/rascaBackup -r inc --all && /usr/bin/rascaBackup -r remove_old --all && /usr/bin/rascaBackup -r cleanup --all"'
end
# Full on saturday
cron "rascaBackup-full" do
  hour "00"
  minute "01"
  weekday "7"
  command '/bin/bash -l -c "/usr/bin/rascaBackup -r full --all && /usr/bin/rascaBackup -r remove_old --all && /usr/bin/rascaBackup -r cleanup --all"'
end

## FIXME: Maybe this should be in cookbook rasca instead
# Basic config for rascaBackup
#rasca_config "CheckDuplicity" do
#  check "CheckDuplicity"
#  content <<EOF
#:encryptkeypass: ""
#:volsize: "250"
#:sshkeyfile: /root/.ssh/backup_dsa
#:baseurl: sftp://backup@backups.mycompany.net//dat/duplicity/myhost
#:timetofull: 6D
#EOF
#end
# Template for rascaBackup objects
rasca_object "Template" do
  check "CheckDuplicity"
  content <<EOF
## Template for volume definitions for rascaBackup
#/:
#  :name: myhost_root
#  # We can change the baseurl for a volume
#  :baseurl: s3://s3-eu-west-1.amazonaws.com/backups-mycompany/
#  :keepfull: 5
#/dat/data:
#  :name: myhost_data
#  :keepfull: 10
#  :use_lvm_snapshot:
#    :lvcreate: /sbin/lvcreate
#    :lvremove: /sbin/lvremove
#    :snapshot_size: 1G
#    :lv: data
#    :vg: dat
#    :mountpoint: /mnt/snapshot
#    :mount_cmd: /bin/mount -onouuid
EOF
end
