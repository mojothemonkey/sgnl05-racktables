# Installs RackTables
class racktables::config (
  $secretfile = $::racktables::secretfile,
  $apacheuser = $::racktables::apacheuser,
  $datadir    = $::racktables::datadir,
) {

  validate_string($secretfile)
  validate_string($apacheuser)
  validate_string($datadir)

  case $secretfile {

    'template': {
      $db_username           = $racktables::db_username
      $db_password           = $racktables::db_password
      $db_name               = $racktables::db_name
      $db_host               = $racktables::db_host
      $user_auth_src         = $racktables::user_auth_src
      $require_local_account = $racktables::require_local_account
      $pdo_bufsize           = $racktables::pdo_bufsize
      $ldap_options          = $racktables::ldap_options
      $saml_options          = $racktables::saml_options
      $helpdesk_banner       = $racktables::helpdesk_banner

      file { "${datadir}/wwwroot/inc/secret.php":
        ensure  => present,
        owner   => $apacheuser,
        mode    => '0400',
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'httpd_sys_content_t',
        content => template('racktables/secret.erb'),
        require => Vcsrepo[$datadir],
      }
    }

    /^r/: {
      file { "${datadir}/wwwroot/inc/secret.php":
        ensure  => present,
        owner   => $apacheuser,
        mode    => '0400',
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'httpd_sys_content_t',
        require => Vcsrepo[$datadir],
      }
    }

    /^w/: {
      file { "${datadir}/wwwroot/inc/secret.php":
        ensure  => present,
        owner   => $apacheuser,
        mode    => '0600',
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'httpd_sys_content_t',
        require => Vcsrepo[$datadir],
      }
    }

    'absent', 'delete': {
      file { "${datadir}/wwwroot/inc/secret.php":
        ensure => absent,
      }
    }

    undef: { # No action
    }

    default: { # Assume the $secretfile is the string content
      if is_string($secretfile) {
        file { "${datadir}/wwwroot/inc/secret.php":
          ensure  => present,
          owner   => $apacheuser,
          mode    => '0400',
          seluser => 'system_u',
          selrole => 'object_r',
          seltype => 'httpd_sys_content_t',
          require => Vcsrepo[$datadir],
          content => $secretfile,
        }
      } else {
        fail('secretfile is not a string')
      }
    }

  }

}
