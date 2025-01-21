#!/usr/bin/perl


my $res = `grep -r "Invalid handshake response getStatus: 503 Service Unavailable" /home/nobody/vchat/lastlog`;

if (length($res)) {
        print "Res length is ".length($res)."!\n";
        my $r = `/home/nobody/restart_maven.sh`;
}

exit;

