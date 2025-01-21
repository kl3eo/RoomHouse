#!/usr/bin/perl
use DBI;

my $server = "127.0.0.1";
my $pguser = "postgres";
my $passwd = "postgres";
my $dbase = "cp";
my $port = 5432;

$dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$pguser, $passwd);

$dbconn->{LongReadLen} = 16384;

my $user = $ARGV[0];
my $acc = $ARGV[1];

#alter table joins add column eligible smallint default 0;
$comm = "select eligible from joins where name = ? and dtm > current_date-1 order by dtm desc";
#print "comm is $comm!\n";

my $result=$dbconn->prepare($comm);
$result->execute($user);
&dBaseError($result, $comm."  (".$result->rows()." rows found)") if ($result->rows() == -2);
my $listresult = $result->fetchall_arrayref;
my $ntuples = $result->rows();
#print "ntuples is $ntuples!\n";

my $eli = $ntuples > 0 ? ${${$listresult}[0]}[0] : 0;
my $rand = rand(10);

#print "Eli is $eli!\n";

if ($eli) {
	my $res = `node /opt/nvme/polka/skydrop_cinema.js --address=$acc --qty=$rand`;
	$res =~ s/(\r|\n)//g; 
	#print "Res is $res!\n";
	if ($res eq "Success") {
		my $cmd = "update joins set eligible = 0 where name = ?";
		my $result = $dbconn->prepare($cmd);
		$result->execute($user);
		&dBaseError($dbconn, $cmd) if (!defined($result));
		#create table skyfall (name text, address text, qty float, dtm timestamp default now());
		my $cmd = "insert into skyfall (name, address, qty) values (?,?,?)";
		my $result = $dbconn->prepare($cmd);
		$result->execute($user, $acc, $rand);
		&dBaseError($dbconn, $cmd) if (!defined($result));		
		
	}
}

#my $filename = '/home/nobody/report.txt';
#open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
#print $fh "User: $user\n";
#print $fh "Acc: $acc\n";
#close $fh;

$dbconn->disconnect;
exit;


sub dBaseError {

    local($check, $message) = @_;
    die("Action failed on command:$message  Error_was:$DBI::errstr");
}
