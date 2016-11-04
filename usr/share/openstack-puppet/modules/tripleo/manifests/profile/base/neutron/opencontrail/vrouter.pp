# Copyright 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::neutron::opencontrail::vrouter
#
# Opencontrail profile to run the contrail vrouter
#
# === Parameters
#
# [*step*]
#   (Optional) The current step of the deployment
#   Defaults to hiera('step')
#
class tripleo::profile::base::neutron::opencontrail::vrouter (
  #$step           = hiera('step'),
  $admin_password = hiera('contrail::admin_password'),
  $admin_tenant_name = hiera('contrail::admin_tenant_name'),
  $admin_token = hiera('contrail::admin_token'),
  $admin_user = hiera('contrail::admin_user'),
  $auth_host = hiera('contrail::auth_host'),
  $auth_port = hiera('contrail::auth_port'),
  $auth_protocol = hiera('contrail::auth_protocol'),
  $disc_server_ip = hiera('controller_virtual_ip'),
  $disc_server_port = 5998,
  $insecure = hiera('contrail::insecure'),
  $memcached_servers = hiera('contrail::memcached_server'),
  $physical_interface = "eth0",
) {

  #if $step >= 4 {
    $cidr = netmask_to_cidr($::netmask)
    notify { 'cidr':
      message => $cidr,
    }
    $gateway = get_gateway()
    notify { 'gateway':
      message => $gateway,
    }
    #include ::contrail::vrouter
    # NOTE: it's not possible to use this class without a functional
    # contrail controller up and running
    #class {'::contrail::vrouter::provision_vrouter':
    #  require => Class['contrail::vrouter'],
    #}
    class {'::contrail::keystone':
      keystone_config => {
        'KEYSTONE' => {
          'admin_password'    => $admin_password,
          'admin_tenant_name' => $admin_tenant_name,
          'admin_user'        => $admin_user,
          'auth_host'         => $auth_host,
          'auth_port'         => $auth_port,
          'auth_protocol'     => $auth_protocol,
          'insecure'          => $insecure,
          'memcache_servers'  => $memcached_servers,
        },
      },
    } ->
    class {'::contrail::vrouter':
      vhost_ip => $::ipaddress,
      discovery_ip => $disc_server_ip,
      mask => $cidr,
      netmask => $::netmask,
      gateway => $gateway,
      macaddr => $::macaddress,
      physical_interface => $physical_interface,
      vrouter_agent_config       => {
        'NETWORKS'  => {
          'control_network_ip' => $::ipaddress,
        },
        'VIRTUAL-HOST-INTERFACE'  => {
          'name' => "vhost0",
          'ip'   => "${::ipaddress}/${cidr}",
          'gateway' => $gateway,
          'physical_interface' => $physical_interface,
          'compute_node_address' => $::ipaddress,
        },
        'DISCOVERY' => {
          'server' => $disc_server_ip,
          'port'   => $disc_server_port,
        },
      },
      vrouter_nodemgr_config       => {
        'DISCOVERY' => {
          'server' => $disc_server_ip,
          'port'   => $disc_server_port,
        },
      },
      vnc_api_lib_config    => {
        'auth' => {
          'AUTHN_SERVER' => $auth_host,
        },
      },
    }
  #}
}
