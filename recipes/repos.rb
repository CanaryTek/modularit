# Repos for ModularIT

if node['platform'] == "centos" or node['platform'] == "rhel"

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
# EPEL uses https wich may require an updated ca-certificates package
if node['platform_version'].to_i >= 6
package "ca-certificates" do
  action :upgrade
end
end
include_recipe "yum-epel"

# ModularIT repo
yum_repository "modularit" do
  description "ModularIT repo for RHEL/CentOS"
  url "http://ftp.modularit.org/repos/centos/$releasever/$basearch/"
  gpgkey "http://ftp.modularit.org/repos/RPM-GPG-KEY-CanaryTek"
  enabled true
  priority "5"
  action :add
end

end
