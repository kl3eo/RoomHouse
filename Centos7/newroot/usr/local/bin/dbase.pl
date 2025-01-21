#!/usr/bin/perl

use MIME::Base64;

my $ret = MIME::Base64::decode_base64($ARGV[0]);
print $ret;
exit;
