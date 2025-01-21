#!/usr/bin/perl

my $par = $ARGV[0];
my $ch_str = '';my $ch_str_a = '';

my $current_sp = `cat /etc/sysconfig/interfaces | grep KEY5 | awk -F '=' '{print \$2}'`;
$current_sp =~ s/\n//g;$current_sp =~ s/\r//g;

if ($par eq "px") 
{
	$ch_str = "ps aux | grep /usr/sbin/squid |  grep -v squid2 | grep -v grep | awk '{print \$2}'";
	$ch_str_a = "ps aux | grep /usr/sbin/squid |  grep squid2 | grep -v grep | awk '{print \$2}'" if ($current_sp eq '1');
}

if ($par eq "ts") 
{
	$ch_str = "ps aux | grep sendmail |  grep -v grep | grep accepting | awk '{print \$2}'";
}

if ($par eq "ry") 
{
	$ch_str = "ps aux | grep cyrus-master |  grep -v grep | grep Ss | awk '{print \$2}'";
	
	unless ($current_sp eq '1') { #home softpack disabled daemons
		print -1;
		exit;
	}

}

if ($par eq "sy") 
{
	$ch_str = "ps aux | grep /usr/sbin/smbd |  grep -v grep | grep Ss | awk '{print \$2}'";
	$ch_str_a = "ps aux | grep /usr/sbin/nmbd |  grep -v grep | grep Ss | awk '{print \$2}'";
	
	unless ($current_sp eq '1') { #home softpack disabled daemons
		print -1;
		exit;
	}

}

if ($par eq "hy") 
{
	$ch_str = "ps aux | grep httpd |  grep -v grep | grep Ss | awk '{print \$2}'";
}

if ($par eq "fy") 
{
	$ch_str = "ps aux | grep ./wftpserver |  grep -v grep | awk '{print \$2}'";
	
	unless ($current_sp eq '1') { #home softpack disabled daemons
		print -1;
		exit;
	}

}

if ($par eq "py") 
{
	$ch_str = "ps aux | grep /usr/local/pgsql/bin/postgres |  grep -v grep | awk '{print \$2}'";
}

if ($par eq "ny") 
{
	$ch_str = "ps aux | grep /usr/sbin/named |  grep -v grep | grep Ss | awk '{print \$2}'";
}
	
my $ret = '';

if (length($ch_str)) {

	$ret = `$ch_str`; $ret =~ s/(\r|\n)//d;

	if (length($ch_str_a && ($ret =~ /^\d+$/) )) {
		$ret = `$ch_str_a`;
	}
}

print $ret;

exit;
