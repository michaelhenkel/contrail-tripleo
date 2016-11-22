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
class contrail::analyticsdatabase::config (
  $database_nodemgr_config = {},
  $cassandra_servers  = "",
  $cassandra_ip       = $::ipaddress,
  $storage_port       = '7000',
  $ssl_storage_port   = '7001',
  $client_port        = '9042',
  $client_port_thrift = '9160',
) {
  validate_hash($database_nodemgr_config)
  $contrail_database_nodemgr_config = { 'path' => '/etc/contrail/contrail-database-nodemgr.conf' }

  create_ini_settings($database_nodemgr_config, $contrail_database_nodemgr_config)
  validate_ipv4_address($cassandra_ip)

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
      'cluster_name'          => 'ContrailAnalytics',
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
}
