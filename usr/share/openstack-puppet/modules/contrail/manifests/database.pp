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
  $database_nodemgr_config,
  $cassandra_servers = hiera('contrail::cassandra_server_list'),
  $cassandra_ip = hiera('contrail::database::host_ip'),
) inherits contrail::params {

  Service <| name == 'supervisor-analytics' |> -> Service['supervisor-database']
  Service <| name == 'supervisor-config' |> -> Service['supervisor-database']
  Service <| name == 'supervisor-control' |> -> Service['supervisor-database']
  Service['supervisor-database'] -> Service <| name == 'supervisor-webui' |>


  anchor {'contrail::database::start': } ->
  #class {'::contrail::database::install': } ->
  class {'::contrail::database::config': 
    database_nodemgr_config => $database_nodemgr_config,
    cassandra_servers       => $cassandra_servers,
    cassandra_ip            => $cassandra_ip,
  } ~>
  class {'::contrail::database::service': }
  anchor {'contrail::database::end': }
  
}
