#!/usr/bin/perl

use DBI;
#=================================================[������롼����]====

#�����Х��ѿ��ν����
$StdLib 		= "lib/kstd.pl";
$SqlLib 		= "lib/ksql.pl";
$JcodeLib 		= "lib/jcode.pl";
$Glib			= "lib/glib.pl";
$MainINIFile	= "ini/g.ini";
$ThisFile		= $ENV{"SCRIPT_NAME"};

#---------------------------------------------------------------------

$|=1;

# IIS�ξ���@INC�����Хѥ���ޤ��
#push(@INC,"C:/Url/Gurumenet(Renewal)/cgibin");
#push(@INC,"C:/Url/Gurumenet(Renewal)/cgibin/lib/admin");

require "$StdLib";		#���ꥸ�ʥ�ɸ��饤�֥������
require "$SqlLib";		#�ӣѣ̥饤�֥������
require "$JcodeLib";	#ʸ���������Ѵ��饤�֥������
require "$Glib";		#�����ͥåȥ饤�֥������

&Init_Form("euc");
&Init_Tag;

%INI = {};
%INI = &InitINIData(1,$MainINIFile);

&pInit_SQL;

#&Init_Admin;

$BackToAdmin	= &ConvVal($INI{'GROBAL-BackToAdmin'});

#==================================================================================[�ᥤ��롼����]==
#����������������������������������������������������������������������������������������������������
#====================================================================================================


$form{'rlib'} = $form{'act'};
$form{'rlib'} = "enter" if($form{'rlib'} eq "");
require "$INI{'LIB-Admin'}$form{'rlib'}.pl";


#�ӣѣ���³ ��������������
&pConnectSQL;


#�ۡ���
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
#Ź�޴���ʬ��---
 elsif($form{'act'} eq "shop_reg") {
	&Shop_Reg;
} elsif($form{'act'} eq "shop_edit") {
	&Shop_Edit;
} elsif($form{'act'} eq "shop_del") {
	&Shop_Del;
} elsif($form{'act'} eq "shop_view") {
	&Shop_View;
}
#���ʴ���ʬ��---
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
#��ʸ����ʬ��---
 elsif($form{'act'} eq "order_view") {
	&Order_View;
} elsif($form{'act'} eq "order_del") {
	&Order_Del;
}
#���ƥ������ʬ��---
 elsif($form{'act'} eq "cat_admin") {
	&Cat_Admin;
}
#�Ǽ��Ĵ���ʬ��---
 elsif($form{'act'} eq "bbs_admin") {
	&BBS_Admin;
}
#�Хå����å�ʬ��---
 elsif($form{'act'} eq "backup") {
	&Backup;
}
#�ڡ�������ʬ��---
 elsif($form{'act'} eq "make_html") {
	&Make_Html;
}
#�᡼��ޥ��������ʬ��---
 elsif($form{'act'} eq "mag_admin") {
	&Mag_Admin;
}#���ʥ����ڡ������ʬ��---
 elsif($form{'act'} eq "canpaign") {
	&Canpaign;
}#���С�����ʬ��---
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
#���С�����ʬ��---
elsif($form{'act'} eq "gmail") {
	&Gmail;
}

#�ӣѣ����� ��������������
&DisconnectSQL;

&PB_ADMIN;

exit(0);

#---------------------------------
# ���ϴؿ�
#---------------------------------

sub PB_ADMIN {
	print &PH;
	print &ConvVal(&JE(&ReadFileData("html/admin_header.html",3)));
	print $K;
	print &ConvVal(&JE(&ReadFileData("html/admin_footer.html",3)));
}

#---------------------------------
# ���顼�ؿ�
#---------------------------------

sub Err002 {

	local($msg) = @_;

	$K = &MakeTempLabel($msg);
	&PB_ADMIN;
	exit(0);

}










sub intcmp { $a <=> $b }