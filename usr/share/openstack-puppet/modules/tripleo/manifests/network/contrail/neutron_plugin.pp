# This class installs and configures Opencontrail Neutron Plugin.
#
# === Parameters
#
# [*api_server_ip*]
#   IP address of the API Server
#   Defaults to $::os_service_default
#
# [*api_server_port*]
#   Port of the API Server.
#   Defaults to $::os_service_default
#
# [*contrail_extensions*]
#   Array of OpenContrail extensions to be supported
#   Defaults to $::os_service_default
#   Example:
#
#     class {'neutron::plugins::opencontrail' :
#       contrail_extensions => ['ipam:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_ipam.NeutronPluginContrailIpam']
#     }
#
# [*keystone_auth_url*]
#   Url of the keystone auth server
#   Defaults to $::os_service_default
#
# [*keystone_admin_user*]
#   Admin user name
#   Defaults to $::os_service_default
#
# [*keystone_admin_tenant_name*]
#   Admin_tenant_name
#   Defaults to $::os_service_default
#
# [*keystone_admin_password*]
#   Admin password
#   Defaults to $::os_service_default
#
# [*keystone_admin_token*]
#   Admin token
#   Defaults to $::os_service_default
#
# [*package_ensure*]
#   (optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the opencontrail config.
#   Defaults to false.
#
class tripleo::network::contrail::neutron_plugin (
  $contrail_extensions    = hiera('contrail::vrouter::contrail_extensions'),
  $purge_config           = false,
  $admin_password         = hiera('contrail::admin_password'),
  $admin_tenant_name      = hiera('contrail::admin_tenant_name'),
  $admin_token            = hiera('contrail::admin_token'),
  $admin_user             = hiera('contrail::admin_user'),
  $api_server             = hiera('internal_api_virtual_ip'),
  $api_port               = hiera('contrail::api_port'),
  $auth_host              = hiera('contrail::auth_host'),
  $auth_port              = hiera('contrail::auth_port'),
  $auth_port_ssl          = hiera('contrail::auth_port_ssl'),
  $auth_protocol          = hiera('contrail::auth_protocol'),
  $ca_file                = hiera('tripleo::haproxy::service_certificate',False),
  $cert_file              = hiera('tripleo::haproxy::service_certificate',False),
) {

  include ::neutron::deps
  include ::neutron::params

  validate_array($contrail_extensions)

  package { 'neutron-plugin-contrail':
    ensure => $package_ensure,
    name   => $::neutron::params::opencontrail_plugin_package,
    tag    => ['neutron-package', 'openstack'],
  }
  package {'python-contrail':
    ensure => installed,
  }

  ensure_resource('file', '/etc/neutron/plugins/opencontrail', {
    ensure => directory,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640'}
  )

  if $::osfamily == 'Debian' {
    file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path  => '/etc/default/neutron-server',
      match => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line  => "NEUTRON_PLUGIN_CONFIG=${::neutron::params::opencontrail_config_file}",
      tag   => 'neutron-file-line',
    }
  }

  if $::osfamily == 'Redhat' {
    file { '/etc/neutron/plugin.ini':
      ensure  => link,
      target  => $::neutron::params::opencontrail_config_file,
      require => Package[$::neutron::params::opencontrail_plugin_package],
      tag     => 'neutron-config-file',
    }
    $api_paste_config_file = '/usr/share/neutron/api-paste.ini'
  }
  ini_setting { "filter:user_token":
    ensure  => present,
    path    => $api_paste_config_file,
    section => 'filter:user_token',
    setting => 'paste.filter_factory',
    value   => 'neutron_plugin_contrail.plugins.opencontrail.neutron_middleware:token_factory',
  }
  ini_setting { "composite:neutronapi_v2_0":
    ensure  => present,
    path    => $api_paste_config_file,
    section => 'composite:neutronapi_v2_0',
    setting => 'keystone',
    value   => 'user_token cors http_proxy_to_wsgi request_id catch_errors authtoken keystonecontext extensions neutronapiapp_v2_0',
  }
  resources { 'neutron_plugin_opencontrail':
    purge => $purge_config,
  }

  exec { 'add neutron user to haproxy group':
    command => '/usr/sbin/usermod -a -G haproxy neutron',
  }

  if $auth_protocol == 'https' {
    $auth_url = join([$auth_protocol,'://',$auth_host,':',$auth_port_ssl,'/v2.0'])
    neutron_plugin_opencontrail {
      'APISERVER/api_server_ip':           value => $api_server;
      'APISERVER/api_server_port':         value => $api_port;
      'APISERVER/contrail_extensions':     value => join($contrail_extensions, ',');
      'KEYSTONE/auth_url':                 value => $auth_url;
      'KEYSTONE/admin_user' :              value => $admin_user;
      'KEYSTONE/admin_tenant_name':        value => $admin_tenant;
      'KEYSTONE/admin_password':           value => $admin_password, secret =>true;
      'KEYSTONE/admin_token':              value => $admin_token, secret =>true;
      'KEYSTONE/cafile':                   value => $ca_file;
      'KEYSTONE/certfile':                 value => $cert_file;
      'keystone_authtoken/admin_user':     value => $admin_user;
      'keystone_authtoken/admin_tenant':   value => $admin_tenant;
      'keystone_authtoken/admin_password': value => $admin_password, secret =>true;
      'keystone_authtoken/auth_host':      value => $auth_host;
      'keystone_authtoken/auth_protocol':  value => $auth_protocol;
      'keystone_authtoken/auth_port':      value => $auth_port_ssl;
      'keystone_authtoken/cafile':         value => $ca_file;
      'keystone_authtoken/certfile':       value => $cert_file;
    }
  } else {
    $auth_url = join([$auth_protocol,'://',$auth_host,':',$auth_port,'/v2.0'])
    neutron_plugin_opencontrail {
      'APISERVER/api_server_ip':           value => $api_server;
      'APISERVER/api_server_port':         value => $api_port;
      'APISERVER/contrail_extensions':     value => join($contrail_extensions, ',');
      'KEYSTONE/auth_url':                 value => $auth_url;
      'KEYSTONE/admin_user' :              value => $admin_user;
      'KEYSTONE/admin_tenant_name':        value => $admin_tenant;
      'KEYSTONE/admin_password':           value => $admin_password, secret =>true;
      'KEYSTONE/admin_token':              value => $admin_token, secret =>true;
      'keystone_authtoken/admin_user':     value => $admin_user;
      'keystone_authtoken/admin_tenant':   value => $admin_tenant;
      'keystone_authtoken/admin_password': value => $admin_password, secret =>true;
      'keystone_authtoken/auth_host':      value => $auth_host;
      'keystone_authtoken/auth_protocol':  value => $auth_protocol;
      'keystone_authtoken/auth_port':      value => $auth_port;
    }
  }
}
