# == Class: contrail::database::install
#
# Install the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::database::install (
) {

  package { 'java-1.8.0-openjdk' :
    ensure => installed,
  } ->
  package { 'contrail-openstack-database' :
    ensure => installed,
  }

}
