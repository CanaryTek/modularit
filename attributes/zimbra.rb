##
## Attributes for modularit::zimbra
##

case node['platform_family']
when 'debian'
  ## Packages for Debian?
when 'rhel','fedora'
  default['modularit']['zimbra']['dependencies']=["nc","sudo","libidn","gmp","libstdc++","perl","sysstat","sqlite"]
  default['modularit']['zimbra']['stop_services']=["nginx","postfix"]
  default['modularit']['zimbra']['version']="8.0.3_GA_5664.RHEL6_64.20130305090204"
  default['modularit']['zimbra']['checksum']="e263f2bcfcb3e059dcef23ba2b43060b"
  default['modularit']['zimbra']['packages']="zimbra-core* zimbra-store* zimbra-ldap* zimbra-logger* zimbra-mta* zimbra-snmp* zimbra-snmp* zimbra-apache* zimbra-spell*"
  default['modularit']['zimbra']['admin_pass']="changeme"
else
  default['modularit']['zimbra']['packages']=["amavisd-new","spamassassin","clamd"]
  default['modularit']['zimbra']['services']=["amavisd","clamd","clamd.amavisd","spamassassin"]
end
# Server name 
#default['modularit']['zimbra']['server_name'] = node.has_key?(:domain) ? "mail.#{domain}" : 'mail'
# Where to store Mail TLS certificates
#default['modularit']['zimbra']['certs_dir']="/etc/postfix"
#default['modularit']['zimbra']['ssl_req'] = '/C=US/ST=Several/L=Locality/O=Example/OU=Operations/' +
#  "CN=#{node['modularit']['zimbra']['server_name']}/emailAddress=ops@#{node['modularit']['mailgw']['server_name']}"

