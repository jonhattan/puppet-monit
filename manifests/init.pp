class monit (
  $ensure = 'present',
  $autoupgrade = false
) {

  require monit::params

  $package = $monit::params::package
  $config_file = $monit::params::config_file
  $config_file_replace = true
  $config_dir = $monit::params::config_dir
  $service_name = $monit::params::service_name
  $source = $monit::params::source
  $switch_file = $monit::params::switch_file
  $switch_source = $monit::params::switch_source

  case $ensure {
    /(present)/: {
      $dir_ensure = 'directory'
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $dir_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  # Startfile
  package { $package:
    ensure => $package_ensure,
  }

  file { $config_file:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    replace => $config_file_replace,
    source  => $source,
    require => Package[$package],
  }

  file { $switch_file:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    replace => $config_file_replace,
    source  => $switch_source,
    #content  => template($switch_template),
    require => Package[$package],
  }

  file { $config_dir:
    ensure  => $dir_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    recurse => true,
    purge   => true,
    require => Package[$package],
  }

  service { $service_name:
    name       => $service_name,
    ensure     => running,
    hasstatus  => false,
    hasrestart => true,
    enable     => true,
  }

  # HTTPS support
  if $monit::params::https {
    file { $monit::params::pem_path:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0550',
    }
    if $monit::params::https_pem_source == undef {
      # comprobar que exista
      $tmp_file = '/tmp/monit.cnf'
      file { $tmp_file:
        ensure  => present,
        content => template('monit/cert.cnf.erb'),
        require => Class['monit::cert_params']
      }
      exec { "monit_create_pem_file":
        command => "/usr/bin/openssl req -batch -new -x509 -days 3650 -nodes -config $tmp_file -out ${monit::params::pem_path}${monit::params::pem_name} -keyout ${monit::params::pem_path}${monit::params::pem_name} && /usr/bin/openssl gendh 512 >> ${monit::params::pem_path}${monit::params::pem_name} && chmod 700 ${monit::params::pem_path}${monit::params::pem_name}",
        creates => "${monit::params::pem_path}${monit::params::pem_name}",
        require => File["${monit::params::pem_path}"],
        notify  => Service[$service_name],
      }
    } else {
      file { "${monit::params::pem_path}${monit::params::pem_name}":
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0700',
        source => $monit::params::https_pem_source,
      }
    }
  }
  
  # Monit config
  @monit::conf{ 'daemon_config':
    priority => 00,
    template => $monit::params::daemon_template,
  }
  # System monitor
  require monit::system_params
  @monit::conf{ $fqdn:
    priority    => 01,
    template    => $monit::params::system_template,
    require     => Class['monit::system_params']
  }
#  if $monit::params::httpserver {
#    #TO-DO: Only test if http enabled
#    $net_test = [
#      {
#        "port" => "22", 
#        "protocol" => "SSH" },
#      {
#        "host" => "192.168.8.90", 
#        "port" => "2812",
#        "protocol" => "HTTPS" },
#      {
#        "host" => "192.168.8.90", 
#        "port" => "2812",
#        "type" => "TCP",
#        "protocol" => "HTTPS" },
#      {
#        "port" => $monit::params::http_port,
#        "type" => "TCP",
#        "protocol" => $monit::params::https ? {
#          true  => "HTTPS",
#          false => "HTTP",
#        }
#      }
#    ]
#  }

  @monit::service_conf{ $name:
#    alert => 'foo@bar',
#    reminder => 30,
#    files => '/root/',
    priority  => 10,
    net_tests => $monit::params::httpserver ? {
      false => undef,
      true  => [{
        'port' => $monit::params::http_port,
        'type' => $monit::params::https ? {
          true  => 'TCPSSL',
          false => 'TCP',
        },
        'protocol' => $monit::params::https_pem_source ? {
          undef   => '',
          default => 'HTTP',
        },
      }],
    },
  }
  # TO-DO: Realize virtual resources
  Monit::Conf <| |>
  Monit::Service_conf <| |>
}
