#!/usr/bin/perl

use CGI;
use File::Basename;

$CGI::POST_MAX = 1024 * 500000;
#my $safe_filename_characters = "a-zA-Z0-9_.-";
my $upload_dir = "/opt/nvme/ssd/shared";

my $query = new CGI;
my $filename = $query->param("uploaded_file");

if ( !$filename )
{
print $query->header ( );
print "There was a problem uploading your photo (try a smaller file).";
exit;
}

my ( $name, $path, $extension ) = fileparse ( $filename, '..*' );
$filename = $name . $extension;
$filename =~ tr/ /_/;
#$filename =~ s/[^$safe_filename_characters]//g;

#if ( $filename =~ /^([$safe_filename_characters]+)$/ )
#{
#$filename = $1;
#}
#else
#{
#die "Filename contains invalid characters";
#}

my $upload_filehandle = $query->upload("uploaded_file");

open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";
binmode UPLOADFILE;

while ( <$upload_filehandle> )
{
print UPLOADFILE;
}

close UPLOADFILE;

print $query->header ( );
print <<END_HTML;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Thanks!</title>
<script>
location.href='/?mode=uc_files_win';
</script>
</head>
<body>
</body>
</html>
END_HTML
