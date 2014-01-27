##
## Attributes for sudo
##
node.override['authorization']['sudo']['groups']=['sysadmin']
node.override['authorization']['sudo']['passwordless']=true
node.override['authorization']['sudo']['include_sudoers_d']=true
node.default['authorization']['sudo']['agent_forwarding']=true

