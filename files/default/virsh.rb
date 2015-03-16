# Plugin to list guest vm in a libvirt host
require_plugin "virtualization"
provides "virtualization/guest_list"

list=Mash.new
if not virtualization.nil? and virtualization[:role] == 'host'
  status, stdout, stderr = run_command(:no_status_check => true, :timeout => 60, :command => "virsh list | egrep -v '^( Id|---)|^$'")
  if status == 0
    stdout.each_line do |g|
      id, name, state = g.split
      list[name] = Mash.new
      list[name][:id] = id.strip
      list[name][:state] = state.strip
    end
  else
    # Some error running virsh
  end
end

virtualization[:guest_list]=list
