class monit::system_params (
  $load_1min        = 3 * $processorcount,
  $load_5min        = 1.5 * $processorcount,
  $memory           = '75%',
  $cpu_user         = '70%',
  $cpu_system       = '30%',
  $cpu_wait         = '30%',
  $swap             = '5%',
  $filesystems      = ['/', '/var/', '/home/', '/tmp/'],
  $filesystem_space = '10%'
) {

}
