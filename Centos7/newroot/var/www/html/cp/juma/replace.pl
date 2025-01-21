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
			
			
			
			
$line1=~ s/�/E/g;
$line1=~ s/�/e/g;
$line1=~ s/�/я/g;
$line1=~ s/�/п/g;

$line1=~ s/�/А/g;
$line1=~ s/�/Б/g;
$line1=~ s/�/В/g;
$line1=~ s/�/Г/g;
$line1=~ s/�/Д/g;
$line1=~ s/�/Е/g;
$line1=~ s/�/Ж/g;
$line1=~ s/�/З/g;
$line1=~ s/�/И/g;
$line1=~ s/�/Й/g;
$line1=~ s/�/К/g;
$line1=~ s/�/Л/g;
$line1=~ s/�/М/g;
$line1=~ s/�/Н/g;
$line1=~ s/�/О/g;
$line1=~ s/�/П/g;
$line1=~ s/�/Р/g;
$line1=~ s/�/С/g;
$line1=~ s/�/Т/g;
$line1=~ s/�/У/g;
$line1=~ s/�/Ф/g;
$line1=~ s/�/Х/g;
$line1=~ s/�/Ц/g;
$line1=~ s/�/Ч/g;
$line1=~ s/�/Ш/g;
$line1=~ s/�/Щ/g;
$line1=~ s/�/Ь/g;
$line1=~ s/�/Ы/g;
$line1=~ s/�/Ъ/g;
$line1=~ s/�/Э/g;
$line1=~ s/�/Ю/g;
$line1=~ s/�/Я/g;

$line1=~ s/�/а/g;
$line1=~ s/�/б/g;
$line1=~ s/�/в/g;
$line1=~ s/�/г/g;
$line1=~ s/�/д/g;
$line1=~ s/�/е/g;
$line1=~ s/�/ж/g;
$line1=~ s/�/з/g;
$line1=~ s/�/и/g;
$line1=~ s/�/й/g;
$line1=~ s/�/к/g;
$line1=~ s/�/л/g;
$line1=~ s/�/м/g;
$line1=~ s/�/н/g;
$line1=~ s/�/о/g;
$line1=~ s/�/р/g;
$line1=~ s/�/с/g;
$line1=~ s/�/т/g;
$line1=~ s/�/у/g;
$line1=~ s/�/ф/g;
$line1=~ s/�/х/g;
$line1=~ s/�/ц/g;
$line1=~ s/�/ч/g;
$line1=~ s/�/ш/g;
$line1=~ s/�/щ/g;
$line1=~ s/�/ь/g;
$line1=~ s/�/ы/g;
$line1=~ s/�/ъ/g;
$line1=~ s/�/э/g;
$line1=~ s/�/ю/g;					
				
				print OUTF $line1;
			}
			
			close(OUTF);
			close(INFF);
			
		system("rm -f $file_old_name");	

		}
	exit;
