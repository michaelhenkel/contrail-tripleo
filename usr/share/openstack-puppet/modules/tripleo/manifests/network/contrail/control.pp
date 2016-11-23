#
# Copyright (C) 2015 Juniper Networks
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
# == Class: tripleo::network::contrail::control
#
# Configure Contrail Control services
#
# == Parameters:
#
# [*host_ip*]
#  (required) host IP address of Control
#  String (IPv4) value.
#
# [*ifmap_password*]
#  (required) ifmap password
#  String value.
#
# [*ifmap_username*]
#  (optional) ifmap username
#  String value.
#  Defaults to hiera('contrail::ifmap_username'),
#
# [*admin_password*]
#  (optional) admin password
#  String value.
#  Defaults to hiera('contrail::admin_password'),
#
# [*admin_tenant_name*]
#  (optional) admin tenant name.
#  String value.
#  Defaults to hiera('contrail::admin_tenant_name'),
#
# [*admin_token*]
#  (optional) admin token
#  String value.
#  Defaults to hiera('contrail::admin_token'),
#
# [*admin_user*]
#  (optional) admin user name.
#  String value.
#  Defaults to hiera('contrail::admin_user'),
#
# [*auth_host*]
#  (optional) keystone server ip address
#  String (IPv4) value.
#  Defaults to hiera('contrail::auth_host'),
#
# [*auth_port*]
#  (optional) keystone port.
#  Defaults to hiera('contrail::auth_port'),
#
# [*auth_protocol*]
#  (optional) authentication protocol.
#  Defaults to hiera('contrail::auth_protocol'),
#
# [*disc_server_ip*]
#  (optional) IPv4 address of discovery server.
#  String (IPv4) value.
#  Defaults to hiera('contrail::disc_server_ip'),
#
# [*disc_server_port*]
#  (optional) port Discovery server listens on.
#  Integer value.
#  Defaults to hiera('contrail::disc_server_port'),
#
# [*insecure*]
#  (optional) insecure mode.
#  Defaults to hiera('contrail::insecure'),
#
# [*memcached_servers*]
#  (optional) IPv4 address of memcached servers
#  String (IPv4) value + port
#  Defaults to hiera('contrail::memcached_servers'),
#
class tripleo::network::contrail::control(
  $step              = hiera('step'),
  $admin_password    = hiera('contrail::admin_password'),
  $admin_tenant_name = hiera('contrail::admin_tenant_name'),
  $admin_token       = hiera('contrail::admin_token'),
  $admin_user        = hiera('contrail::admin_user'),
  $api_server        = hiera('internal_api_virtual_ip'),
  $api_port          = 8082,
  $auth_host         = hiera('contrail::auth_host'),
  $auth_port         = hiera('contrail::auth_port'),
  $auth_protocol     = hiera('contrail::auth_protocol'),
  $disc_server_ip    = hiera('internal_api_virtual_ip'),
  $disc_server_port  = hiera('contrail::disc_server_port'),
  $host_ip           = hiera('contrail::control::host_ip'),
  $ibgp_auto_mesh    = true,
  $ifmap_password    = hiera('contrail::control::host_ip'),
  $ifmap_username    = hiera('contrail::control::host_ip'),
  $insecure          = hiera('contrail::insecure'),
  $memcached_servers = hiera('contrail::memcached_server'),
  $public_vip        = hiera('public_virtual_ip'),
  $router_asn        = 64512,
  $secret            = hiera('contrail::control::rndc_secret'),
)
{
  $control_ifmap_user     = "${ifmap_username}.control"
  $control_ifmap_password = "${ifmap_username}.control"
  $dns_ifmap_user         = "${ifmap_username}.dns"
  $dns_ifmap_password     = "${ifmap_username}.dns"

  class {'::contrail::control':
    secret                 => $secret,
    control_config         => {
      'DEFAULT'  => {
        'hostip' => $host_ip,
      },
      'DISCOVERY' => {
        'port'   => $disc_server_port,
        'server' => $disc_server_ip,
      },
      'IFMAP'     => {
        'password' => $control_ifmap_user,
        'user'     => $control_ifmap_password,
      },
    },
    dns_config             => {
      'DEFAULT'  => {
        'hostip'      => $host_ip,
        'rndc_secret' => $secret,
      },
      'DISCOVERY' => {
        'port'   => $disc_server_port,
        'server' => $disc_server_ip,
      },
      'IFMAP'     => {
        'password' => $dns_ifmap_user,
        'user'     => $dns_ifmap_password,
      }
    },
    control_nodemgr_config => {
      'DISCOVERY' => {
        'port'   => $disc_server_port,
        'server' => $disc_server_ip,
      },
    },
  }
  if $step >= 5 {
    class {'::contrail::control::provision_control':
      api_address                => $api_server,
      api_port                   => $api_port,
      control_node_address       => $host_ip,
      control_node_name          => $::hostname,
      ibgp_auto_mesh             => $ibgp_auto_mesh,
      keystone_admin_user        => $admin_user,
      keystone_admin_password    => $admin_password,
      keystone_admin_tenant_name => $admin_tenant_name,
      router_asn                 => $router_asn,
    }
  }
}
