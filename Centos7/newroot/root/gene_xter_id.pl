#!/usr/bin/perl

use String::Random;

my $sr = String::Random->new;
my $random = $sr->randregex('[A-Z]{8}');

my $res = `sed -i '/UNIQUE_XTER_ID=/d' /etc/sysconfig/interfaces && echo "UNIQUE_XTER_ID=$random" >> /etc/sysconfig/interfaces && chmod 644 /etc/sysconfig/interfaces && cp -a /etc/sysconfig/interfaces /etc/sysconfig/interfaces.new && cp -a /etc/sysconfig/interfaces /etc/sysconfig/interfaces.saved`;
exit;
