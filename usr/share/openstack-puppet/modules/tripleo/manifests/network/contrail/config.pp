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
# == Class: tripleo::network::contrail::config
#
# Configure Contrail Config services
#
# == Parameters:
#
# [*ifmap_password*]
#  (required) ifmap password
#  String value.
#
# [*ifmap_server_ip*]
#  (required) ifmap server ip address.
#  String value.
#
# [*ifmap_username*]
#  (required) ifmap username
#  String value.
#
# [*rabbit_server*]
#  (required) IPv4 address of rabbit server.
#  String (IPv4) value.
#
# [*admin_password*]
#  (optional) admin password
#  String value.
#  Defaults to hiera('contrail::admin_password')
#
# [*admin_tenant_name*]
#  (optional) admin tenant name.
#  String value.
#  Defaults to hiera('contrail::admin_tenant_name')
#
# [*admin_token*]
#  (optional) admin token
#  String value.
#  Defaults to hiera('contrail::admin_token')
#
# [*admin_user*]
#  (optional) admin user name.
#  String value.
#  Defaults to hiera('contrail::admin_user')
#
# [*auth*]
#  (optional) Authentication method.
#  Defaults to hiera('contrail::auth')
#
# [*auth_host*]
#  (optional) keystone server ip address
#  String (IPv4) value.
#  Defaults to hiera('contrail::auth_host')
#
# [*auth_port*]
#  (optional) keystone port.
#  Defaults to hiera('contrail::auth_port')
#
# [*auth_protocol*]
#  (optional) authentication protocol.
#  Defaults to hiera('contrail::auth_protocol')
#
# [*cassandra_server_list*]
#  (optional) List IPs+port of Cassandra servers
#  Array of strings value.
#  Defaults to hiera('contrail::cassandra_server_list')
#
# [*disc_server_ip*]
#  (optional) IPv4 address of discovery server.
#  String (IPv4) value.
#  Defaults to hiera('contrail::disc_server_ip')
#
# [*insecure*]
#  (optional) insecure mode.
#  Defaults to hiera('contrail::insecure')
#
# [*listen_ip_address*]
#  (optional) IP address to listen on.
#  String (IPv4) value.
#  Defaults to '0.0.0.0'
#
# [*listen_port*]
#  (optional) Listen port for config-api
#  Defaults to 8082
#
# [*memcached_servers*]
#  (optional) IPv4 address of memcached servers
#  String (IPv4) value + port
#  Defaults to hiera('contrail::memcached_server')
#
# [*multi_tenancy*]
#  (optional) Defines if mutli-tenancy is enabled.
#  Defaults to hiera('contrail::multi_tenancy')
#
# [*redis_server*]
#  (optional) IPv4 address of redis server.
#  String (IPv4) value.
#  Defaults to '127.0.0.1'
#
# [*zk_server_ip*]
#  (optional) List IPs+port of Zookeeper servers
#  Array of strings value.
#  Defaults to hiera('contrail::zk_server_ip')
#
class tripleo::network::contrail::config(
  $step = hiera('step'),
  $admin_password         = hiera('contrail::admin_password'),
  $admin_tenant_name      = hiera('contrail::admin_tenant_name'),
  $admin_token            = hiera('contrail::admin_token'),
  $admin_user             = hiera('contrail::admin_user'),
  $api_server             = hiera('internal_api_virtual_ip'),
  $api_port               = 8082,
  $auth                   = hiera('contrail::auth'),
  $auth_host              = hiera('contrail::auth_host'),
  $auth_port              = hiera('contrail::auth_port'),
  $auth_protocol          = hiera('contrail::auth_protocol'),
  $cassandra_server_list  = hiera('contrail_database_node_ips'),
  $config_hostnames       = hiera('contrail_config_short_node_names'),
  $control_server_list    = hiera('contrail_control_node_ips'),
  $disc_server_ip         = hiera('internal_api_virtual_ip'),
  $disc_server_port       = hiera('contrail::disc_server_port'),
  $host_ip                = hiera('contrail::config::host_ip'),
  $ifmap_password         = hiera('contrail::config::ifmap_password'),
  $ifmap_server_ip        = hiera('contrail::config::host_ip'),
  $ifmap_username         = hiera('contrail::config::ifmap_username'),
  $insecure               = hiera('contrail::insecure'),
  $ipfabric_service_port  = 8775,
  $listen_ip_address      = '0.0.0.0',
  $listen_port            = 8082,
  $linklocal_service_port = 80,
  $linklocal_service_name = 'metadata',
  $linklocal_service_ip   = '169.254.169.254',
  $memcached_servers      = hiera('contrail::memcached_server'),
  $multi_tenancy          = hiera('contrail::multi_tenancy'),
  $public_vip             = hiera('public_virtual_ip'),
  $rabbit_server          = hiera('rabbitmq_node_ips'),
  $rabbit_user            = hiera('contrail::rabbit_user'),
  $rabbit_password        = hiera('contrail::rabbit_password'),
  $rabbit_port            = hiera('contrail::rabbit_port'),
  $redis_server           = '127.0.0.1',
  $zk_server_ip           = hiera('contrail_database_node_ips'),
)
{
  validate_ip_address($listen_ip_address)
  validate_ip_address($disc_server_ip)
  validate_ip_address($ifmap_server_ip)
  $basicauthusers_property_control = map($control_server_list) |$item| { "${item}.control:${item}.control" }
  $basicauthusers_property_dns = $control_server_list.map |$item| { "${item}.dns:${item}.dns" }
  $basicauthusers_property = concat($basicauthusers_property_control, $basicauthusers_property_dns)
  $cassandra_server_list_9160 = join([join($cassandra_server_list, ':9160 '),":9160"],'')
  $rabbit_server_list_5672 = join([join($rabbit_server, ':5672,'),":5672"],'')
  $zk_server_ip_2181 = join([join($zk_server_ip, ':2181,'),":2181"],'')

  class {'::contrail::keystone':
    keystone_config => {
      'KEYSTONE' => {
        'admin_password'    => $admin_password,
        'admin_tenant_name' => $admin_tenant_name,
        'admin_token'       => $admin_token,
        'admin_user'        => $admin_user,
        'auth_host'         => $auth_host,
        'auth_port'         => $auth_port,
        'auth_protocol'     => $auth_protocol,
        'insecure'          => $insecure,
        'memcached_servers' => $memcached_servers,
      },
    },
  } ->
  class {'::contrail::config':
    api_config            => {
      'DEFAULTS' => {
        'auth'                  => $auth,
        'cassandra_server_list' => $cassandra_server_list_9160,
        'disc_server_ip'        => $disc_server_ip,
        'ifmap_password'        => $ifmap_password,
        'ifmap_server_ip'       => $ifmap_server_ip,
        'ifmap_username'        => $ifmap_username,
        'listen_ip_addr'        => $listen_ip_address,
        'listen_port'           => $listen_port,
        'multi_tenancy'         => $multi_tenancy,
        'rabbit_server'         => $rabbit_server_list_5672,
        'rabbit_user'           => $rabbit_user,
        'rabbit_password'       => $rabbit_password,
        'redis_server'          => $redis_server,
        'zk_server_ip'          => $zk_server_ip_2181,
      },
    },
    basicauthusers_property => $basicauthusers_property,
    config_nodemgr_config => {
      'DISCOVERY' => {
        'server' => $disc_server_ip,
        'port'   => $disc_server_port,
      },
    },
    device_manager_config => {
      'DEFAULTS' => {
        'cassandra_server_list' => $cassandra_server_list_9160,
        'disc_server_ip'        => $disc_server_ip,
        'disc_server_port'      => $disc_server_port,
        'rabbit_server'         => $rabbit_server_list_5672,
        'redis_server'          => $redis_server,
        'rabbit_user'           => $rabbit_user,
        'rabbit_password'       => $rabbit_password,
        'zk_server_ip'          => $zk_server_ip_2181,
      },
    },
    schema_config         => {
      'DEFAULTS' => {
        'cassandra_server_list' => $cassandra_server_list_9160,
        'disc_server_ip'        => $disc_server_ip,
        'disc_server_port'      => $disc_server_port,
        'ifmap_password'        => $ifmap_password,
        'ifmap_server_ip'       => $ifmap_server_ip,
        'ifmap_username'        => $ifmap_username,
        'rabbit_server'         => $rabbit_server_list_5672,
        'rabbit_user'           => $rabbit_user,
        'rabbit_password'       => $rabbit_password,
        'redis_server'          => $redis_server,
        'zk_server_ip'          => $zk_server_ip_2181,
      },
    },
    discovery_config      => {
      'DEFAULTS' => {
        'cassandra_server_list' => $cassandra_server_list_9160,
        'zk_server_ip'          => $zk_server_ip_2181,
      },
    },
    svc_monitor_config    => {
      'DEFAULTS' => {
        'cassandra_server_list' => $cassandra_server_list_9160,
        'disc_server_ip'        => $disc_server_ip,
        'disc_server_port'      => $disc_server_port,
        'ifmap_password'        => $ifmap_password,
        'ifmap_server_ip'       => $ifmap_server_ip,
        'ifmap_username'        => $ifmap_username,
        'rabbit_server'         => $rabbit_server_list_5672,
        'rabbit_user'           => $rabbit_user,
        'rabbit_password'       => $rabbit_password,
        'redis_server'          => $redis_server,
        'zk_server_ip'          => $zk_server_ip_2181,
      },
    },
    vnc_api_lib_config    => {
      'auth' => {
        'AUTHN_SERVER' => $public_vip,
      },
    },
  }
  if $step >= 5 {
    class {'::contrail::config::provision_config':
      api_address                => $api_server,
      api_port                   => $api_port,
      config_node_address        => $host_ip,
      config_node_name           => $::hostname,
      keystone_admin_user        => $admin_user,
      keystone_admin_password    => $admin_password,
      keystone_admin_tenant_name => $admin_tenant_name,
      openstack_vip              => $public_vip,
    }
    if $config_hostnames[0] == $::hostname {
      class {'::contrail::config::provision_linklocal':
        api_address                => $api_server,
        api_port                   => $api_port,
        ipfabric_service_ip        => $api_server,
        ipfabric_service_port      => $ipfabric_service_port,
        keystone_admin_user        => $admin_user,
        keystone_admin_password    => $admin_password,
        keystone_admin_tenant_name => $admin_tenant_name,
        linklocal_service_name     => $linklocal_service_name,
        linklocal_service_ip       => $linklocal_service_ip,
        linklocal_service_port     => $linklocal_service_port,
      }
    }
  }
}
