#!/usr/bin/perl
#

use 5.006;
use CGI;
use DBI;
use TClubMD5;

my $server = "127.0.0.1";
my $user = $primary_user;
my $passwd = $primary_passwd;
my $dbase = $primary_dbase;
my $port = $primary_port;

my $n_counted = 0;
my $n_forum = 10;

my $query = new CGI;

print "Content-Type: text/html; charset=UTF-8\n\n";

my $who = $query->param('who');
my $token = $query->param('token');

my $defdb = "cp";
my $db = defined($query->param('db')) ? $query->param('db') : $defdb;

my $curr_sp = defined($query->param('cat')) ? $query->param('cat') : 0;
my $sport_and = $curr_sp eq '0' ? '' : " sport = $curr_sp and";

my $session = TClubMD5::md5_hex($who.$salt);
my $time_zone = "Europe/Moscow";
my $hourshift = '0 hours';

die("check_alert.pl: token is $token, session is $session, who is $who, salt is $salt!\n") if ($token ne $session);
die("psssooff!\n") if (in_list($who,$pssoff_guys_string));

($dbase,$server,$port,$user,$passwd,$hourshift) = TClubMD5::get_connect_req($ru_en);

$dbase = $db unless (length($dbase));

$dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$user, $passwd);

($n_curr_active_cha,$n_curr_hashsum) = &count_cha_hashsum;

my $n_found = &count_new_forum_msgs;

#print STDERR "Here found is $n_found!\n";

my $ret = $n_curr_active_cha.'&'.$n_curr_hashsum.'&'.$n_found;
print $ret;

$dbconn->disconnect;
$query->delete_all;

#print STDERR "Printed $ret and go!\n";
exit;

sub dBaseError {

    my ($check, $message) = @_;
    print "<H4><FONT COLOR=BLACK><P>$message<BR>Error: ".$check->errstr."</FONT></H4>";
    die("Action failed on command:$message  Error_was:$DBI::errstr");
};

sub in_list { #160

my $guy = shift;
my $str = shift;
my $comma = shift;

if (defined($comma)) {
return 1 if ($str eq $guy || $str =~ /^$guy\,/ || $str =~ /\,$guy\,/ || $str =~ /\,$guy$/);
return 0;
} else {
return 1 if ($str eq $guy || $str =~ /^$guy\#/ || $str =~ /\#$guy\#/ || $str =~ /\#$guy$/);
return 0;
}
}

sub count_cha_hashsum {
     

my $sel = "select count(*), sum(hex_to_int(substr(md5(concat(partner,status::text,date_and_time::text,price::text,place,condition)),0,3))) from challenges, members where$sport_and members.proj_code=challenges.owner and date_and_time > current_timestamp+'$hourshift'";
#print STDERR "Here sel is $sel!\n";

my $res = $dbconn->prepare($sel);
$res->execute;
&dBaseError($res, $sel."  (".$res->rows()." rows found)") if ($res->rows() == -2);

my $r = $res->fetchall_arrayref;

my $ret = (${${$r}[0]}[0] > 0) ? ${${$r}[0]}[0] : 0;
my $ret1 = length(${${$r}[0]}[1]) ? ${${$r}[0]}[1] : 0;

return ($ret,$ret1) ;

}

sub count_new_forum_msgs {

$comm = "select ID from forum where reply_to_num='reply_to_num' and (z_destination is null or z_destination = '' or z_destination ~ '^$who\$' or z_destination ~ '^$who,' or z_destination ~ ',$who,' or z_destination ~ ',$who\$') order by vremya_z desc limit 10";
&getTable;
#print STDERR $comm."\n";
my $n_topics = $ntuples;

$n_topics = $n_forum if ($n_topics > $n_forum);

	for (my $i = 0; $i < $n_topics; $i++) {
		&check_if_there_is_new(${${$listresult}[$i]}[0]);

	}

return $n_counted;
}

sub check_if_there_is_new {

my $moid = shift;
my $search = "select is_replied, who_read, z_destination, author from forum where ID = '$moid'";
my $listResult=$dbconn->prepare($search);

$listResult->execute; 
&dBaseError($listResult, $search."  (".$listResult->rows()." rows found)") 
    if($listResult->rows() == -2);


my $listResult_data=$listResult->fetchall_arrayref;
my $is_replied = ${${$listResult_data}[0]}[0];
my $wr_string =  ${${$listResult_data}[0]}[1];
my $wr_auth =  ${${$listResult_data}[0]}[3];
my $zdest = ${${$listResult_data}[0]}[2];

my @privat = split(',',$zdest);

return if ($who ne $wr_auth && !in_array($who,@privat) && $zdest ne '' && $zdest ne 'z_destination');

$n_counted += ruser_is_not_in_wr_string($wr_string);

 if ($is_replied eq '0') {
	return;
 } else {
	$search = "select ID from forum where reply_to_num = '$moid'";
	$listResult=$dbconn->prepare($search);
	$listResult->execute; 
	&dBaseError($listResult, $search."  (".$listResult->rows()." rows found)") 
    		if($listResult->rows() == -2);
	$listResult_data1{$moid}=$listResult->fetchall_arrayref;
	$ntuples1{$moid}=$listResult->rows;

	for (my $j = 0; $j < $ntuples1{$moid}; $j++) {
		&check_if_there_is_new(${${$listResult_data1{$moid}}[$j]}[0]);

	}
 }

}

sub ruser_is_not_in_wr_string {
my $str = shift;

my @list = split(',',$str);
	foreach my $line (@list) {
		return 0 if ($who eq $line);
	}
return 1;
}

sub getTable {

	$result=$dbconn->prepare($comm);
    	$result->execute;
	&dBaseError($result, $comm."  (".$result->rows()." rows found)") if ($result->rows() ==
	-2);
	
	$listresult = $result->fetchall_arrayref;
	$ntuples = $result->rows();

};

sub in_array { #161

my $guy = shift;
my @l  = @_;
my $count = 1;
foreach my $line (@l) {
	return $count if ($guy eq $line);
	$count++;
}
return 0;
}
