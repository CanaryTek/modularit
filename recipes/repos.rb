# Repos for ModularIT

unless node['platform_family'] == "debian"

# Fix yum cookbook broken epel key
if node['platform_version'].to_i >= 7
  node.set['yum']['epel']['key'] = "RPM-GPG-KEY-EPEL-7"
  node.set['yum']['epel']['key_url'] = "http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7"
elsif node['platform_version'].to_i >= 6
  node.set['yum']['epel']['key'] = "RPM-GPG-KEY-EPEL-6"
else
  node.set['yum']['epel']['key'] = "RPM-GPG-KEY-EPEL"
end

# EPEL
include_recipe "yum::epel"

# ModularIT repo
yum_key "RPM-GPG-KEY-CanaryTek" do
  url "http://ftp.modularit.org/repos/RPM-GPG-KEY-CanaryTek"
  action :add
end
yum_repository "modularit" do
  description "ModularIT repo for RHEL/CentOS"
  url "http://ftp.modularit.org/repos/centos/$releasever/$basearch/"
  #key "RPM-GPG-KEY-CanaryTek"
  enabled "1"
  priority "5"
  action :add
end

end
