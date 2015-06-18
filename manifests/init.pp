# Will require snort::sensor

class snuffler ( $ip_ranges, $dns_servers = '$HOME_NET', $snort_perfprofile = "false", $stream_memcap = "8388608", $stream_prune_log_max = "1048576", $stream_max_queued_segs = "2621", $stream_max_queued_bytes = "1048576", $perfmonitor_pktcnt = "10000", $dcerpc2_memcap = "102400", $enable = true, $ensure = running ) {

  package {
    snuffler:
      ensure => installed,
      require => User['snort'];
  }

  file {
    "/etc/snuffler/rules/local.rules":
      source => [ "puppet:///modules/snort/local/local.rules-$::fqdn",
                  "puppet:///modules/snort/local/local.rules" ],
      mode => 644,
      owner => "root",
      group => "root",
      ensure => present,
      force => true,
      notify => Service[snufflerd],
      require => Package[snuffler];
    "/etc/snuffler/rules":
      ensure => directory,
      mode => 644,
      owner => "root",
      group => "root",
      notify => Service[snufflerd],
      require => Package[snuffler];
    "/etc/snuffler/rules/all.rules" :
      source => "puppet:///modules/snuffler/rules/all.rules",
      mode => 644,
      owner => "root",
      group => "root",
      notify => Service[snufflerd],
      require => Package[snuffler];
    "/etc/snuffler/snuffler.conf":
      mode => 644,
      owner => "root",
      group => "root",
      alias => "snufflerconf",
      content => template( "snuffler/snuffler.conf.erb"),
      notify => Service[snufflerd],
      require => Package[snuffler];
    "/etc/sysconfig/snuffler":
      source => [ "puppet:///modules/snuffler/sysconfig/snuffler-$::fqdn",
                  "puppet:///modules/snuffler/sysconfig/snuffler" ],
      mode => 644,
      owner => "root",
      group => "root",
      notify => Service[snufflerd],
      require => Package[snuffler];
    "/etc/snuffler/suspicious_hosts.bpf":
      source => ["puppet:///modules/snuffler/bpf/suspicious_hosts.bpf-${::fqdn}",
                 "puppet:///modules/snuffler/bpf/suspicious_hosts.bpf"],
      mode => 644,
      owner => "root",
      group => "root",
      notify => Service[snufflerd],
      require => Package[snuffler];
  }

  service {
    snufflerd:
      ensure => $ensure,
      enable => $enable,
      hasstatus => true,
      hasrestart => true,
      require => Package[snuffler];
  }
}
