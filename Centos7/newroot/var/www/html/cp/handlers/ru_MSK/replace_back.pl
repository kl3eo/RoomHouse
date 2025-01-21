#!/usr/bin/perl
# script to replace strings in massive lists of files (good for recode) --alex shevlakov 
# create filelist  with shell command: find ./ -name "*.c" > filez; find ./ -name "*.h" >>filez , etc.
# Then look for files matching strings to be replaced: grep 'string to replace' `cat filez`
# and finally edit the $line1 section at the bottom of the script, run script and delete backup copies (*.bef)
# if everything is fine

$conttype  = "Content-type: text/html\n Charset: koi8-r\n Pragma: no-cache\n\n";
my @files=('TClub_LANG_ru.rus');

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
			
			
			
			
$line1=~ s/Ğ/á/g;
$line1=~ s/Ğ‘/â/g;
$line1=~ s/Ğ’/÷/g;
$line1=~ s/Ğ“/ç/g;
$line1=~ s/Ğ”/ä/g;
$line1=~ s/Ğ•/å/g;
$line1=~ s/Ğ–/ö/g;
$line1=~ s/Ğ—/ú/g;
$line1=~ s/Ğ˜/é/g;
$line1=~ s/Ğ™/ê/g;
$line1=~ s/Ğš/ë/g;
$line1=~ s/Ğ›/ì/g;
$line1=~ s/Ğœ/í/g;
$line1=~ s/Ğ/î/g;
$line1=~ s/Ğ/ï/g;
$line1=~ s/ĞŸ/ğ/g;
$line1=~ s/Ğ /ò/g;
$line1=~ s/Ğ¡/ó/g;
$line1=~ s/Ğ¢/ô/g;
$line1=~ s/Ğ£/õ/g;
$line1=~ s/Ğ¤/æ/g;
$line1=~ s/Ğ¥/è/g;
$line1=~ s/Ğ¦/ã/g;
$line1=~ s/Ğ§/ş/g;
$line1=~ s/Ğ¨/û/g;
$line1=~ s/Ğ©/ı/g;
$line1=~ s/Ğ¬/ø/g;
$line1=~ s/Ğ«/ù/g;
$line1=~ s/Ğª/ÿ/g;
$line1=~ s/Ğ­/ü/g;
$line1=~ s/Ğ®/à/g;
$line1=~ s/Ğ¯/ñ/g;

$line1=~ s/Ğ°/Á/g;
$line1=~ s/Ğ±/Â/g;
$line1=~ s/Ğ²/×/g;
$line1=~ s/Ğ³/Ç/g;
$line1=~ s/Ğ´/Ä/g;
$line1=~ s/Ğµ/Å/g;
$line1=~ s/Ğ¶/Ö/g;
$line1=~ s/Ğ·/Ú/g;
$line1=~ s/Ğ¸/É/g;
$line1=~ s/Ğ¹/Ê/g;
$line1=~ s/Ğº/Ë/g;
$line1=~ s/Ğ»/Ì/g;
$line1=~ s/Ğ¼/Í/g;
$line1=~ s/Ğ½/Î/g;
$line1=~ s/Ğ¾/Ï/g;
$line1=~ s/Ñ€/Ò/g;
$line1=~ s/Ñ/Ó/g;
$line1=~ s/Ñ‚/Ô/g;
$line1=~ s/Ñƒ/Õ/g;
$line1=~ s/Ñ„/Æ/g;
$line1=~ s/Ñ…/È/g;
$line1=~ s/Ñ†/Ã/g;
$line1=~ s/Ñ‡/Ş/g;
$line1=~ s/Ñˆ/Û/g;
$line1=~ s/Ñ‰/İ/g;
$line1=~ s/ÑŒ/Ø/g;
$line1=~ s/Ñ‹/Ù/g;
$line1=~ s/ÑŠ/ß/g;
$line1=~ s/Ñ/Ü/g;
$line1=~ s/Ñ/À/g;

$line1=~ s/Ñ/Ñ/g;
$line1=~ s/Ğ¿/Ğ/g;
				
				print OUTF $line1;
			}
			
			close(OUTF);
			close(INFF);
			
		system("rm -f $file_old_name");	

		}
	exit;
