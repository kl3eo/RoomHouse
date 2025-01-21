#!/bin/perl

use strict;

my $file = "/etc/sysconfig/whitelist";

my $ret = 0;
$ret = `/sbin/iptables -t filter -A OUTPUT -d 8.8.0.0/16 -p tcp --dport 53 -j ACCEPT`;
$ret = `/sbin/iptables -t filter -A OUTPUT -d 8.8.0.0/16 -p udp --dport 53 -j ACCEPT`;

$ret = `rm -rf /etc/squid/blocked_https.txt`;
$ret = `rm -rf /etc/squid/allowed_https.txt`;
$ret = `touch /etc/squid/blocked_https.txt`;
$ret = `touch /etc/squid/allowed_https.txt`;

if (open my $info, $file) {

	while( my $line = <$info>)  {
		$line =~ s/(\r|\n)//g;
	   if ($line =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3})$/ || $line =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3})$/ || $line =~ /^(\d{1,3}\.\d{1,3})$/ ) {
		if ($line =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3})$/) {
			$line .= ".0/24";
		} elsif ($line =~ /^(\d{1,3}\.\d{1,3})$/) {
			$line .= ".0.0/16";
		}
	   	$ret = `/sbin/iptables -A OUTPUT -d $line -j ACCEPT`;
	   } elsif ($line =~ /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/) {
	   	
		my $ln = '.'.$line;
		$ret = `echo $ln >> /etc/squid/allowed_https.txt`;

	     if(0) {
		my @r = split('\s',`/usr/bin/dig \@8.8.8.8 +short $line`);
		foreach my $l (@r) {
			if ($l	=~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3})$/ ) {
				$ret = `/sbin/iptables -A OUTPUT -d $l -j ACCEPT`;
			} else {
				print STDERR "Here l is $l\n";
			}		
		}
	     }
	   }
	}
	$ret = `echo .xetr.ru >> /etc/squid/allowed_https.txt`;
	close $info;
} #if open

$ret = `service squid restart`;
$ret = `cat /var/run/squid2.pid`;
$ret = `kill -HUP $ret`;

exit;
