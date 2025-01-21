#!/usr/bin/perl

use warnings;

use DBI;
use Encode;
use URI::Encode qw{ uri_decode };

my $debug = 0;

my $logdir = "/home/nobody/apilogs";

my $writing = 0;
my $script_start_time = time;

print "Content-type: application/x-www-form-urlencoded\n\n";

my $relay = '';
my $in = \*STDIN;
my $bytes = read($in, $relay, $ENV{'CONTENT_LENGTH'});

my $data = '';
$relay =~ /phone=(.+)$/; $data .= $1.' ';
$relay =~ /name=(.+)&/; $data .= $1."<br>" if ($1 ne "No+name");
$relay =~ /comment=(.+?)&/; $data .= $1 if ($1 ne "No+comment");

$data =~ s/\+%2B7\+//g;
$data =~ s/\)\+/\)/g;

my $sport = 0;

my $dbserver = "localhost";
my $port = 5432;
my $dbase = "cp";
my $user = "postgres";
my $passwd = "x";

my $dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$dbserver", $user, $passwd);

my $now_time  = time;
my $tt = $now_time - $script_start_time;

print STDERR "Debug: after dbconn, time is $tt\n" if ($debug);

$dbconn->{LongReadLen} = 16384;

$data = decode('UTF-8', uri_decode($data));

$sport = city_selector($data);

unless ($writing) {
	my $cmd = "insert into challenges (condition,time_of_selection, date_and_time, place, price, owner, sport) values (?,current_timestamp,current_timestamp+'2days','General',1,'admin',? )";
	my $result=$dbconn->prepare($cmd);

     	$result->execute($data,$sport);
	&dBaseError($dbconn, $cmd) if (!defined($result));
	
#	my $rv = $result->fetchrow_hashref();
#	my $newid = $rv->{'oid'};
	
#	$cmd = "insert into tags (tag,match_oid) values (current_date::text,$newid)";
#	$result=$dbconn->prepare($cmd);$result->execute;
#        &dBaseError($dbconn, $cmd) if (!defined($result));
}

	
$dbconn->disconnect;

if ($writing) {
	($thissec,$thismin,$thishour,$mday,$mon,$thisyear,$t,$t,$t) = gmtime(time+10800);
	
	$thisyear += 1900;$mon += 1;
	my $logfile = $thisyear.'-'.$mon.'-'.$mday.'-'.$thishour.'-'.$thismin.'-'.$thissec;

	if ( -f "$logdir/$logfile") {
		$logfile .= sprintf("%x", rand 16) for 1..8;
	}

	open (RT,">$logdir/$logfile");
	print RT $relay;
	close RT;
}

exit;

sub getTable { #16

my $now_time  = time;
my $tt = $now_time - $script_start_time;

print STDERR "Debug: in get table - begin, dbase is $dbase; comm is $comm, time is $tt\n" if ($debug);

	$result=$dbconn->prepare($comm);

    	$result->execute;
	&dBaseError($result, $comm."  (".$result->rows()." rows found)") if ($result->rows() ==
	-2);
	
	$listresult = $result->fetchall_arrayref;
	$ntuples = $result->rows();

$now_time  = time;
$tt = $now_time - $script_start_time;

print STDERR "Debug: in get table - end, time is $tt\n" if ($debug);

}

sub dBaseError { #12

    my ($check, $message) = @_;

    my $str = $check->errstr;
    
    die("Action failed on command:$message  Error_was:$DBI::errstr");
}

sub city_selector {

my $data = shift;

my $r = 0;

$data =~ tr/0-9//cd;

if ($data =~ /^79(.+)/ || $data =~ /^89(.+)/) 
{$data = substr($data,1);}

my $start = 4;

my $counter = 0;
my $reg = '';

while ($counter != 1&& $start < 11 ) {
	my $d = substr($data,0,$start);
	$comm = "select region_name from region_codes where substr(concat(code,pattern),1,$start) = '$d'";
	&getTable;
	$counter = $ntuples;
	$reg = ${${$listresult}[0]}[0];
	$start++;
}

$reg = '' if ($start == 10 and $counter != 1);

if ( length($reg) ) {

$c[0] = "��� �������";
$c[1] = "������";
$c[2] = "�����";
$c[3] = "���������";
$c[4] = "��������";
$c[5] = "�������������";
$c[6] = "������������";
$c[7] = "������������";
$c[8] = "������������";
$c[9] = "��������";
$c[10] = "�������";
$c[11] = "������������";
$c[12] = "�������������";
$c[13] = "�����������";
$c[14] = "�����������";
$c[15] = "��������";
$c[16] = "���������";
$c[17] = "�������������";
$c[18] = "���������";
$c[19] = "���������";
$c[20] = "����������";
$c[21] = "���������-����������";
$c[22] = "���������������";
$c[23] = "��������";
$c[24] = "���������";
$c[25] = "����������";
$c[26] = "���������-����������";
$c[27] = "�������";
$c[28] = "�����������";
$c[29] = "���������";
$c[30] = "����";
$c[31] = "�����������";
$c[32] = "�������������";
$c[33] = "������������";
$c[34] = "����";
$c[35] = "����������";
$c[36] = "�������";
$c[37] = "��������";
$c[38] = "�����������";
$c[39] = "����� ��";
$c[40] = "��������";
$c[41] = "������";
$c[42] = "����������";
$c[43] = "��������";
$c[44] = "�������������";
$c[45] = "������������";
$c[46] = "�������������";
$c[47] = "������";
$c[48] = "������������";
$c[49] = "���������";
$c[50] = "����������";
$c[51] = "��������";
$c[52] = "����������";
$c[53] = "���������";
$c[54] = "�����-��������";
$c[55] = "�����������";
$c[56] = "����������";
$c[57] = "���������";
$c[58] = "���� (������)";
$c[59] = "�����������";
$c[60] = "���������";
$c[61] = "�����-���������";
$c[62] = "�����������";
$c[63] = "�������� ������";
$c[64] = "����������";
$c[65] = "��������������";
$c[66] = "������������";
$c[67] = "���������";
$c[68] = "����������";
$c[69] = "���������";
$c[70] = "�������";
$c[71] = "��������";
$c[72] = "��������";
$c[73] = "����";
$c[74] = "��������";
$c[75] = "�����������";
$c[76] = "�����������";
$c[77] = "�������";
$c[78] = "�����-����������";
$c[79] = "�����������";
$c[80] = "���������";
$c[81] = "���������";
$c[82] = "���������";
$c[83] = "������..";

#print STDERR "Here reg is $reg, c83 is $c[83]!\n";

for (my $i = 1; $i < $#c; $i++) {
	if ($c[$i] eq $reg) {
		$r = $i; last;
	}
}

} else { #length zero
	$r = 83;
}

return $r;
}
