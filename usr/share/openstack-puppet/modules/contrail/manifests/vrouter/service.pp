# == Class: contrail::vrouter::service
#
# Manage the vrouter service
#
class contrail::vrouter::service(
  $cidr,
  $gateway,
  $host_ip,
  $physical_interface,
  $vhost_ip,
) {

  service {'supervisor-vrouter' :
    ensure => running,
    enable => true,
  }
  $address = inline_template("<%= scope.lookupvar('::ipaddress_${physical_interface}') -%>")
  if $address == $vhost_ip {
    exec { 'ip address del':
      path => '/sbin',
      command => "ip addr del ${vhost_ip}/${cidr} dev ${physical_interface}",
      refreshonly => true,
    }
  }
  $cur_gateway = get_gateway()
  if $cur_gateway != $gateway {
    exec { 'add default gw':
      path => '/sbin',
      command => "ip route add default via ${gateway}",
      refreshonly => true,
    }
  }
}
