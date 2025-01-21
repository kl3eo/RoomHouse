#!/usr/bin/perl
########################################################################
#
# perl-md5-login: a Perl/CGI + JavaScript password protection scheme
#
# usage: removeUser.pl <userName>
#
########################################################################
use Digest::MD5 qw(md5_hex);
use DB_File;
use strict;

my ($userName,$addon) = @ARGV;

my $user_database_full_path ="/var/www/html/cp/handlers/users.db";
$user_database_full_path ="/var/www/html/cp/handlers/users_$addon.db" if (length($addon));
if (!$userName) {

     print "\nusage: removeUser.pl <userName>\n\n";
     exit;
}

deleteHashValue($user_database_full_path,$userName);

print "user $userName was removed from the database $user_database_full_path\n";

exit;

########################################################################

sub deleteHashValue {

     my ($file,$key) = @_;

     my %hash;

     tie(%hash,'DB_File',$file,O_CREAT|O_RDWR,0664,$DB_HASH) or

          die "Unable to open hash file\n";

     delete $hash{$key};

     untie(%hash) or die "Unable to close hash file\n";
}
