# Cookbook Name:: modularit
# Recipe:: apache_server
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
[ "httpd"].each do |pkg|
  package pkg
end

## Rasca obj for alarms
rasca_object "ProcChk-apache" do
  check "ProcChk"
  content <<__EOF__
httpd:
  :cmd:  service httpd restart
__EOF__
end

## Rasca obj for alarms
rasca_object "SecPkgChk-apache" do
  check "SecPkgChk"
  content <<__EOF__
httpd:
  :package: httpd
  :ports: [ TCP/80, TCP/443 ]
__EOF__
end

