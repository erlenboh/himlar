class profile::application::builder (
  $rc_file,
  $template_dir,
  $download_dir,
  $az    = undef,
  $user  = 'imagebuilder',
  $group = 'imagebuilder',
  $flavor = 'm1.small',
  $insecure = false,
) {

  if $az {
    $real_az = $az
  } else {
    $real_az = "${::location}-default-1"
  }

  file { '/opt/images':
    ensure => directory,
    mode   => '0755'
  } ->
  file { '/opt/images/public_builds':
    ensure => directory,
    mode   => '0755'
  }

  file { '/etc/imagebuilder':
    ensure => directory,
    mode   => '0755'
  } ->
  file { '/etc/imagebuilder/config':
    ensure  => file,
    mode    => '0644',
    content => "[main]\ntemplate_dir = ${template_dir}\ndownload_dir = ${download_dir}\n"
  } ->
  file { "${template_dir}/template":
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/application/builder/template.erb"),
  }

  group { $group:
    ensure => present
  } ->
  user { $user:
    ensure     => present,
    managehome => true,
    gid        => $group,
    before     => Class['profile::openstack::openrc']
  }

  create_resources('profile::application::builder::jobs', hiera_hash('profile::application::builder::images', {}))
}
