#!/usr/bin/perl
use CGI;

my $q = new CGI;

print "Content-Type: text/html; charset=UTF-8\n\n";

my $base = defined ($q->param('size')) ? $q->param('size') : 36;

my $base1 = 31753000; #virtio w10 drivers

my $cd = "/opt/nvme/iso/virtio_w10_64.iso";
my $vm = "/opt/nvme/ssd/vm.img";

if ( -f $cd && ! -f $vm) {

	my $s = `ls -la $cd | awk '{print \$5}'`; $s =~ s/(\r|\n)//g;
	$ret = int(($s/$base1) * 100);
	
	
} elsif (-f $vm) {
	
	my $s = `ls -la $vm | awk '{print \$5/(1024*1024*1024)}'`; $s =~ s/(\r|\n)//g;
	$ret = int(($s/$base) * 100);

}

print $ret;
exit;
