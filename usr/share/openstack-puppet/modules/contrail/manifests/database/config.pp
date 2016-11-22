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
  $cassandra_servers       = [],
  $cassandra_ip            = $::ipaddress,
  $storage_port            = '7000',
  $ssl_storage_port        = '7001',
  $client_port             = '9042',
  $client_port_thrift      = '9160',
  $zookeeper_server_ips    = hiera('contrail_database_node_ips'),
  $zookeeper_client_ip     = $::ipaddress,
  $zookeeper_hostnames     = hiera('contrail_database_short_node_names', ''),
  $packages                = hiera('zookeeper::params::packages'),
  $service_name            = 'zookeeper'
) {
  $zk_server_ip_2181 = join([join($zookeeper_server_ips, ':2181,'),":2181"],'')
  validate_hash($database_nodemgr_config)
  $contrail_database_nodemgr_config = { 'path' => '/etc/contrail/contrail-database-nodemgr.conf' }

  create_ini_settings($database_nodemgr_config, $contrail_database_nodemgr_config)
  validate_ipv4_address($cassandra_ip)

#  package { 'java-1.8.0-openjdk.x86_64':
#    ensure => 'installed',
#  } ->
  file { ['/var/lib/cassandra',
          '/var/lib/cassandra/data',
          '/var/lib/cassandra/saved_caches',
          '/var/lib/cassandra/commitlog', ]:
    ensure => 'directory',
    owner  => 'cassandra',
    mode   => '0750',
  } ->
  class {'::cassandra':
    service_ensure => true,
    settings => {
      'cluster_name'          => 'ConfigDatabase',
      'listen_address'        => $cassandra_ip,
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
              'seeds' => $cassandra_servers[0],
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

  #file {'/usr/lib/zookeeper/bin/zkEnv.sh':
  #  ensure => link,
  #  target => '/usr/libexec/zkEnv.sh'
  #}
  file_line { 'adjust zookeeper service':
    path => '/etc/rc.d/init.d/zookeeper',
    line => "ZOOCFGDIR=/etc/zookeeper/conf",
    match   => "^ZOOCFGDIR=.*$",
  } ->
  exec { 'systemctl daemon-reload':
    path => '/bin',
  } ->
  class {'::zookeeper':
    servers   => $zookeeper_server_ips,
    client_ip => $zookeeper_client_ip,
    id        => extract_id($zookeeper_hostnames, $::hostname),
    cfg_dir   => '/etc/zookeeper/conf',
    packages  => $packages,
    service_name => $service_name,
    #service_provider => 'systemd',
    #manage_service_file => true,
  }

  #File['/usr/lib/zookeeper/bin/zkEnv.sh'] -> Class['::zookeeper']

  file { '/usr/share/kafka/config/server.properties':
    ensure => present,
  }->
  file_line { 'add zookeeper servers to kafka config':
    path => '/usr/share/kafka/config/server.properties',
    line => "zookeeper.connect=${zk_server_ip_2181}",
    match   => "^zookeeper.connect=.*$",
  }
  $kafka_broker_id = extract_id($zookeeper_hostnames, $::hostname)
  file_line { 'set kafka broker id':
    path => '/usr/share/kafka/config/server.properties',
    line => "broker.id=${kafka_broker_id}",
    match   => "^broker.id=.*$",
  }
}
