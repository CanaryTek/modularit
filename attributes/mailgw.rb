##
## Attributes for modularit::mailgw
##

case node['platform_family']
when 'debian'
  ## Packages for Debian?
when 'rhel','fedora'
  default['modularit']['mailgw']['packages']=["amavisd-new","spamassassin","clamd"]
  default['modularit']['mailgw']['services']=["amavisd","clamd","clamd.amavisd","spamassassin"]
else
  default['modularit']['mailgw']['packages']=["amavisd-new","spamassassin","clamd"]
  default['modularit']['mailgw']['services']=["amavisd","clamd","clamd.amavisd","spamassassin"]
end
# Server name 
default['modularit']['mailgw']['server_name'] = node.has_key?(:domain) ? "mail.#{domain}" : 'mail'
# Where to store Mail TLS certificates
default['modularit']['mailgw']['certs_dir']="/etc/postfix"
default['modularit']['mailgw']['ssl_req'] = '/C=US/ST=Several/L=Locality/O=Example/OU=Operations/' +
  "CN=#{node['modularit']['mailgw']['server_name']}/emailAddress=ops@#{node['modularit']['mailgw']['server_name']}"

