#!/usr/bin/perl

use CGI;

$query = new CGI;

my $par = $query->param('par') || '';
my $Coo = $par eq "session" ? $query->cookie('session') : $query->cookie('role');
print "Content-type:text/html; charset=UTF-8\r\n\r\n";
print $Coo;

exit;
