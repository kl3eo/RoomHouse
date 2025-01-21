#!/usr/bin/perl

use CGI;
use MIME::Base64;

my $q = new CGI;
my $u = $q->param('u');
$u = MIME::Base64::decode_base64($u);

my $filepath= "/opt/nvme/ssd/shared/$u";

print $q->header(  -type => 'application/octet-stream',  -Content_Disposition => 'attachment;filename='.$u);

open FILE, "< $filepath" or die "can't open : $!";
binmode FILE;
local $/ = \10240;
while (<FILE>){
    print $_;
}

close FILE;
