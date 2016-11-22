# == Class: contrail::vrouter
#
# Install and configure the vrouter service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for vrouter
#
class contrail::vrouter (
  $discovery_ip,
  $gateway,
  $host_ip,
  $netmask,
  $macaddr,
  $mask,
  $package_name = $contrail::params::vrouter_package_name,
  $physical_interface,
  $vhost_ip,
  $vrouter_agent_config = {},
  $vrouter_nodemgr_config = {},
  $vnc_api_lib_config = {},
) inherits contrail::params {

  anchor {'contrail::vrouter::start': } ->
  #class {'::contrail::vrouter::install': } ->
  class {'::contrail::vrouter::config':
    compute_device         => $physical_interface,
    device                 => $physical_interface,
    discovery_ip           => $discovery_ip,
    gateway                => $gateway,
    macaddr                => $macaddr,
    mask                   => $mask,
    netmask                => $netmask,
    vhost_ip               => $vhost_ip,
    vrouter_agent_config   => $vrouter_agent_config,
    vrouter_nodemgr_config => $vrouter_nodemgr_config,
    vnc_api_lib_config     => $vnc_api_lib_config,
  } ~>
  class {'::contrail::vrouter::service': 
    cidr               => $mask,
    gateway            => $gateway,
    host_ip            => $host_ip,
    physical_interface => $physical_interface,
    vhost_ip           => $vhost_ip,
  }
  anchor {'contrail::vrouter::end': }

}
