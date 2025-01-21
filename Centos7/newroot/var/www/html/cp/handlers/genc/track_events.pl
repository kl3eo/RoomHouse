#!/usr/bin/perl

use DBI;
use Time::HiRes;

my $dbconn=DBI->connect("dbi:Pg:dbname='cp';port='5432';host='127.0.0.1'", "postgres", "xxx");

while (1) {
   foreach my $i (1,2) {
	$comm = "select img_url from frames where current_timestamp-t < '1 second' and camera = $i and img_url ~ '^frame' limit 1";
	&getTable;
	my $url = $ntuples == 1 ? ${${$listresult}[0]}[0] : '';
	
	my $n = $ntuples;
	$comm = "select cam".$i."_status from objects where object = 'teddy bear'";
	&getTable;
	my $s = $ntuples == 1 ? ${${$listresult}[0]}[0] : '';
	
	my $c = '';
	
	my $e = 0;
	
	if ($n > 0 && $s ne '1') {
		
		$e = 1;
		$c = "begin;insert into events (object, t, camera, event_type, snapshot) values ('teddy bear', current_timestamp, $i, $e,'$url'); update objects set cam".$i."_status = 't' where object = 'teddy bear';commit;";
	
	} elsif ($n == 0 && $s eq '1') {
	
		$comm = "select img_url from frames where current_timestamp-t < '1 second' and camera = $i and img_url ~ '^back' limit 1";
		&getTable;
		
		if ($ntuples == 1) {
			$e = 2;
			$pho = 	${${$listresult}[0]}[0];
			$c = "begin;insert into events (object, t, camera, event_type, snapshot) values ('teddy bear', current_timestamp, $i, $e, '$pho'); update objects set cam".$i."_status = 'f' where object = 'teddy bear';commit;";
		}
		
		#$c = $ntuples == 1 ? '' : "begin;insert into events (object, t, camera, event_type, snapshot) values ('teddy bear', current_timestamp, $i, 2, 'anon.png'); update objects set cam".$i."_status = 'f' where object = 'teddy bear';commit;";
	}
	
	if (length($c)) {
		my $result=$dbconn->prepare($c);
		my $nr = $result->execute;
		print "event $e just inserted for camera $i!\n";
	}
	
   } #cameras
Time::HiRes::sleep(0.5);
}

$dbconn->disconnect;
exit;

sub getTable { #16

	$result=$dbconn->prepare($comm);

    	$result->execute;
	die("Action failed on command:$comm  Error_was:$DBI::errstr") if ($result->rows() == -2);
	
	$listresult = $result->fetchall_arrayref;
	$ntuples = $result->rows();

}
