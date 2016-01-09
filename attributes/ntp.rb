##
## Attributes for NTP
##
node.default['ntp']['servers']=['0.pool.ntp.org','1.pool.ntp.org','2.pool.ntp.org','3.pool.ntp.org']
node.default['ntp']['ntpdate']['disable']=true

case node[:platform_family]
  when "debian"
    default['ntp']['packages'] = %w(ntp ntpdate)
  when "suse"
    default['ntp']['packages'] = %w(ntp)
  when "rhel","fedora"
    default['ntp']['packages'] = %w(ntp ntpdate)
end

