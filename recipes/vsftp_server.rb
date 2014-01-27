# Cookbook Name:: modularit
# Recipe:: vsftp_server
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
[ "vsftpd"].each do |pkg|
  package pkg
end

## Rasca obj for alarms
rasca_object "ProcChk-vsftp" do
  check "ProcChk"
  content <<__EOF__
vsftpd:
  :cmd:  service vsftpd restart
__EOF__
end

## Rasca obj for alarms
rasca_object "SecPkgChk-vsftp" do
  check "SecPkgChk"
  content <<__EOF__
vsftpd:
  :package: vsftpd
  :ports: [ TCP/21, TCP/ANY ]
__EOF__
end

