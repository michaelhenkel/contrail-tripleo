# == Class: contrail::vrouter::service
#
# Manage the vrouter service
#
class contrail::vrouter::service(
  $host_ip,
  $physical_interface,
  $cidr,
  $default_gw,
  $vhost_ip,
) {

  service {'supervisor-vrouter' :
    ensure => running,
    enable => true,
  }
  #$address = inline_template("<%= scope.lookupvar('::ipaddress_${physical_interface}') -%>")
  #if $address == $vhost_ip {
  if $host_ip == $vhost_ip {
    exec { 'ip address del':
      path => '/sbin',
      command => "ip addr del ${vhost_ip}/${cidr} dev ${physical_interface}",
      refreshonly => true,
    }
  }
  $gateway = get_gateway()
  if $gateway != $default_gw {
    exec { 'add default gw':
      path => '/sbin',
      command => "ip route add default via ${default_gw}",
      refreshonly => true,
    }
  }
}
