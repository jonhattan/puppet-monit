class monit::params (
  $check_interval   = hiera('monit_check_interval', 60),
  $initial_delay    = hiera('monit_initial_delay', 120),
  $mailserver       = hiera('monit_mailserver', localhost'),
  $alert            = hiera('monit_alert', 'root@localhost'),
  $httpserver       = hiera('monit_httpserver', true),
  $https            = hiera('monit_https', true),
  $https_pem_source = hiera('monit_https_pem_source', undef),
  $http_port        = hiera('monit_http_port', 2812),
  $auth             = hiera('monit_auth', 'admin:monit')
) {
  case $::operatingsystem {
    ubuntu, debian: {
      $package = 'monit'
      $config_file = '/etc/monit/monitrc'
      $config_dir = '/etc/monit/conf.d/'
      $switch_file = '/etc/default/monit'
      $service_name = 'monit'
      $source = 'puppet:///modules/monit/monitrc.deb'
      $switch_source = 'puppet:///modules/monit/monit.default.deb'
      $daemon_template = 'monit/daemon.deb.erb'
      $system_template = 'monit/system.deb.erb'
      $pem_path = '/var/certs/'
      $pem_name = 'monit.pem'
    }
#    redhat, centos: {
#    }
    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}
