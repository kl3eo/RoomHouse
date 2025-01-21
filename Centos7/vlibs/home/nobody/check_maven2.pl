#!/usr/bin/perl


my $res = `grep -r "Message will not be sent because the WebSocket session has been closed" /home/nobody/vchat/lastlog`;

if (length($res)) {
        print "Res length is ".length($res)."!\n";
        my $r = `/home/nobody/restart_maven.sh`;
}

exit;

