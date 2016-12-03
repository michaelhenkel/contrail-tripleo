# == Class: contrail::analytics::install
#
# Install the analytics service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for analytics
#
class contrail::analytics::install (
) {

  package { 'wget' :
    ensure => installed,
  }
  package { 'contrail-openstack-analytics' :
    ensure => installed,
  }

}
