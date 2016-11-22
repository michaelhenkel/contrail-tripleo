# == Class: contrail::database::install
#
# Install the database service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for database
#
class contrail::analyticsdatabase::install (
  $package_name = $contrail::database::package_name,
) {

  package { $package_name :
    ensure => installed,
  }

}
