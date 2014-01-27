# Cookbook Name:: modularit
# Recipe:: denyhosts
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

package "denyhosts"

service "denyhosts" do
  service_name node['modularit']['denyhosts']['service_name']
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
bash "add_allowed_hosts" do
    user "root"
    cwd "/tmp"
    code "echo \"sshd: #{node['modularit']['denyhosts']['allowed_hosts']}\" >> /etc/hosts.allow"
    not_if "grep #{node['modularit']['denyhosts']['allowed_hosts']} /etc/hosts.allow"
end
# ProcChk
rasca_object "ProcChk-denyhosts" do
  check "ProcChk"
  content <<EOF
# Run alert with option --info to see the format
denyhosts:
  :ensure: running
  :cmd: /etc/init.d/denyhosts restart
EOF
end

