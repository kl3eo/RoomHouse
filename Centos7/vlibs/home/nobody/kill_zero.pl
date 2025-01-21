#!/usr/bin/perl
use DBI;

my $server = "127.0.0.1";
my $pguser = "postgres";
my $passwd = "postgres";
my $dbase = "people";
my $port = 5432;

my $dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$pguser, $passwd);

$dbconn->{LongReadLen} = 16384;

$comm = "select accid from not_changed_1369 where addr is null order by baltot, nonce";
my $result=$dbconn->prepare($comm);
$result->execute();
&dBaseError($result, $comm."  (".$result->rows()." rows found)") if ($result->rows() == -2);
my $listresult = $result->fetchall_arrayref;
my $ntuples = $result->rows();

for (my $i = 0; $i < $ntuples; $i++) {
	my $acc = ${${$listresult}[$i]}[0];
	my $res = `node /opt/nvme/polka/setbal.js --address=$acc`;
	$res =~ s/(\r|\n)//g; #5DSSqa6JYQrg9EBwMChRvTXmbfJCGCSEorN7hDAhj7znZYaA
	#print "res is $res!\n";
	my @ress = split(' ', $res);
	if ($ress[0] =~ /^5[A-z0-9]{47}$/) {
		my $cmd = "update not_changed_1369 set addr = ?, hash = ? where accid = ?";
		my $result = $dbconn->prepare($cmd);
		$result->execute($ress[0], $ress[1], $acc);
		&dBaseError($dbconn, $cmd) if (!defined($result));
	}
}

$dbconn->disconnect;
exit;


sub dBaseError {

    local($check, $message) = @_;
    die("Action failed on command:$message  Error_was:$DBI::errstr");
}
