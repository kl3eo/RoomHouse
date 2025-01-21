#!/usr/bin/perl
########################################################################
#
# perl-md5-login: a Perl/CGI + JavaScript password protection scheme
#
# usage: addUser.pl <userName> <password> <email@company.com>
#
########################################################################
use Digest::MD5 qw(md5_hex);
use DB_File;
use strict;

my ($userName,$password,$email,$addon) = @ARGV;

my $user_database_full_path ="/var/www/html/cp/handlers/users.db";
$user_database_full_path ="/var/www/html/cp/handlers/users_$addon.db" if (length($addon));

if (!$userName or !$password or !$email) {

     print "\nusage: addUser.pl <userName> <password> <email\@company.com>\n\n";
     exit;
}

setHashValue($user_database_full_path,
             $userName,
             md5_hex($password . $userName) . '||' . $email
            );

print "\nUser $userName was added to the database $user_database_full_path\n";

exit;

########################################################################

sub setHashValue {

     my ($file,$key,$value) = @_;

     my %hash;

     tie(%hash,'DB_File',$file,O_CREAT|O_RDWR,0664,$DB_HASH) or

          die "Unable to open hash file\n";

     if ( exists $hash{$key} ) { 

          print "\nUser $key already exists in the database; choose another name.\n";
          exit;
     }

     $hash{$key} = $value;

     untie(%hash) or die "Unable to close hash file\n";
}





