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
  description "ModularIT additional packages"
  #type "rpm-md"
  url "http://download.opensuse.org/repositories/home:/kuko:/ModularIT/CentOS_$releasever"
  gpgkey "http://download.opensuse.org/repositories/home:/kuko:/ModularIT/CentOS_$releasever//repodata/repomd.xml.key"
  enabled true
  priority "5"
  action :add
end

end
