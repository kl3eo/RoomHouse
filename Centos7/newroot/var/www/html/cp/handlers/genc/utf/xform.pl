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

$c[0] = "Все регионы";
$c[1] = "Адыгея";
$c[2] = "Алтай";
$c[3] = "Алтайский";
$c[4] = "Амурская";
$c[5] = "Архангельская";
$c[6] = "Астраханская";
$c[7] = "Башкортостан";
$c[8] = "Белгородская";
$c[9] = "Брянская";
$c[10] = "Бурятия";
$c[11] = "Владимирская";
$c[12] = "Волгоградская";
$c[13] = "Вологодская";
$c[14] = "Воронежская";
$c[15] = "Дагестан";
$c[16] = "Еврейская";
$c[17] = "Забайкальский";
$c[18] = "Ингушетия";
$c[19] = "Иркутская";
$c[20] = "Ивановская";
$c[21] = "Кабардино-Балкарская";
$c[22] = "Калининградская";
$c[23] = "Калмыкия";
$c[24] = "Калужская";
$c[25] = "Камчатский";
$c[26] = "Карачаево-Черкесская";
$c[27] = "Карелия";
$c[28] = "Кемеровская";
$c[29] = "Кировская";
$c[30] = "Коми";
$c[31] = "Костромская";
$c[32] = "Краснодарский";
$c[33] = "Красноярский";
$c[34] = "Крым";
$c[35] = "Курганская";
$c[36] = "Курская";
$c[37] = "Липецкая";
$c[38] = "Магаданская";
$c[39] = "Марий Эл";
$c[40] = "Мордовия";
$c[41] = "Москва";
$c[42] = "Мурманская";
$c[43] = "Ненецкий";
$c[44] = "Нижегородская";
$c[45] = "Новгородская";
$c[46] = "Новосибирская";
$c[47] = "Омская";
$c[48] = "Оренбургская";
$c[49] = "Орловская";
$c[50] = "Пензенская";
$c[51] = "Пермский";
$c[52] = "Приморский";
$c[53] = "Псковская";
$c[54] = "Ямало-Ненецкий";
$c[55] = "Ярославская";
$c[56] = "Ростовская";
$c[57] = "Рязанская";
$c[58] = "Саха (Якутия)";
$c[59] = "Сахалинская";
$c[60] = "Самарская";
$c[61] = "Санкт-Петербург";
$c[62] = "Саратовская";
$c[63] = "Северная Осетия";
$c[64] = "Смоленская";
$c[65] = "Ставропольский";
$c[66] = "Свердловская";
$c[67] = "Тюменская";
$c[68] = "Тамбовская";
$c[69] = "Татарстан";
$c[70] = "Томская";
$c[71] = "Тульская";
$c[72] = "Тверская";
$c[73] = "Тыва";
$c[74] = "Удмуртия";
$c[75] = "Ульяновская";
$c[76] = "Хабаровский";
$c[77] = "Хакасия";
$c[78] = "Ханты-Мансийский";
$c[79] = "Челябинская";
$c[80] = "Чеченская";
$c[81] = "Чукотский";
$c[82] = "Чувашская";
$c[83] = "Другое..";

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
