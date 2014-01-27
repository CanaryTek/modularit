# Cookbook Name:: modularit
# Recipe:: postfix_server
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
[ "postfix"].each do |pkg|
  package pkg
end

## Service
[ "postfix"].each do |srv|
  service srv do
    action [ :enable, :start ]
  end
end

## Rasca obj for alarms
rasca_object "ProcChk-postfix" do
  check "ProcChk"
  content <<__EOF__
postfix:
  :cmd:  service postfix restart
saslauthd:
  :cmd:  service saslauthd restart
__EOF__
end

## Rasca obj for alarms
rasca_object "SecPkgChk-postfix" do
  check "SecPkgChk"
  content <<__EOF__
smtpd:
  :package: postfix
  :ports: [ TCP/25, TCP/587, TCP/465 ]
master:
  :package: postfix
  :ports: [ TCP/25, TCP/587, TCP/465 ]
__EOF__
end

