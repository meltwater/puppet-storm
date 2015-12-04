# == Class storm::install
#
class storm::install inherits storm {

  if $package_rpm_source == undef {
    $package_install_options = {
      ensure   => $package_ensure,
      name     => $package_name
    }
  } else {
    $package_install_options = {
      ensure   => $package_ensure,
      name     => $package_name,
      provider => 'rpm',
      source   => $package_rpm_source
    }
  }

  ensure_resource('package', 'storm', $package_install_options)

  # This exec ensures we create intermediate directories for $local_dir as required
  exec { 'create-storm-local-directory':
    command => "mkdir -p ${local_dir}",
    path    => ['/bin', '/sbin'],
    require => Package['storm'],
  }
  ->
  file { $local_dir:
    ensure       => directory,
    owner        => $user,
    group        => $group,
    mode         => '0750',
    recurse      => true,
    recurselimit => 0,
  }

  # If $log_dir does not point to the default "storm.home"/logs/ directory, we create a symlink
  # from "storm.home"/logs/ to the actual $log_dir.  This is required because as of Sep 2013
  # (and Storm 0.9.0-wip21) the log directory is still hardcoded in same places in the Storm
  # code.  Otherwise we could just supply a custom "storm.home"/logback/cluster.xml config.
  # See https://groups.google.com/forum/#!topic/storm-user/IKRtIkqQfqc for details.
  if $log_dir != $storm::params::storm_rpm_log_dir {
    # This exec ensures we create intermediate directories for $log_dir as required
    exec { 'create-storm-log-directory':
      command => "mkdir -p ${log_dir}",
      path    => ['/bin', '/sbin'],
      require => Package['storm'],
    }
    ->
    file { $log_dir:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0755',
    }
    ->
    file { $storm::params::storm_rpm_log_dir:
      ensure  => link,
      target  => $log_dir,
      force   => true,
      require => Package['storm'],
    }
  }
  else {
    file { $log_dir:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0755',
      require => Package['storm'],
    }
  }

}
