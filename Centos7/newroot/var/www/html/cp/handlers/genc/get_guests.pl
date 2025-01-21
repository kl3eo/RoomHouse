#!/usr/bin/perl

use CGI qw(-no_debug :standard);
use DBI;
use Encode;
use JSON;

my $query = new CGI;
my $room = defined($query->param('room')) ? $query->param('room') : '';

print $query->header;

exit unless length($room);

        my $server      = "127.0.0.1";
        my $port        = "5432";
        my $dbase       = "cp";
        my $user        = "postgres";
        my $passwd      = "x";

        my $dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server", $user, $passwd, {RaiseError => 1}) or die "$DBI::errstr";
        $dbconn->{LongReadLen} = 16384;

        my $sel = "select name, city, country, dtm from joins where room=? and dtm > current_date order by id";

        my $res = $dbconn->prepare($sel);
        $res->execute($room);
        my $r = $res->fetchall_arrayref;
        for (my $i=0; $i < $res->rows(); $i++) {
                ${${$r}[$i]}[0] = decode('UTF-8', ${${$r}[$i]}[0]);
                ${${$r}[$i]}[1] = decode('UTF-8', ${${$r}[$i]}[1]);
                ${${$r}[$i]}[2] = decode('UTF-8', ${${$r}[$i]}[2]);
        }
        $dbconn->disconnect;
        my $j = encode_json($r);
        print $j;


exit;
