#!/usr/bin/perl

use DBI;
#=================================================[½é´ü²½¥ë¡¼¥Á¥ó]====

#¥°¥í¡¼¥Ð¥ëÊÑ¿ô¤Î½é´ü²½
$StdLib 		= "lib/kstd.pl";
$SqlLib 		= "lib/ksql.pl";
$JcodeLib 		= "lib/jcode.pl";
$Glib			= "lib/glib.pl";
$MainINIFile	= "ini/g.ini";
$ThisFile		= $ENV{"SCRIPT_NAME"};

#---------------------------------------------------------------------

$|=1;

# IIS¤Î¾ì¹ç¤Ï@INC¤ËÀäÂÐ¥Ñ¥¹¤ò´Þ¤á¤ë
#push(@INC,"C:/Url/Gurumenet(Renewal)/cgibin");
#push(@INC,"C:/Url/Gurumenet(Renewal)/cgibin/lib/admin");

require "$StdLib";		#¥ª¥ê¥¸¥Ê¥ëÉ¸½à¥é¥¤¥Ö¥é¥ê½é´ü²½
require "$SqlLib";		#£Ó£Ñ£Ì¥é¥¤¥Ö¥é¥ê½é´ü²½
require "$JcodeLib";	#Ê¸»ú¥³¡¼¥ÉÊÑ´¹¥é¥¤¥Ö¥é¥ê½é´ü²½
require "$Glib";		#¥°¥ë¥á¥Í¥Ã¥È¥é¥¤¥Ö¥é¥ê½é´ü²½

&Init_Form("euc");
&Init_Tag;

%INI = {};
%INI = &InitINIData(1,$MainINIFile);

&pInit_SQL;

#&Init_Admin;

$BackToAdmin	= &ConvVal($INI{'GROBAL-BackToAdmin'});

#==================================================================================[¥á¥¤¥ó¥ë¡¼¥Á¥ó]==
#¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú¡ú
#====================================================================================================


$form{'rlib'} = $form{'act'};
$form{'rlib'} = "enter" if($form{'rlib'} eq "");
require "$INI{'LIB-Admin'}$form{'rlib'}.pl";


#£Ó£Ñ£ÌÀÜÂ³ ¢§¢§¢§¢§¢§¢§¢§
&pConnectSQL;


#¥Û¡¼¥ë
if($form{'act'} eq "") {
	&Enter;
} elsif($form{'act'} eq "login") {
	&Login;
} elsif($form{'act'} eq "viewtable") {
	&ViewTable;
} elsif($form{'act'} eq "maketable") {
	&MakeTable;
} elsif($form{'act'} eq "makecsvfile") {
	&MakeCSVFile;
} elsif($form{'act'} eq "menu") {
	&Menu;
} elsif($form{'act'} eq "command") {
	&Command;
}
#Å¹ÊÞ´ÉÍýÊ¬´ô---
 elsif($form{'act'} eq "shop_reg") {
	&Shop_Reg;
} elsif($form{'act'} eq "shop_edit") {
	&Shop_Edit;
} elsif($form{'act'} eq "shop_del") {
	&Shop_Del;
} elsif($form{'act'} eq "shop_view") {
	&Shop_View;
}
#¾¦ÉÊ´ÉÍýÊ¬´ô---
 elsif($form{'act'} eq "goods_reg") {
	&Goods_Reg;
} elsif($form{'act'} eq "goods_edit") {
	&Goods_Edit;
} elsif($form{'act'} eq "goods_del") {
	&Goods_Del;
} elsif($form{'act'} eq "goods_imgup") {
	&Goods_ImgUp;
} elsif($form{'act'} eq "goods_view") {
	&Goods_View;
}
#ÃíÊ¸´ÉÍýÊ¬´ô---
 elsif($form{'act'} eq "order_view") {
	&Order_View;
} elsif($form{'act'} eq "order_del") {
	&Order_Del;
}
#¥«¥Æ¥´¥ê´ÉÍýÊ¬´ô---
 elsif($form{'act'} eq "cat_admin") {
	&Cat_Admin;
}
#·Ç¼¨ÈÄ´ÉÍýÊ¬´ô---
 elsif($form{'act'} eq "bbs_admin") {
	&BBS_Admin;
}
#¥Ð¥Ã¥¯¥¢¥Ã¥×Ê¬´ô---
 elsif($form{'act'} eq "backup") {
	&Backup;
}
#¥Ú¡¼¥¸ºîÀ®Ê¬´ô---
 elsif($form{'act'} eq "make_html") {
	&Make_Html;
}
#¥á¡¼¥ë¥Þ¥¬¥¸¥ó´ÉÍýÊ¬´ô---
 elsif($form{'act'} eq "mag_admin") {
	&Mag_Admin;
}#¾¦ÉÊ¥­¥ã¥ó¥Ú¡¼¥ó´ÉÍýÊ¬´ô---
 elsif($form{'act'} eq "canpaign") {
	&Canpaign;
}#¥á¥ó¥Ð¡¼´ÉÍýÊ¬´ô---
 elsif($form{'act'} eq "member_view") {
	&Member_View;
}
 elsif($form{'act'} eq "member_del") {
	&Member_Del;
}
 elsif($form{'act'} eq "member_edit") {
	&Member_Edit;
} elsif($form{'act'} eq "member_reg") {
	&Member_Reg;
}
#¥á¥ó¥Ð¡¼´ÉÍýÊ¬´ô---
elsif($form{'act'} eq "gmail") {
	&Gmail;
}

#£Ó£Ñ£ÌÀÚÃÇ ¢¥¢¥¢¥¢¥¢¥¢¥¢¥
&DisconnectSQL;

&PB_ADMIN;

exit(0);

#---------------------------------
# ½ÐÎÏ´Ø¿ô
#---------------------------------

sub PB_ADMIN {
	print &PH;
	print &ConvVal(&JE(&ReadFileData("html/admin_header.html",3)));
	print $K;
	print &ConvVal(&JE(&ReadFileData("html/admin_footer.html",3)));
}

#---------------------------------
# ¥¨¥é¡¼´Ø¿ô
#---------------------------------

sub Err002 {

	local($msg) = @_;

	$K = &MakeTempLabel($msg);
	&PB_ADMIN;
	exit(0);

}










sub intcmp { $a <=> $b }