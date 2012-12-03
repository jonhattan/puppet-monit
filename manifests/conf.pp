define monit::conf(
  $ensure = present,
  $priority = 10,
  $content = undef,
  $source = undef,
  $template = undef,
  $monit_config_dir = $monit::params::config_dir
) {

  File[$monit::params::config_dir] -> Monit::Conf[$name]

  $full_path = "${monit_config_dir}${priority}_${name}"

  if $template != undef {
    $actual_content = template($template)
    #notify {"USING TEMPLATE: $template":}
  }
  if $content != undef {
    $actual_content = $content
  }

  file { "${full_path}":
    path    => "${$full_path}",
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    source  => $source,
    content => $actual_content,
    notify  => Service[$monit::service_name]
  }
}
