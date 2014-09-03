# ModularIT collectd recipe
#
# Miguel Armas <kuko@canarytek.com>

# Installs/configure collectd client to send data to Graphite

# Install packages
node['collectd']['packages'].each do |pkg|
  package pkg do
    action :install
  end
end

# Directory for additional config files
directory "/etc/collectd.d" do
  action :create
end

# Collectd configuration
template "/etc/collectd.conf" do
  source 'collectd.conf.erb'
  mode 00644
  notifies :restart, 'service[collectd]'
end

# Run/activate Services
node['collectd']['services'].each do |srv|
  service srv do
    action [ :start, :enable ]
  end
end

