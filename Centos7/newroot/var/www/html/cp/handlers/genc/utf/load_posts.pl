#!/usr/bin/perl
#

use 5.006;
use DBI;
use CGI;
use TClubMD5;
use JSON;
use Date::Calc qw(Day_of_Week);

my $query = new CGI;

my $touch_specific_bro = 0; $touch_specific_bro = 1 if (defined($query->param('touch')) && $query->param('touch') eq '1');

my $r_user = $query->param('who');

my $token = $query->param('token');
my $num_order = defined($query->param('num_order')) ? $query->param('num_order') : 20;

my $type = defined($query->param('type')) ? $query->param('type') : 0;

my $f = defined( $query->param('filter') ) ? $query->param('filter') : '';
my $ft = defined( $query->param('filtertable') ) ? $query->param('filtertable') : 0;

my $filter = length($f) && ($type eq '5' || $type eq '3') ? " lower(tags.tag) ~ lower('$f') and tags.match_oid=challenges.ID and" : '';
my $taddon = length($f) && ($type eq '5' || $type eq '3') ? ", tags" : '';

my $session = TClubMD5::md5_hex($r_user.$salt);

die("load_posts.pl: token is $token, session is $session, who is $r_user, salt is $salt!\n") if ($token ne $session);

my $is_admin = $r_user eq "admin" ? 1 : 0;
$language = "russian";

($dbase,$server,$port,$user,$passwd,$hourshift) = TClubMD5::get_connect_req($ru_en);

my $limit = defined($query->param('lim')) ? $query->param('lim') : 2;
my $off = defined($query->param('start')) ? $query->param('start') : 0;
my $curr_sport = defined($query->param('sport')) ? $query->param('sport') : 0;

#print STDERR "Here start is $off, limit is $limit, type is $type, sport is $curr_sport!\n";

print "Content-Type: text/html; charset=".$default_charset."\n\n";

$dbconn=DBI->connect("dbi:Pg:dbname=$dbase;port=$port;host=$server",$user, $passwd);
$dbconn->{LongReadLen} = 16384;

if ($ft eq '1' && $type eq '3' && length ($f) ) {$f = nkname_lookup($f,1); $filter = " partner = '$f' and"; $taddon = '';}
if ($ft eq '2') {$filter = $f eq "yesterday" ? " challenges.time_of_selection < current_date and challenges.time_of_selection > current_date-1 and" : $f eq "today" ? " challenges.time_of_selection > current_date and" :''; $taddon = '';}

my $city = 0; my $curr_balance = 0;

($city, $curr_balance) = &check_user(0) unless ($is_admin);

my $def_req_order = $type eq '5' ? "challenges.time_of_selection desc" : "challenges.date_and_time desc";
$def_req_order = $type eq '1' ? "members.p_vremya_z" : $def_req_order;

my $requested_order = $num_order == 21 ? "challenges.date_and_time" : $num_order == 20 ? "challenges.date_and_time desc" :
			$num_order == 1 ? "challenges.price" : $num_order == 0 ? "challenges.price desc" :
			$num_order == 11 ? "challenges.place" : $num_order == 10 ? "challenges.place desc" :
			$num_order == 31 ? "challenges.condition" : $num_order == 30 ? "challenges.condition desc" :
			$num_order == 41 ? "challenges.time_of_selection" : $num_order == 40 ? "challenges.time_of_selection desc" : $def_req_order;

if ($type eq '1') {
$requested_order = $num_order == 21 ? "members.p_vremya_z" : $num_order == 20 ? "members.p_vremya_z desc" :
			$num_order == 1 ? "members.a_nkname" : $num_order == 0 ? "members.a_nkname desc" :
			$num_order == 11 ? "members.k_kredit" : $num_order == 10 ? "members.k_kredit desc" :
			$num_order == 31 ? "members.d_spec" : $num_order == 30 ? "members.d_spec" : $def_req_order
}

my $sport_and = $curr_sport  eq '0' ? '' : " sport = '$curr_sport' and";			
$comm = "select members.ID, challenges.owner, challenges.place, challenges.date_and_time, challenges.condition, members.e_masterst, challenges.ID, challenges.status, challenges.partner, challenges.time_of_selection, challenges.price, challenges.hashed_condition from challenges, members 
where$sport_and challenges.date_and_time > current_timestamp+'$hourshift' and members.proj_code=challenges.owner order by $requested_order, challenges.ID limit $limit offset $off";

$comm = "select members.ID, challenges.owner, challenges.place, challenges.date_and_time, challenges.condition, members.e_masterst, challenges.ID, challenges.status, challenges.partner, challenges.time_of_selection, challenges.price, challenges.hashed_condition from challenges, members$taddon 
where$sport_and$filter challenges.status = 'f' and length(challenges.partner) > 0 and members.proj_code=challenges.owner order by $requested_order, challenges.ID limit $limit offset $off"
	if ($type == 3);

#print STDERR "and Here who is $r_user!\n";	
$comm = "select members.ID, challenges.owner, challenges.place, challenges.date_and_time, challenges.condition, members.e_masterst, challenges.ID, challenges.status, challenges.partner, challenges.time_of_selection, challenges.price, challenges.hashed_condition from challenges, members$taddon  
where$sport_and$filter challenges.status = 'f' and challenges.partner = '$r_user' and members.proj_code=challenges.owner order by $requested_order, challenges.ID limit $limit offset $off"
	if ($type == 5);
#print STDERR "And here comm is $comm!\n";

my $city_and = $curr_sport  eq '0' ? '' : " city = '$curr_sport' and";
$comm = "select members.ID, '$r_user', members.k_kredit, members.p_vremya_z, members.d_spec, 1, members.ID, null, null, 
null, members.a_nkname from members where$city_and u_admin = '' order by $requested_order, ID limit $limit offset $off" 
	if ($type == 1);
	
#print STDERR "load_posts: here comm is $comm!\n";

my @output;
&getTable;

my $cntr = 0;
my $ffam = "Tahoma";
my $fs12 = "12px";
my $fs14 = "14px";
my $fs16 = "15px";

for (my $i = 0; $i < $ntuples; $i++) {

my $aa = ${${$listresult}[$i]}[6]; #oid challenges
my $bb = ${${$listresult}[$i]}[0]; #oid members
my $cc = $aa."_".$bb; #combi

my $hide_chal_warn = koitoutf8("Убрать строку?");
my $color_chal_warn = koitoutf8("Выделить цветом?");

my $hide_chal = "[x]" if ($is_admin);	
my $div_hide_mark = "<div id=marker_".$aa." style=\"float:right;background:#faf0f0;padding:2px;font-size:$fs10;font-style:italic;color:#369;\" onclick=\"var yon = window.confirm(\''Really?! $hide_chal_warn\'');if (yon) {hide_record(".$aa.")};\">$hide_chal</div>";
	
$div_hide_mark = '' unless ($is_admin );
	
my $color_chal = "[oOo]" if ($is_admin);	
my $color_mark = "<div id=color_".$aa." style=\"float:right;background:#faf0f0;padding:2px;font-size:$fs10;font-style:italic;color:#369;\" onclick=\"var yon = window.confirm(\''Really?! $color_chal_warn\'');if (yon) {color_record(".$aa.")};\">$color_chal</div>";
$color_mark = '' unless ($is_admin);

my $t1 = "<div style=\"display:inline;margin-left:12px;font-weight:bold;font-family:$ffam;font-size:$fs16;color:#2233ff;line-height:20px;background:transparent;\" onmouseover=\"this.style.color=\''#bbb\'';\" onmouseout=\"this.style.color=\''#2233ff\'';\">".${${$listresult}[$i]}[10]."</div>";
my $t2 = "<div style=\"font-family:$ffam;font-size:$fs14;padding-left:5px;text-align:left;\">".${${$listresult}[$i]}[2]."</div>";	

############### tags categories 
if ($type eq '5' || $type eq '3') {

	my $add_tag_text = koitoutf8("новый тэг");

	$t2 .= "<div class=\"postControlsBottom\"><div class=\"bottomDiv\"><div id=\"tags_2_$aa\" class=\"tags\">";			
					
	$t2 .= &print_tags($aa,$type,2);
	
	my $d = $type eq '3' ? "display:none;" : '';
	
	$t2 .= "</div><span style=\"float:left;margin-right:10px;color:#369;text-decoration:underline;font-size:12px;cursor:pointer;$d\" onclick=\"\$(\''tag_adder_wrapper_2_$aa\'').style.display=\''block\'';\">$add_tag_text</span><div id=tag_adder_wrapper_2_$aa style=\"display:none;\"><div style=\"float:left;margin-left:5px;\"><input type=text id=tag_adder_2_$aa name=tag value=\"\" onfocus=\"this.value=\''\'';\" onblur=\"\$(\''tag_adder_wrapper_2_$aa\'').style.display=\''none\'';\" onkeydown=\"var Ucode=event.keyCode? event.keyCode : event.charCode; if (Ucode == 13) ajax_get_tags($aa,this.value,0,$type,2);\" style=\"width:112px;font-family:$ffam;font-size:12px;padding:3px;\"></div><div style=\"float:left;margin-left:5px;\"><input type=button value=\"+\" onclick=\"ajax_get_tags($aa,\$(\''tag_adder_0_$aa\'').value,0,$type,2);\" style=\"width:24px;font-family:$ffam;font-size:12px;padding:0px 3px 3px 3px;\"></div><div style=\"clear:left;\"></div></div></div><!-- bottomDiv --></div><!-- postControlsBottom -->";
} # my buys
############### end tags date

my $t3 = "<div style=\"font-family:$ffam;font-size:$fs14;color:#024;padding-left:7px;\">".&swap_date(${${$listresult}[$i]}[3],0).", ".&find_weekday(${${$listresult}[$i]}[3],1)."</div>";

############### tags date 
if ($type eq '5' || $type eq '3') { #my buys

	my $add_tag_text = koitoutf8("новый тэг");

	$t3 .= "<div class=\"postControlsBottom\"><div class=\"bottomDiv\"><div id=\"tags_1_$aa\" class=\"tags\">";			
					
	$t3 .= &print_tags($aa,$type,1);
	
	my $d = "display:none;";
	
	$t3 .= "</div><span style=\"float:left;margin-right:10px;color:#369;text-decoration:underline;font-size:12px;cursor:pointer;$d\" onclick=\"\$(\''tag_adder_wrapper_1_$aa\'').style.display=\''block\'';\">$add_tag_text</span><div id=tag_adder_wrapper_1_$aa style=\"display:none;\"><div style=\"float:left;margin-left:5px;\"><input type=text id=tag_adder_1_$aa name=tag value=\"\" onfocus=\"this.value=\''\'';\" onblur=\"\$(\''tag_adder_wrapper_1_$aa\'').style.display=\''none\'';\" onkeydown=\"var Ucode=event.keyCode? event.keyCode : event.charCode; if (Ucode == 13) ajax_get_tags($aa,this.value,0,$type,1);\" style=\"width:112px;font-family:$ffam;font-size:12px;padding:3px;\"></div><div style=\"float:left;margin-left:5px;\"><input type=button value=\"+\" onclick=\"ajax_get_tags($aa,\$(\''tag_adder_0_$aa\'').value,0,$type,1);\" style=\"width:24px;font-family:$ffam;font-size:12px;padding:0px 3px 3px 3px;\"></div><div style=\"clear:left;\"></div></div></div><!-- bottomDiv --></div><!-- postControlsBottom -->";
} # my buys
############### end tags date

my $cond_of_match = &chunk_idiots(${${$listresult}[$i]}[4]);
my $is_winner = $r_user eq ${${$listresult}[$i]}[8] ? 1 : 0;
my $is_loser = (!$is_winner && ${${$listresult}[$i]}[7] eq '0') ? 1 : 0;

my $pokazat = koitoutf8("показать хэш ответа");
my $hp = length(${${$listresult}[$i]}[11]) ? ${${$listresult}[$i]}[11] : "no hash";
#$cond_of_match = "-------------------" unless ($is_admin || $is_winner); #juma
$cond_of_match = "<div class=pokazat data-mBox-tooltip=\"$hp\">$pokazat</div>" unless ($is_admin || $is_winner || $is_loser);
#print STDERR "Here pokazat is $cond_of_match!\n";

my $bg = ($is_winner) ? "#fff" : "transparent";

my $t4 = "<div style=\"font-family:$ffam;font-size:$fs14;text-align:center;border-radius:3px;background:$bg;padding:3px;\">".$cond_of_match."</div>";

############### tags name 
if ($type eq '5' || $type eq '3') { #my buys

	my $add_tag_text = koitoutf8("новый тэг");


	$t4 .= "<div class=\"postControlsBottom\"><div class=\"bottomDiv\"><div id=\"tags_0_$aa\" class=\"tags\">";			
					
	$t4 .= &print_tags($aa,$type,0);
	
	my $d = $type eq '3' ? "display:none;" : '';
	$t4 .= "</div><span style=\"float:left;margin-right:10px;color:#369;text-decoration:underline;font-size:12px;cursor:pointer;$d\" onclick=\"\$(\''tag_adder_wrapper_0_$aa\'').style.display=\''block\'';\">$add_tag_text</span><div id=tag_adder_wrapper_0_$aa style=\"display:none;\"><div style=\"float:left;margin-left:5px;\"><input type=text id=tag_adder_0_$aa name=tag value=\"\" onfocus=\"this.value=\''\'';\" onblur=\"\$(\''tag_adder_wrapper_0_$aa\'').style.display=\''none\'';\" onkeydown=\"var Ucode=event.keyCode? event.keyCode : event.charCode; if (Ucode == 13) ajax_get_tags($aa,this.value,0,$type,0);\" style=\"width:112px;font-family:$ffam;font-size:12px;padding:3px;\"></div><div style=\"float:left;margin-left:5px;\"><input type=button value=\"+\" onclick=\"ajax_get_tags($aa,\$(\''tag_adder_0_$aa\'').value,0,$type,0);\" style=\"width:24px;font-family:$ffam;font-size:12px;padding:0px 3px 3px 3px;\"></div><div style=\"clear:left;\"></div></div></div><!-- bottomDiv --></div><!-- postControlsBottom -->";
} # my buys
############### end tags name

my $sig = 0;
my $stat = 0;
my $new_tips = 1;
my $chunk = '';
	
if (${${$listresult}[$i]}[7] ne '') { #there are candidates, we make a list
	 	
	$stat = 1 if (${${$listresult}[$i]}[7] eq '1');
		
	my $p_string = ${${$listresult}[$i]}[8];

	my @p_array = split(',',$p_string);

	$chunk = koitoutf8("кандидаты")."::";

	$chunk_a = '';
	$num_vars = 0;

	foreach my $pline (@p_array) {
		
		my $changing = "#f0f0a0";
		
		my $hh = &nkname_lookup($pline);

		my $hoid = &oid_lookup($pline,1);			
		
		($pline,my $rest) = split('_',$pline) unless ($pline =~ /^visitatore_/);
				
		my $sel = "select comment from comments where author = '$pline' and match_oid = '$aa'";
		my $res = $dbconn->prepare($sel);
		$res->execute;
		&dBaseError($res, $sel."  (".$res->rows()." rows found)") if ($res->rows() == -2);
		my $listres = $res->fetchall_arrayref;
		my $ntpls = $res->rows();
		my $cmnt = ($ntpls == 1) ? ${${$listres}[0]}[0] : '';
		$cmnt =~ s/\s+/ /g;$cmnt =~ s/^\s$//g;
		
		my $thre_is_cmnt = '';$thre_is_cmnt = "&nbsp;<font color=#369><b><s>C</s></b></font>" if ( $is_admin &&  length($cmnt));
							
				$chunk .= "<div>".$hh;
				$chunk .= $thre_is_cmnt;
				$chunk .= "</div>";
				
				my $if_there_is_tips_then = '';
				$if_there_is_tips_then = " class=tipz title=\"::$cmnt\"" 
					if ($is_admin &&  length($cmnt));
					
					my $js_show_profile = ''; #we dont show profiles for everybody in auctions
											
					#$js_show_profile = " onclick=\"js_show_profile($hoid);\"";

					
					my $bg_high = length($js_show_profile) ? "color:#2233ff;background:$changing;" : '';
					my $js_high = length($js_show_profile) ? "onmouseover=\"this.style.color=\''#bbb\'';\" onmouseout=\"this.style.color=\''#2233ff\'';\"" : '';
					
					$chunk_a .= "<div$if_there_is_tips_then style=\"float:left;display:inline;font-family:$ffam;font-size:$fs12;margin:4px;$bg_high\"$js_show_profile$js_high>".$hh."</div>";
					

     			$num_vars++;
			$sig = 1 if ($pline eq $r_user);#this can't be in dev14 as admins own all chals
     		}


} #status is no null, we make the list of candidates



my $ow = ${${$listresult}[$i]}[1];#owner
my $pa = ${${$listresult}[$i]}[8];#partner
my $st = ${${$listresult}[$i]}[7]; #status
my $price = ${${$listresult}[$i]}[10]; #price

my $gold_cl = "#f5ea74";
$gold_cl = "#def";

my $sta_bg = $st eq '0' ? ($is_admin && length($pa) ? "background:$gold_cl;" : $is_winner ? "background:$gold_cl;" : '') : !$sig && $r_user ne $ow ? '' : !$stat && ($r_user eq ${${$listresult}[$i]}[1]) ? '' : "background:#b2e6c5;";

#START cases of types of ajax_box

my $button_width = "120px";
my $x_screen_offset = ($touch_specific_bro) ? 210 : 240;
my $y_screen_offset = ($touch_specific_bro) ? 210: 270;
my $grey_shado = "-webkit-box-shadow: 1px 1px 3px #ccc;-moz-box-shadow: 1px 1px 3px #ccc;box-shadow: 1px 1px 3px #ccc";

my $l = "var a = (screen.width/2)-$x_screen_offset";
my $m ="var b = (screen.height/2)-$y_screen_offset";

my $t5 = '';


my $adm_addon = '';
if ($is_admin && $st ne '0' && $type eq '0') {
	$adm_addon = "<div>".$div_hide_mark.$color_mark."<div style=\"clear:right;\"></div></div>";
}

if ($st eq '0') {
################################
#challenge status is 0, nothing to do, partner already selected
################################

	#my $o = &oid_lookup($pa,1);#oid only for js_show_profile
	my $sopernik = &nkname_lookup($pa);	

	my $oncl = "onmouseover=\"bsc=this.style.color;this.style.color=\''#bbb\'';\" onmouseout=\"this.style.color=bsc;\"";
	
	if ($is_admin && $type eq '3') {						
		#$sopernik = "<a href=\"?mode=stocksells_panel&tag=$sopernik&tagtable=1\">$sopernik</a>";
		$sopernik = "<a href=\"javascript: function open_tag_link() {tag=\''$sopernik\'';tagtable=1;from_interact=1;r(current_sport,num_open_cha,num_order,$type,tag,1);\$(\''myForm_list_challenges\'').send();}open_tag_link();\">$sopernik</a>";

	}
	$sopernik = '' if $type eq '5';		
	if ($is_winner || $is_admin || $is_loser) {

				$t5 = "<div style=\"margin:3px auto;text-align:center;\"><div style=\"font-weight:bold;font-family:$ffam;color:#69c;font-size:$fs14;\" $oncl>".$sopernik."</div></div>";


	} else {
			my $kuplen = koitoutf8("продано");
			$t5 = "<div style=\"text-align:center;font-size:$fs14;font-family:$ffam;white-space:nowrap;\">>> $kuplen <<</div>";
	}
		
	my $a =  substr(${${$listresult}[$i]}[9],0,16) if (length(${${$listresult}[$i]}[9]));
	$t5 .= "<span style=\"font-size:$fs14;\">".$a."</span>";
	$t5 = "<div style=\"text-align:center;margin:0 auto;width:100%;height:100%;padding:5px;$sta_bg\">".$t5.$adm_addon."</div>";

	
} elsif (!$sig && $r_user ne $ow) {

################################
#in case we are not the owner, & not in list yet, we can subscribe to candidates
################################

#$contest = koitoutf8("согласиться"); #juma
$contest = koitoutf8("купить");
if ($curr_balance >= $price ) {
	#$contest = koitoutf8("купить") if ($price eq '1');#juma
	$t5 = "<div style=\"text-align:center;margin:0 auto;width:100%;height:100%;$sta_bg\"><INPUT TYPE=button style=\"$grey_shado;margin:0px auto;font-family:$ffam;padding:2px 2px 4px 2px;width:$button_width;font-size:$fs12;\" id=ask_$cc VALUE=$contest 
	onclick=\"$l;$m;
		var pos = navigator.userAgent.indexOf(\''MSIE 6\'') > 0 ? \''absolute\'' : \''fixed\'';	
		\$(\''ajax_0\'').setStyles({\''position\'': pos });
		\$(\''ajax_0\'').setStyles({\''left\'': a });	
		\$(\''ajax_0\'').setStyles({\''top\'': b });
		\$(\''ajax_0\'').setStyles({\''display\'': \''block\'' });
		\$(\''ajax_0\'').fade(1);
		\$(\''container_log_ajax_0\'').setStyles({\''display\'': \''block\'' });	
		var log_ajax_0 = \$(\''_ajax_0\'').empty().addClass(\''ajax-loading\'');
		var form = document.createElement(\''form\'');
		form.setAttribute(\''method\'', \''get\'');
		form.setAttribute(\''id\'', \''myForm_0\'');
		document.body.appendChild(form);	
		\$(\''myForm_0\'').action = \''?mode=confirm_yourself_juma&cat=$curr_sport&coid=$aa&member=$bb\'';
		\$(\''myForm_0\'').set(\''send\'', {onComplete: function(response) { 
			check_response(response);
			log_ajax_0.removeClass(\''ajax-loading\'');
			log_ajax_0.set(\''html\'', response);
		}});
		\$(\''myForm_0\'').send();
		\$(\''myForm_0\'').dispose();\">$adm_addon</div>";
} else {
	print "<div style=\"text-align:center;margin:0 auto;width:100%;height:100%;$sta_bg\">LOW BALANCE!!<br>$curr_balance < $price !</div>";
}
} elsif ( !$stat && ($r_user eq ${${$listresult}[$i]}[1])) { 

################################
#IS challenge owner, no candidates
################################

	my $edit_challenge = koitoutf8("редактировать");
	
   unless ($touch_specific_bro) {	   

	$t5 = "<div style=\"text-align:center;margin:0 auto;width:100%;height:100%;$sta_bg\"><INPUT TYPE=button id=ask_$aa style=\"$grey_shado;margin:0px auto;font-family:$ffam;font-size:$fs12;padding:2px 2px 5px 2px;width:$button_width;\" VALUE=$edit_challenge 
	onclick=\"check_my_auth();$l;$m;
	var pos = navigator.userAgent.indexOf(\''MSIE 6\'') > 0 ? \''absolute\'' : \''fixed\'';
		\$(\''ajax_0\'').setStyles({\''position\'': pos });
		\$(\''ajax_0\'').setStyles({\''left\'': a });	
		\$(\''ajax_0\'').setStyles({\''top\'': b });
		\$(\''ajax_0\'').setStyles({\''display\'': \''block\'' });
		\$(\''ajax_0\'').fade(1);
		\$(\''container_log_ajax_0\'').setStyles({\''display\'': \''block\'' });	
		var log_ajax_0 = \$(\''_ajax_0\'').empty().addClass(\''ajax-loading\'');
		var form = document.createElement(\''form\'');
		form.setAttribute(\''method\'', \''get\'');
		form.setAttribute(\''id\'', \''myForm_0\'');
		document.body.appendChild(form);	
		\$(\''myForm_0\'').action = \''?mode=edit_challenge&coid=$aa\'';
		\$(\''myForm_0\'').set(\''send\'', {onComplete: function(response) { 
			check_response(response);
			log_ajax_0.removeClass(\''ajax-loading\'');
			log_ajax_0.set(\''html\'', response);
		}});
		\$(\''myForm_0\'').send();
		\$(\''myForm_0\'').dispose();
		\">$adm_addon</div>";

   } else {
	   	$t5 = "<div style=\"text-align:center;margin:0 auto;width:100%;height:100%;$sta_bg\"><INPUT TYPE=button style=\"width:$button_width;font-size:$fs12;\" 
		onclick=\"location.href=\''?mode=edit_challenge&coid=".$aa."\''\" VALUE=$edit_challenge>$adm_addon</div>";
   }	
} elsif ( $r_user eq ${${$listresult}[$i]}[1]) { 

################################
#owner is selecting candidate
################################
	my $addon = '';	
	my $select_candidate = koitoutf8("выбрать");
	
	if ($is_admin) {

		$k_i = koitoutf8("покупатели");

		$addon = "<br><span style=\"font-size:$fs12;\">$k_i: $num_vars</span>";
		my $h = $aa;

		$addon .= "<div id=\"candidates_$h\" style=\"display:none;margin-right:5px;width:$button_width;font-size:$fs12;\">$chunk_a</div>";
	
		$addon .= &print_variants_in_new_tooltip($chunk,"show_candidates($h);",1);
		
	}
   unless ($touch_specific_bro) {


	$t5 = "<div style=\"text-align:center;margin:0 auto;width:100%;height:100%;$sta_bg\"><INPUT TYPE=button id=ask_$aa style=\"width:$button_width;font-size:$fs16;\" VALUE=$select_candidate 
	onclick=\"check_my_auth();$l;$m;
	var pos = navigator.userAgent.indexOf(\''MSIE 6\'') > 0 ? \''absolute\'' : \''fixed\'';
		\$(\''ajax_0\'').setStyles({\''position\'': pos });
		\$(\''ajax_0\'').setStyles({\''left\'': a });	
		\$(\''ajax_0\'').setStyles({\''top\'': b });
		\$(\''ajax_0\'').setStyles({\''display\'': \''block\'' });
		\$(\''ajax_0\'').fade(1);
		\$(\''container_log_ajax_0\'').setStyles({\''display\'': \''block\'' });	
		var log_ajax_0 = \$(\''_ajax_0\'').empty().addClass(\''ajax-loading\'');
		var form = document.createElement(\''form\'');
		form.setAttribute(\''method\'', \''get\'');
		form.setAttribute(\''id\'', \''myForm_0\'');
		document.body.appendChild(form);	
		\$(\''myForm_0\'').action = \''?mode=select_candidate&coid=$aa&par=0\'';
		\$(\''myForm_0\'').set(\''send\'', {onComplete: function(response) { 
			check_response(response);
			log_ajax_0.removeClass(\''ajax-loading\'');
			log_ajax_0.set(\''html\'', response);
		}});
		\$(\''myForm_0\'').send();
		\$(\''myForm_0\'').dispose();
		\">$addon$adm_addon</div>";
   } else {
	   	$t5 = "<div style=\"text-align:center;margin:0 auto;width:100%;height:100%;$sta_bg\"><INPUT TYPE=button style=\"width:$button_width;font-size:$fs16;\" onclick=\"location.href=\''?mode=select_candidate&par=0&coid=".$aa
		."\''\" VALUE=$select_candidate>$addon$adm_addon</div>";

   }

	
} else { #finally, reject, don't be a candidate any longer

	my $reject = koitoutf8("передумал(а)");
	
	$t5 = "<div style=\"text-align:center;margin:0 auto;width:100%;padding:10px;$sta_bg\"><INPUT TYPE=button id=ask_$cc style=\"width:$button_width;font-size:$fs12;font-family:$ffam;padding:2px 2px 5px 2px;\" VALUE=$reject 
	onclick=\"$l;$m;var pos = navigator.userAgent.indexOf(\''MSIE 6\'') > 0 ? \''absolute\'' : \''fixed\'';
		\$(\''ajax_0\'').setStyles({\''position\'': pos });
		\$(\''ajax_0\'').setStyles({\''left\'': a });	
		\$(\''ajax_0\'').setStyles({\''top\'': b });
		\$(\''ajax_0\'').setStyles({\''display\'': \''block\'' });
		\$(\''ajax_0\'').fade(1);
		\$(\''container_log_ajax_0\'').setStyles({\''display\'': \''block\'' });	
		var log_ajax_0= \$(\''_ajax_0\'').empty().addClass(\''ajax-loading\'');
		var form = document.createElement(\''form\'');
		form.setAttribute(\''method\'', \''get\'');
		form.setAttribute(\''id\'', \''myForm_0\'');
		document.body.appendChild(form);	
		\$(\''myForm_0\'').action = \''?mode=remove_yourself&cat=$curr_sport&coid=$aa&member=$bb\'';
		\$(\''myForm_0\'').set(\''send\'', {onComplete: function(response) { 
			check_response(response);
			log_ajax_0.removeClass(\''ajax-loading\'');
			log_ajax_0.set(\''html\'', response);
		}});
		\$(\''myForm_0\'').send();
		\$(\''myForm_0\'').dispose();
		\">$adm_addon</div>";
	
} #END cases of types of ajax_box

my $comm = "select '$t1' as price,'$t2' as place,'$t3' as active_until,'$t4' as f4,'$t5' as f5";
#print STDERR "Here comm is $comm!\n";
my $sth = $dbconn->prepare($comm);
$sth->execute;

my $ntu = $sth->rows();

while ( my $row = $sth->fetchrow_hashref ){
    push @output, $row;
}
$cntr++;
}

if ($cntr > 0) { my $json_str = encode_json(\@output);utf8::decode($json_str);print $json_str;} 
else {print 0;}

$dbconn->disconnect;

exit;

sub getTable { #16

my $now_time  = time;
my $tt = $now_time - $script_start_time;

print STDERR "Debug: in get table - begin, dbase is $dbase; comm is $comm, time is $tt\n" if ($debug);

	$result=$dbconn->prepare($comm);

    	$result->execute;
	&dBaseError($result, $comm."  (".$result->rows()." rows found)") if ($result->rows() ==
	-2);
	
	$listresult = $result->fetchall_arrayref;
	$ntuples = $result->rows();

my $now_time  = time;
my $tt = $now_time - $script_start_time;

print STDERR "Debug: in get table - end, time is $tt\n" if ($debug);

}

sub dBaseError { #12

    my ($check, $message) = @_;

    my $str = $check->errstr;

    print qq{
    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html; charset=KOI8-R" http-equiv="content-type">
  <title>Ooops</title>
</head>
<body style="padding: 5px; background: rgb(51, 102, 153) none repeat scroll 0%; font-family: Tahoma; font-size: 12px;">
<div style="border: 1px solid rgb(51, 102, 153); margin: 10px; padding: 30px; background: rgb(241, 248, 255) none repeat scroll 0% 50%;$blu_shado;">
    };
    print "Ooops! Some error occured, please be patient!<br>".$str;
    print qq{
<br><br><br>
<span style="font-weight: bold;">$xTER </span><br
 style="font-weight: bold;">
<span style="font-weight: bold;">(C) 2006-2019</span><br>
</div>
</body>
</html>    
    };
    
    die("Action failed on command:$message  Error_was:$DBI::errstr");
}

sub find_weekday { #144

my $td = shift;
my $par = shift;

$td =~ /^(\d+)-(\d+)-(\d+)/;
my $y = $1;
my $m = $2;
my $d = $3;

my $wd = Day_of_Week($y, $m, $d);
$wd = 0 if ($wd eq '7');

@weekday_abbr = ("Sun","Mon","Tue","Wed","Thu","Fri","Sat") unless ($language eq "russian");
@weekday_abbr = (koitoutf8("вс"),koitoutf8("пн"),koitoutf8("вт"),koitoutf8("ср"),koitoutf8("чт"),koitoutf8("пт"),koitoutf8("сб")) if ($language eq "russian");

return $par  ? $weekday_abbr[$wd] : $weekday[$wd];
}

sub swap_date { #260

my $dtm = shift;
my $with_yr = shift;

$dtm =~ /\d\d(\d\d)-(\d\d)-(\d\d)\s(\d\d:\d\d):\d\d/;
return $2."/".$3."<br><b>".$4."</b>&nbsp;MSK" unless ($with_yr);
return $3."/".$2."/".$1 if ($with_yr);

return $dtm;
}

sub koitoutf8 { #26

my $pvdcoderwin=shift;

$pvdcoderwin=~ s/Ё/E/g;
$pvdcoderwin=~ s/ё/e/g;
$pvdcoderwin=~ s/я/я▐/g;
$pvdcoderwin=~ s/п/п©/g;

$pvdcoderwin=~ s/А/п░/g;
$pvdcoderwin=~ s/Б/п▒/g;
$pvdcoderwin=~ s/В/п▓/g;
$pvdcoderwin=~ s/Г/п⌠/g;
$pvdcoderwin=~ s/Д/п■/g;
$pvdcoderwin=~ s/Е/п∙/g;
$pvdcoderwin=~ s/Ж/п√/g;
$pvdcoderwin=~ s/З/п≈/g;
$pvdcoderwin=~ s/И/п≤/g;
$pvdcoderwin=~ s/Й/п≥/g;
$pvdcoderwin=~ s/К/п /g;
$pvdcoderwin=~ s/Л/п⌡/g;
$pvdcoderwin=~ s/М/п°/g;
$pvdcoderwin=~ s/Н/п²/g;
$pvdcoderwin=~ s/О/п·/g;
$pvdcoderwin=~ s/П/п÷/g;
$pvdcoderwin=~ s/Р/п═/g;
$pvdcoderwin=~ s/С/п║/g;
$pvdcoderwin=~ s/Т/п╒/g;
$pvdcoderwin=~ s/У/пё/g;
$pvdcoderwin=~ s/Ф/п╓/g;
$pvdcoderwin=~ s/Х/п╔/g;
$pvdcoderwin=~ s/Ц/п╕/g;
$pvdcoderwin=~ s/Ч/п╖/g;
$pvdcoderwin=~ s/Ш/п╗/g;
$pvdcoderwin=~ s/Щ/п╘/g;
$pvdcoderwin=~ s/Ь/п╛/g;
$pvdcoderwin=~ s/Ы/п╚/g;
$pvdcoderwin=~ s/Ъ/п╙/g;
$pvdcoderwin=~ s/Э/п╜/g;
$pvdcoderwin=~ s/Ю/п╝/g;
$pvdcoderwin=~ s/Я/п╞/g;

$pvdcoderwin=~ s/а/п╟/g;
$pvdcoderwin=~ s/б/п╠/g;
$pvdcoderwin=~ s/в/п╡/g;
$pvdcoderwin=~ s/г/пЁ/g;
$pvdcoderwin=~ s/д/п╢/g;
$pvdcoderwin=~ s/е/п╣/g;
$pvdcoderwin=~ s/ж/п╤/g;
$pvdcoderwin=~ s/з/п╥/g;
$pvdcoderwin=~ s/и/п╦/g;
$pvdcoderwin=~ s/й/п╧/g;
$pvdcoderwin=~ s/к/п╨/g;
$pvdcoderwin=~ s/л/п╩/g;
$pvdcoderwin=~ s/м/п╪/g;
$pvdcoderwin=~ s/н/п╫/g;
$pvdcoderwin=~ s/о/п╬/g;
$pvdcoderwin=~ s/р/я─/g;
$pvdcoderwin=~ s/с/я│/g;
$pvdcoderwin=~ s/т/я┌/g;
$pvdcoderwin=~ s/у/я┐/g;
$pvdcoderwin=~ s/ф/я└/g;
$pvdcoderwin=~ s/х/я┘/g;
$pvdcoderwin=~ s/ц/я├/g;
$pvdcoderwin=~ s/ч/я┤/g;
$pvdcoderwin=~ s/ш/я┬/g;
$pvdcoderwin=~ s/щ/я┴/g;
$pvdcoderwin=~ s/ь/я▄/g;
$pvdcoderwin=~ s/ы/я▀/g;
$pvdcoderwin=~ s/ъ/я┼/g;
$pvdcoderwin=~ s/э/я█/g;
$pvdcoderwin=~ s/ю/я▌/g;

return $pvdcoderwin;
}

sub chunk_idiots { #199

my $ch = shift;

my @l = split(' ',$ch);
my $r = '';

my $ll = 12;
$ll = 23 if ($utf);

foreach my $line (@l) {

	if (length($line) > $ll) {
		my $c = substr($line,0,$ll);
		my $p = substr($line,$ll);
	}
$r .= $line." "
}
chop $r;
$r =~ s/\./\. /g;
$r =~ s/\,/\, /g;
$r =~ s/\(/ \(/g;
$r =~ s/\)/\) /g;
$r =~ s/\)/\) /g;
$r =~ s/\//\/ /g;
$r =~ s/\-/\- /g;

return $r;
}

sub nkname_lookup { #66

my $code = shift;
my $reverse = shift || 0;

	my $co = "select a_nkname from members where proj_code = '$code'";
	$co = "select proj_code from members where a_nkname = '$code'" if ($reverse);

	my $result=$dbconn->prepare($co);
    	$result->execute;
	&dBaseError($result, $co."  (".$result->rows()." rows found)") if ($result->rows() ==
	-2);
	
	my $lr1 = $result->fetchall_arrayref;
	my $ntuples = $result->rows();


	if ($ntuples) {

		my $piece = ${${$lr1}[0]}[0];
		$piece =~ s/"//g;
		
		return $piece;
	} else {
		return $code;
	}

}


sub oid_lookup { #65

my $code = shift;
my $par = shift;

my $comm = "select proj_code from members where ID = '$code'";
$comm = "select ID from members where proj_code = '$code'" if ($par);

my $result=$dbconn->prepare($comm);
$result->execute;
&dBaseError($result, $comm."  (".$result->rows()." rows found)") if ($result->rows() == -2);
	
my $l = $result->fetchall_arrayref;
return ${${$l}[0]}[0];

}

sub print_variants_in_new_tooltip { #71

my ($chunk, $if_real_func, $thirdparm) = @_;

my $addon = $touch_specific_bro ? '' : " class=\"tipz\"";

$html = "<a href=javascript:$if_real_func><img onclick=\"this.style.display=\''none\'';\" src=\"/icon/view_text.png\"$addon title=\"COMMENTS\" align=middle border=0 alt=\"\" width=16 height=16></a>";

$html =~ s/COMMENTS/$chunk/g;

unless ($thirdparm) {
	print $html;
} else {
	return $html;
}

}

sub check_user { #99

my $par = shift || 0;

$comm = "select city, k_kredit from members where proj_code='$r_user'";
&getTable;
return (${${$listresult}[0]}[0],${${$listresult}[0]}[1]);
 
}

sub print_tags { #292

my $o = shift || 0;
my $type = shift || 0;
my $categ = shift || 0;

my $mymode = $type eq '5' ? "stockmybuys_panel" : "stocksells_panel";
my $ret = '';		
		#create table tags (tag text, match_oid oid) with oids;
		$comm = "select tag from tags where match_oid = $o and category = $categ order by ID asc";
		my $sth = $dbconn->prepare($comm);
		$sth->execute;
		my $tags = $sth->fetchall_arrayref;
		my $ntags = $sth->rows();
				
		for (my $j = 0; $j < $ntags; $j++) {
			my $tag = ${${$tags}[$j]}[0];
			my $x = "<span style=\"cursor:pointer;\" onclick=\"var yon = window.confirm(\''$hide_chal_warn\'');if (yon) {ajax_get_tags($o,\''$tag\'',1,$type,$categ);}\">[x]</span> ";
			$x = '' if ( ($j == 0 && $tag =~ /(\d\d\d\d-\d\d-\d\d)/) || $type ne '5' );
			
			$ret .= "<a href=\"javascript: function open_tag_link() {tag=\''$tag\'';tagtable=0;from_interact=1;r(current_sport,num_open_cha,num_order,$type,tag,0);\$(\''myForm_list_challenges\'').send();}open_tag_link();\" class=\"tag\">#$tag</a>$x";

		}
return $ret;		
}
