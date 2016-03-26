# == Class storm::config
#
class storm::config inherits storm {

  file { $config:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($config_template),
    require => [ Package['storm'], File[$log_dir], File[$local_dir] ],
  }

  if $logback {
    $real_log_cluster_config = $logback
  } elsif !$log_cluster_config {
    $real_log_cluster_config = "/opt/storm/${log_framework}/cluster.xml"
  } else {
    $real_log_cluster_config = $log_cluster_config
  }

  if $logback_template {
    $real_log_template = $logback_template
  } elsif !$log_template {
    $real_log_template = "storm/cluster.${log_framework}.xml.erb"
  } else {
    $real_log_template = $log_template
  }

  file { $real_log_cluster_config :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($real_log_template),
    require => File[$config],
  }
  
}
