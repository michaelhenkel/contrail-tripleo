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
) inherits contrail::params {

  anchor {'contrail::analyticsdatabase::start': } ->
  #class {'::contrail::database::install': } ->
  class {'::contrail::analyticsdatabase::config': 
    database_nodemgr_config => $analyticsdatabase['database_nodemgr_config'],
    cassandra_servers       => $analyticsdatabase['cassandra_servers'],
    cassandra_ip            => $analyticsdatabase['host_ip'],
  } ~>
  class {'::contrail::analyticsdatabase::service': }
  anchor {'contrail::analyticsdatabase::end': }
  
}
