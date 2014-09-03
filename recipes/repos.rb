# Repos for ModularIT

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

