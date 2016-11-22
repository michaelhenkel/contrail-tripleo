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
#  (required) host IP address of Database node
#  String (IPv4) value.
#
# [*disc_server_ip*]
#  (optional) IPv4 address of discovery server.
#  String (IPv4) value.
#  Defaults to hiera('contrail::disc_server_ip')
#
# [*disc_server_port*]
#  (optional) port Discovery server listens on.
#  Integer value.
#  Defaults to hiera('contrail::disc_server_port')
#
class tripleo::network::contrail::analyticsdatabase(
  $step              = hiera('step'),
  $auth_host         = hiera('contrail::auth_host'),
  $api_server        = hiera('internal_api_virtual_ip'),
  $api_port          = 8082,
  $admin_password    = hiera('contrail::admin_password'),
  $admin_tenant_name = hiera('contrail::admin_tenant_name'),
  $admin_token       = hiera('contrail::admin_token'),
  $admin_user        = hiera('contrail::admin_user'),
  $cassandra_servers = hiera('contrail_analytics_database_node_ips'),
  $disc_server_ip    = hiera('internal_api_virtual_ip'),
  $disc_server_port  = hiera('contrail::disc_server_port'),
  $host_ip           = hiera('contrail::analytics::database::host_ip'),
  $host_name         = $::hostname,
)
{
  class {'::contrail::analyticsdatabase':
    analyticsdatabase_params => {
      'auth_host'         => $auth_host,
      'api_server'        => $api_server,
      'admin_password'    => $admin_password,
      'admin_tenant_name' => $admin_tenant_name,
      'admin_token'       => $admin_token,
      'admin_user'        => $admin_user,
      'cassandra_servers' => $cassandra_servers,
      'host_ip'           => $host_ip,
      'disc_server_ip'    => $disc_server_ip,
      'disc_server_port'  => $disc_server_port,
      database_nodemgr_config => {
        'DEFAULT'   => {
          'hostip' => $host_ip,
        },
        'DISCOVERY' => {
          'port'   => $disc_server_port,
          'server' => $disc_server_ip,
        },
      },
    }
  }
  if $step >= 5 {
    class {'::contrail::database::provision_database':
      api_address                => $api_server,
      api_port                   => $api_port,
      database_node_address      => $host_ip,
      database_node_name         => $host_name, 
      keystone_admin_user        => $admin_user,
      keystone_admin_password    => $admin_password,
      keystone_admin_tenant_name => $admin_tenant_name,
      openstack_vip              => $auth_host,
    }
  }
}
