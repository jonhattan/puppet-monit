define monit::service_conf (
  $ensure                   = present,
  $priority                 = 20,
  $template                 = 'monit/service.deb.erb',
  $alert                    = undef,
  $reminder                 = undef,
  $group                    = $name,
  $pid_file                 = "/var/run/${name}.pid",
  $initd                    = "/etc/init.d/${name}",
  $start                    = "/etc/init.d/${name} start",
  $stop                     = "/etc/init.d/${name} stop",
  $bin                      = "/usr/sbin/${name}",
  $files                    = undef,
  $net_tests                = undef,
  $cpu_alert                = undef,
  $cpu_alert_cycles         = 5,
  $cpu_restart              = undef,
  $cpu_restart_cycles       = 10,
  $total_mem_alert          = undef,
  $total_mem_alert_cycles   = 5,
  $total_mem_restart        = undef,
  $total_mem_restart_cycles = 10,
  $children_alert           = undef,
  $children_restart         = undef,
  $load5_stop               = undef,
  $load5_stop_cycles        = 10,
  $custom_lines             = undef,
  $restarts_timeout         = 5,
  $cycles_timeout           = 5,
  $monit_config_dir         = $monit::params::config_dir
) {

  if $net_tests != undef {
    $net_tests_lines = template('monit/net_tests.erb')
    #notify {"net tests: $net_tests_lines":}
  }

  $content = template('monit/service.deb.erb')

  monit::conf { $name: 
    ensure   => $ensure,
    priority => $priority,
    content  => $content,
    monit_config_dir => $monit::params::config_dir,
  }
}
