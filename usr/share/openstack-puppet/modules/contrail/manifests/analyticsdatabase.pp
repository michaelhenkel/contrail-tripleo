# == Class: contrail::database
#
# Install and configure the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::analyticsdatabase (
  $package_name = $contrail::params::database_package_name,
  $database_nodemgr_config,
  $cassandra_servers = hiera('contrail_analytics_database_node_ips'),
  $cassandra_ip = $host_ip,
) inherits contrail::params {

  #Service <| name == 'supervisor-analytics' |> -> Service['supervisor-database']
  #Service <| name == 'supervisor-config' |> -> Service['supervisor-database']
  #Service <| name == 'supervisor-control' |> -> Service['supervisor-database']
  #Service['supervisor-database'] -> Service <| name == 'supervisor-webui' |>


  anchor {'contrail::analyticsdatabase::start': } ->
  #class {'::contrail::database::install': } ->
  class {'::contrail::analyticsdatabase::config': 
    database_nodemgr_config => $database_nodemgr_config,
    cassandra_servers       => $cassandra_servers,
    cassandra_ip            => $cassandra_ip,
  } ~>
  class {'::contrail::analyticsdatabase::service': }
  anchor {'contrail::analyticsdatabase::end': }
  
}
