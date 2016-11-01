# == Class: contrail::database::config
#
# Configure the database service
#
# === Parameters:
#
# [*database_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-database-nodemgr.conf
#   Defaults to {}
#
class contrail::database::config (
  $database_nodemgr_config = {},
  $cassandra_servers = hiera('contrail::cassandra_server_list'),
  $cassandra_ip = hiera('contrail::database::host_ip'),  
  $storage_port       = '7000',
  $ssl_storage_port   = '7001',
  $client_port        = '9042',
  $client_port_thrift = '9160',
  $zookeeper_server_ips = hiera('contrail::zk_server_ip'),
  $zookeeper_client_ip = hiera('contrail::database::host_ip'),
  $zookeeper_hostnames = hiera('contrail_database_short_node_names', ''),
  $packages = ['zookeeper'],
  $service_name = 'zookeeper'
) {

  validate_hash($database_nodemgr_config)
  $contrail_database_nodemgr_config = { 'path' => '/etc/contrail/contrail-database-nodemgr.conf' }

  create_ini_settings($database_nodemgr_config, $contrail_database_nodemgr_config)
  validate_ipv4_address($cassandra_ip)

  package { 'java-1.8.0-openjdk.x86_64':
    ensure => 'installed',
  } ->
  file { '/var/lib/cassandra/data':
    ensure => 'directory',
    owner  => 'cassandra',
    mode   => '0750',
  } ->
  file { '/var/lib/cassandra/saved_caches':
    ensure => 'directory',
    owner  => 'cassandra',
    mode   => '0750',
  } ->
  file { '/var/lib/cassandra/commitlog':
    ensure => 'directory',
    owner  => 'cassandra',
    mode   => '0750',
  } ->
  class {'::cassandra':
    service_ensure => true,
    settings => {
      'cluster_name'          => 'TripleO',
      'listen_address'        => $::ipaddress,
      'storage_port'          => $storage_port,
      'ssl_storage_port'      => $ssl_storage_port,
      'native_transport_port' => $client_port,
      'rpc_port'              => $client_port_thrift,
      'commitlog_directory'         => '/var/lib/cassandra/commitlog',
      'commitlog_sync'              => 'periodic',
      'commitlog_sync_period_in_ms' => 10000,
      'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
      'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
      'data_file_directories'       => ['/var/lib/cassandra/data'],
      'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
      'seed_provider'               => [
        {
          'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
          'parameters' => [
            {
              'seeds' => $::ipaddress,
            },
          ],
        },
      ],
      'start_native_transport'      => true,
    }
  } 
  # validate_array($zookeeper_server_ips)
  validate_ipv4_address($zookeeper_client_ip)
  # validate_array($zookeeper_hostnames)

  # TODO(devvesa) Zookeeper package should provide these paths,
  # remove this lines as soon as it will.
  file {['/usr/lib', '/usr/lib/zookeeper', '/usr/lib/zookeeper/bin/']:
    ensure => directory
  }

  file {'/usr/lib/zookeeper/bin/zkEnv.sh':
    ensure => link,
    target => '/usr/libexec/zkEnv.sh'
  }

  class {'::zookeeper':
    servers   => $zookeeper_server_ips,
    client_ip => $zookeeper_client_ip,
    id        => extract_id($zookeeper_hostnames, $::hostname),
    cfg_dir   => '/etc/zookeeper/conf',
    packages  => $packages,
    service_name => $service_name,
  }

  File['/usr/lib/zookeeper/bin/zkEnv.sh'] -> Class['::zookeeper']
}
