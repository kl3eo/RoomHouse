#!/usr/bin/perl

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

my $par = $ARGV[0];
my $obj = $ARGV[1];

my $event = $par eq '1' ? "appeared" : $par eq '2' ? "disappeared" : "undefined";

my $t = `date`;
my $text = "object $obj $event at $t";
my $phone = `cat /etc/sysconfig/interfaces.new | grep SMS | awk -F '=' '{print \$2}'`; $phone =~ s/(\r|\n)//g;

my $req = POST 'https://sms.ru/sms/send',[api_id => '114DE85C-4557-EA83-E96D-B0BE8C4A60E2',to => $phone,text => $text.'_'.$par];
$ua = LWP::UserAgent->new;
print STDERR $ua->request($req)->as_string;

exit;
