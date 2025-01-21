#!/usr/bin/perl

my $mycabo = $ARGV[0];
my $par = $ARGV[1];

#ru
if ($mycabo eq "club" || $mycabo =~ /rgsu/) {
	if ($par) {
        	my $res = `/usr/bin/sed -i "s/open_cabo pblue/closed_cabo pred/g" /var/www/html/cp/public_html/join_$mycabo.html && sed -i -E "s/128275; ОТКРЫТО/128273; НУЖЕН КЛЮЧ/g" /var/www/html/cp/public_html/join_$mycabo.html`;
	} else {
       		my $res = `/usr/bin/sed -i "s/closed_cabo pred/open_cabo pblue/g" /var/www/html/cp/public_html/join_$mycabo.html && sed -i -E "s/128273; НУЖЕН КЛЮЧ/128275; ОТКРЫТО/g" /var/www/html/cp/public_html/join_$mycabo.html`;
	}
#en
} else {
	if ($par) {
        	my $res = `/usr/bin/sed -i "s/open_cabo pblue/closed_cabo pred/g" /var/www/html/cp/public_html/join_$mycabo.html && sed -i -E "s/128275; DOOR IS UNLOCKED/128273; MUST HAVE A KEY/g" /var/www/html/cp/public_html/join_$mycabo.html`;
	} else {
        	my $res = `/usr/bin/sed -i "s/closed_cabo pred/open_cabo pblue/g" /var/www/html/cp/public_html/join_$mycabo.html && sed -i -E "s/128273; MUST HAVE A KEY/128275; DOOR IS UNLOCKED/g" /var/www/html/cp/public_html/join_$mycabo.html`;
	}
}
