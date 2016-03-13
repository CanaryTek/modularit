# Collectd attributes for ModularIT


case node[:platform]
  when "debian", "ubuntu", "freebsd"
    default['collectd']['packages'] = [ "collectd" ]
    default['collectd']['services'] = [ "collectd" ]
  when "centos", "amazon", "redhat"
    default['collectd']['packages'] = [ "collectd", "collectd-rrdtool" ]
    default['collectd']['services'] = [ "collectd" ]
end

# Enable write_graphite?
default['collectd']['enable_graphite'] = true
# Graphite server parameters
default['collectd']['graphite']['server'] = "graphite_ip"
default['collectd']['graphite']['protocol'] = "tcp"
default['collectd']['graphite']['port'] = "2003"

