default['nagios']['host_name_attribute'] = 'nagios_name'
default['nagios']['users_databag_group'] = 'nagios'

# Node attribute to use as host name in nagios
# Search to use in server to find hosts to include in nagios
default['nagios']['host_search']    = 'nagios_name:*'
# Skip hosts with this role
default['nagios']['skip_role']      = 'skip_nagios'
