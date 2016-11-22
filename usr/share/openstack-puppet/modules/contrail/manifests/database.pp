# == Class: contrail::database
#
# Install and configure the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::database (
  $package_name = $contrail::params::database_package_name,
) inherits contrail::params {

  Service <| name == 'supervisor-analytics' |> -> Service['supervisor-database']
  Service <| name == 'supervisor-config' |> -> Service['supervisor-database']
  Service <| name == 'supervisor-control' |> -> Service['supervisor-database']
  Service['supervisor-database'] -> Service <| name == 'supervisor-webui' |>

  anchor {'contrail::database::start': } ->
  #class {'::contrail::database::install': } ->
  class {'::contrail::database::config': 
    cassandra_servers       => $database['cassandra_servers'],
    cassandra_ip            => $database['host_ip'],
    database_nodemgr_config => $database['database_nodemgr_config'],
    zookeeper_server_ips    => $database['zookeeper_server_ips'],
    zookeeper_client_ip     => $database['zookeeper_client_ip'],
    zookeeper_hostnames     => $database['zookeeper_hostnames'],
  } ~>
  class {'::contrail::database::service': }
  anchor {'contrail::database::end': }
  
}
