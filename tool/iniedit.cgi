#!/usr/bin/perl

######################################################################
#
# [	����̾		]	ini�ե����륨�ǥ��� ver1.0
# [	������		]	���Ĺ���Ϻ
#
# [ ������ˡ	]	�ʲ�����.
#
#   �ʲ��Τ褦�ʥե����ޥåȤ�ini�ե�������������
#   ini�ե�������� iniedit.ini �ǥե�������¸���Ʋ�������
#   ����iniedit.ini�Ϥ��Υץ�����ư�����Τ�ɬ�פ�����ե�����Ǥ���
#
#   ������������������������������
#   [GROBAL]
#   DecodeINITo	= sjis
#   [END]
#   ������������������������������
#
#   �ޤ����Υץ�����ɬ�פʰ������Խ�����ini�ե�����Υե�����̾�Ǥ���
#   ��ư����Ȥ��� iniedit.cgi?inifile=ini�ե�����Υѥ�
#   �����Ϥ��Ƶ�ư���Ʋ�������
#   DecodeINITo = sjis ���Խ���������ե������ʸ�������ɤǤ���
#
# [	ɬ�פʤ��	]	��kstd.pl�١���jcode.pl�� ����iniedit.ini��
#
######################################################################

#=================================================[������롼����]====

#�����Х��ѿ��ν����
$StdLib 		= "lib/kstd.pl";
$JcodeLib 		= "lib/jcode.pl";
$ThisFile		= $ENV{"SCRIPT_NAME"};
$MainINIFile	= "ini/iniedit.ini";

#---------------------------------------------------------------------

$|=1;

push(@INC,"lib");

require "$StdLib";		#���ꥸ�ʥ�ɸ��饤�֥������
require "$JcodeLib";	#ʸ���������Ѵ��饤�֥������

&Init_Form("euc");
&Init_Tag;

%INI = {};
%INI = &InitINIData(1,$MainINIFile);

#==================================================================================[�ᥤ��롼����]==
#����������������������������������������������������������������������������������������������������
#====================================================================================================

&EditINI;

#====================================================================================[���֥롼����]==
#����������������������������������������������������������������������������������������������������
#====================================================================================================

sub EditINI {

	local($i,$strtm);

	if($form{'step'} eq "") {

		#���顼���� --- ��������
		if(!defined($INI{"GROBAL-DecodeINITo"})) {
			&Err001("<h3>GROBAL����������DecodeINITo������ե������ʸ�������ɡˤ����ꤷ�Ʋ�������</h3>");
		}

		$strtmp = &JE(&ReadFileData($form{'inifile'},3));
		$strtmp =~ s/\r//g;
		@strarray = split(/\n/,$strtmp);
		$i_max = $#strarray;

		$tmp01 = &Parapara("#EAEAEA");

		@strarray = grep { $_ ne "" } @strarray;

		#���ǥ��åȥơ��֥�����롼�� ------------- ��������
		for($i = 0; $i <= $i_max; $i++) {

			# [ʸ����] �ǻϤޤäƤ����饻�����������ȸ��ʤ�
			if($strarray[$i] =~ /^\[/) {
				($CurSection) = $strarray[$i] =~ /\[(.*)\]/;
				push(@secarray,$CurSection);
				$strhtml .= "<tr bgcolor=\"pink\"><td colspan=\"2\">$CurSection</td></tr>\n";
			}
			# "k = v" �ξ�� ---
			elsif($strarray[$i] =~ /((\w|\d)+)((\t|\s)+)=(\t|\s)(.*)/) {

				$tmp01 = &Parapara("#EAEAEA");

				($CurKey,$dum,$dum,,$dum,$dum,$CurVal) = $strarray[$i] =~ /((\w|\d)+)((\t|\s)+)=(\t|\s)(.*)/;
				#print "$CurKey + $CurVal<BR>";
				$CurVal =~ s/"/&quot;/g;
				$strhtml .= "<tr bgcolor=\"$tmp01\"><td>$CurKey </td><td> <input type=\"text\" name=\"$CurSection\XXX$CurKey\" value=\"$CurVal\"></td></tr>\n";
				push(@hiddenarray,"<input type=\"hidden\" name=\"o$CurSection\XXX$CurKey\" value=\"$CurVal\">\n");

			}
			# str �ξ�� ---
			elsif($strarray[$i] =~ /(.*)/ and $strarray[$i + 1] =~ /(.*)/ and $strarray[$i] ne "") {

				$tmp01 = &Parapara("#EAEAEA");

				($ctt,$dum) = $strtmp =~ /\[$CurSection\]\n(.*?)(\n\[.*\])/s;
				$strhtml .= "<tr bgcolor=\"$tmp01\"><td colspan=\"2\"> <textarea name=\"STR_$CurSection\" rows=\"5\" cols=\"50\">$ctt</textarea> <a href=\"$ThisFile?act=editini\&step=delstr\&sec=$CurSection\&inifile=$form{'inifile'}\">���</a> </td></tr>\n";

				for($i; $i <= $i_max; $i++) {
					if($strarray[$i + 1] =~ /^\[/) {
						last;
					}
				}
			}
		}
		#���ǥ��åȥơ��֥�����롼�� ------------- �����ޤ�

		#����Selection ʸ�������
		$secsel = &MakeSelectionByStrArray(2,"targetsec",*secarray,*secarray);

		$msg = join("","

			<h3>����ե����륨�ǥ���</h3>

			<hr>

			<form action=\"$ThisFile\" method=\"post\">
			<table border=\"0\" $cp{'3'} width=\"80%\">
			$strhtml
			</table>
			<p>
			<input type=\"submit\" value=\"���ϣˡ�\">
			<input type=\"hidden\" name=\"act\" value=\"editini\">
			<input type=\"hidden\" name=\"step\" value=\"2\">
			<input type=\"hidden\" name=\"inifile\" value=\"$form{'inifile'}\">

			@hiddenarray

			</form>



			<form action=\"$ThisFile\" method=\"post\">
			<b>�����κ���</b> <BR>
			$secsel �� ������<input type=\"text\" name=\"newkey\" value=\"\"> �͡�<input type=\"text\" name=\"newval\" value=\"\"> ���ɲ� <input type=\"submit\" value=\"����\">��
			<input type=\"hidden\" name=\"act\" value=\"editini\">
			<input type=\"hidden\" name=\"step\" value=\"addkey\">
			<input type=\"hidden\" name=\"inifile\" value=\"$form{'inifile'}\">
			</form>

			<form action=\"$ThisFile\" method=\"post\">
			<b>ʸ�Ϥκ���</b> <BR>
			������<BR>
			<input type=\"text\" name=\"newkey\" value=\"\"> <BR>
			�͡�<BR>
			<textarea name=\"newval\" rows=\"5\" cols=\"50\"></textarea> <BR>
			<input type=\"submit\" value=\"�����¹�\">
			<input type=\"hidden\" name=\"act\" value=\"editini\">
			<input type=\"hidden\" name=\"act\" value=\"editini\">
			<input type=\"hidden\" name=\"step\" value=\"addstr\">
			<input type=\"hidden\" name=\"inifile\" value=\"$form{'inifile'}\">
			</form>


			<hr>
			<a href=\"$ThisFile?act=editini\&inifile=$form{'inifile'}\">����</a>

			");

		$form{'PageSrc'} = "html/blank.html";
		&PB;
		exit(0);

	}
	elsif($form{'step'} eq "2") {

		#print &PH;
		#&ListArray(1,&ListHash(1,%form));

		@updatearray = grep { /XXX/ } keys(%form);
		@update2array = grep { /STR_/ } keys(%form);

		#&Err001("@update2array");

		# k = v ���� ------------ ��������
		$i_max = $#updatearray;
		for($i = 0; $i <= $i_max; $i++) {
			($sec,$key) = split(/XXX/,$updatearray[$i]);
			&WmUpdateINIFile(1,$form{'inifile'},$sec,$key,$form{"o$updatearray[$i]"},$form{"$updatearray[$i]"});
		}

		# str ���� ------------ ��������
		$i_max = $#update2array;
		for($i = 0; $i <= $i_max; $i++) {
			($dum,$sec) = split(/_/,$update2array[$i]);

			$form{"$update2array[$i]"} =~ s/\r//g;

			$strtmp = &JE(&ReadFileData($form{'inifile'},3));
			$strtmp =~ s/\r//g;

			$strtmp =~ s/(\[$sec\]\n)(.*?)(\n\[(.*)\])/$1$form{"$update2array[$i]"}$3/sg; #�ͤκǸ�˲��Ԥ������

			#&Err001($strtmp);

			&jcode'convert(*strtmp, $INI{'GROBAL-DecodeINITo'});
			&RecordFileData("$form{'inifile'}", 3, $strtmp);
			#sleep 1;
		}

		$msg = "$form{'inifile'} �򹹿����ޤ�����<p> <a href=\"$ThisFile\">$BBSTitle</a> <a href=\"$ThisFile?act=editini\&inifile=$form{'inifile'}\">����</a>";
		$form{'PageSrc'} = $BaseHTML;
		&PB;
		exit(0);

	}
	elsif($form{'step'} eq "addkey") {

		$strtmp = &JE(&ReadFileData($form{'inifile'},3));
		$strtmp =~ s/\r//g;

		$strtmp =~ s/(\[$form{'targetsec'}\]\n)/$1$form{'newkey'}\t= $form{'newval'}\n/g;

		&jcode'convert(*strtmp, $INI{'GROBAL-DecodeINITo'});
		&RecordFileData($form{'inifile'}, 3, $strtmp);

		$form{'step'} = "";
		&EditINI;

	}
	elsif($form{'step'} eq "addstr") {

		$form{'newval'} =~ s/\r//g;


		$strtmp = &JE(&ReadFileData($form{'inifile'},3));
		$strtmp =~ s/\r//g;

		$strtmp =~ s/(\n\[END\])/\n\[$form{'newkey'}\]\n$form{'newval'}$1/g;

		&jcode'convert(*strtmp, $INI{'GROBAL-DecodeINITo'});
		&RecordFileData("$form{'inifile'}", 3, $strtmp);



		$form{'step'} = "";
		&EditINI;

	}
	elsif($form{'step'} eq "delstr") {


		$strtmp = &JE(&ReadFileData($form{'inifile'},3));
		$strtmp =~ s/\r//g;

		$strtmp =~ s/(\[$form{'sec'}\]\n)(.*?)\n(\[(.*)\])/$3/sg;

		&jcode'convert(*strtmp, $INI{'GROBAL-DecodeINITo'});
		&RecordFileData("$form{'inifile'}", 3, $strtmp);

		$form{'step'} = "";
		&EditINI;

	}
}

#====================================================================================[�饤�֥��]====
#����������������������������������������������������������������������������������������������������
#====================================================================================================

sub PB {
	print &PH;
	$from{'msg'} = &ConvVal(&JE(&ReadFileData($form{'PageSrc'},3)));
	print &JS($from{'msg'});
	exit(0);
}


sub Err001 {
	local($q) = @_;

	$msg = $q;
	$form{'PageSrc'} = "html/blank.html";
	&PB;
	exit(0);
}