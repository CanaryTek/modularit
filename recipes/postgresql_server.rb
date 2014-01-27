# Cookbook Name:: modularit
# Recipe:: postgresql_server
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
# FIXME: Should be handled from specific cookbook
[ "postgresql-server"].each do |pkg|
  package pkg
end

## Rasca obj for alarms
rasca_object "ProcChk-postgresql" do
  check "ProcChk"
  content <<__EOF__
postfix:
  :cmd:  service postgresql restart
__EOF__
end

## Rasca obj for alarms
rasca_object "SecPkgChk-postgresql" do
  check "SecPkgChk"
  content <<__EOF__
postmaste:
  :package: postgresql-server
  :ports: [ TCP/5432 ]
__EOF__
end

if node.run_list.roles.include? "postgresql_cluster"

rasca_object "CheckPgXlogReplication" do
  check "CheckPgXlogReplication"
  content <<__EOF__
# Use this file for local entries for alarm. The format is the same as the .obj file
#:bbdd1: 
#  :critical_delay: 10
#  :warning_delay: 6
#  :master: 192.168.1.11
#  :I_am_master: false
__EOF__
end

rasca_check "CheckPgXlogReplication" do
  priority "Emergency"
end

end

