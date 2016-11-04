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
  $package_name = $contrail::params::vrouter_package_name,
  $physical_interface,
  $vhost_ip,
  $discovery_ip,
  $mask,
  $netmask,
  $gateway,
  $macaddr,
  $vrouter_agent_config = {},
  $vrouter_nodemgr_config = {},
  $vnc_api_lib_config = {},
) inherits contrail::params {

  anchor {'contrail::vrouter::start': } ->
  #class {'::contrail::vrouter::install': } ->
  class {'::contrail::vrouter::config':
    vhost_ip => $vhost_ip,
    discovery_ip => $discovery_ip,
    mask => $mask,
    netmask => $netmask,
    gateway => $gateway,
    macaddr => $macaddr,
    vrouter_agent_config => $vrouter_agent_config,
    vrouter_nodemgr_config => $vrouter_nodemgr_config,
    vnc_api_lib_config => $vnc_api_lib_config,
  } ~>
  class {'::contrail::vrouter::service': 
    cidr => $mask,
    physical_interface => $physical_interface,
    vhost_ip => $vhost_ip,
    default_gw => $gateway,
  }
  anchor {'contrail::vrouter::end': }

}
