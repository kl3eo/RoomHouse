#!/usr/bin/perl
# script to replace strings in massive lists of files (good for recode) --alex shevlakov 
# create filelist  with shell command: find ./ -name "*.c" > filez; find ./ -name "*.h" >>filez , etc.
# Then look for files matching strings to be replaced: grep 'string to replace' `cat filez`
# and finally edit the $line1 section at the bottom of the script, run script and delete backup copies (*.bef)
# if everything is fine

$conttype  = "Content-type: text/html\n Charset: koi8-r\n Pragma: no-cache\n\n";

my @files=('index.html');
	foreach $line (@files) 
		{

		chomp($line);
		$file_name=$line;
		$file_old_name = "$file_name"."\.bef";
		system("mv $file_name $file_old_name");

			
			
			open(OUTF,">$file_name") || print $s=$conttype;
				if ($s eq $conttype) 
				{
					print $file_name;
					exit;
				}
			
			open(INFF,"$file_old_name") || print $s=$conttype;
				if ($s eq $conttype) 
				{
					print $file_name;
					exit;
				}
			@files1=<INFF>;
			
			foreach $line1 (@files1) {
			
			
			
			
$line1=~ s/³/E/g;
$line1=~ s/£/e/g;
$line1=~ s/Ñ/Ñ/g;
$line1=~ s/Ğ/Ğ¿/g;

$line1=~ s/á/Ğ/g;
$line1=~ s/â/Ğ‘/g;
$line1=~ s/÷/Ğ’/g;
$line1=~ s/ç/Ğ“/g;
$line1=~ s/ä/Ğ”/g;
$line1=~ s/å/Ğ•/g;
$line1=~ s/ö/Ğ–/g;
$line1=~ s/ú/Ğ—/g;
$line1=~ s/é/Ğ˜/g;
$line1=~ s/ê/Ğ™/g;
$line1=~ s/ë/Ğš/g;
$line1=~ s/ì/Ğ›/g;
$line1=~ s/í/Ğœ/g;
$line1=~ s/î/Ğ/g;
$line1=~ s/ï/Ğ/g;
$line1=~ s/ğ/ĞŸ/g;
$line1=~ s/ò/Ğ /g;
$line1=~ s/ó/Ğ¡/g;
$line1=~ s/ô/Ğ¢/g;
$line1=~ s/õ/Ğ£/g;
$line1=~ s/æ/Ğ¤/g;
$line1=~ s/è/Ğ¥/g;
$line1=~ s/ã/Ğ¦/g;
$line1=~ s/ş/Ğ§/g;
$line1=~ s/û/Ğ¨/g;
$line1=~ s/ı/Ğ©/g;
$line1=~ s/ø/Ğ¬/g;
$line1=~ s/ù/Ğ«/g;
$line1=~ s/ÿ/Ğª/g;
$line1=~ s/ü/Ğ­/g;
$line1=~ s/à/Ğ®/g;
$line1=~ s/ñ/Ğ¯/g;

$line1=~ s/Á/Ğ°/g;
$line1=~ s/Â/Ğ±/g;
$line1=~ s/×/Ğ²/g;
$line1=~ s/Ç/Ğ³/g;
$line1=~ s/Ä/Ğ´/g;
$line1=~ s/Å/Ğµ/g;
$line1=~ s/Ö/Ğ¶/g;
$line1=~ s/Ú/Ğ·/g;
$line1=~ s/É/Ğ¸/g;
$line1=~ s/Ê/Ğ¹/g;
$line1=~ s/Ë/Ğº/g;
$line1=~ s/Ì/Ğ»/g;
$line1=~ s/Í/Ğ¼/g;
$line1=~ s/Î/Ğ½/g;
$line1=~ s/Ï/Ğ¾/g;
$line1=~ s/Ò/Ñ€/g;
$line1=~ s/Ó/Ñ/g;
$line1=~ s/Ô/Ñ‚/g;
$line1=~ s/Õ/Ñƒ/g;
$line1=~ s/Æ/Ñ„/g;
$line1=~ s/È/Ñ…/g;
$line1=~ s/Ã/Ñ†/g;
$line1=~ s/Ş/Ñ‡/g;
$line1=~ s/Û/Ñˆ/g;
$line1=~ s/İ/Ñ‰/g;
$line1=~ s/Ø/ÑŒ/g;
$line1=~ s/Ù/Ñ‹/g;
$line1=~ s/ß/ÑŠ/g;
$line1=~ s/Ü/Ñ/g;
$line1=~ s/À/Ñ/g;					
				
				print OUTF $line1;
			}
			
			close(OUTF);
			close(INFF);
			
		system("rm -f $file_old_name");	

		}
	exit;
