#!/usr/bin/perl

######################################################################
#
# [	����̾		]	�ɥ�����Ⱥ����ġ��� ver1.0
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
$StdLib 		= "../library/kstd.pl";
$JcodeLib 		= "../library/jcode.pl";
$ThisFile		= $ENV{"SCRIPT_NAME"};
$MainINIFile	= "mdoc.ini";

#---------------------------------------------------------------------

$|=1;

push(@INC,"../library/");

require "$StdLib";		#���ꥸ�ʥ�ɸ��饤�֥������
require "$JcodeLib";	#ʸ���������Ѵ��饤�֥������

&Init_Form("euc");
&Init_Tag;

%INI = {};
%INI = &InitINIData(1,$MainINIFile);

$found = 0;
$fnccnt = 0;
$rfname = "";
%fdata;

#==================================================================================[�ᥤ��롼����]==
#����������������������������������������������������������������������������������������������������
#====================================================================================================

&mdoc("../library/kstd.pl","../doc/");

exit(0);

#====================================================================================[���֥롼����]==
#����������������������������������������������������������������������������������������������������
#====================================================================================================

sub mdoc {

	local($fname,$opath) = @_;
	local($i,$dum,$strhtml,$strfuncsrc,$fdata,@dum,@spath,@fline,@fline2);

	#�ե�����̾�Τߤ���� ---
	@dum = split(/\//,$fname);
	$rfname = $dum[$#dum];
	#print $rfname;

	#�ǥ��쥯�ȥ�����å� ---
	if(!(-d $opath . $rfname)) {
		#&Err001("please create directory...");
		print "creating directory...";
		&CheckAndMakeFile($opath . $rfname,"0777");
	}
	$opath .= $rfname . "/";


	#���顼���� ---
	&Err001("please select the file...") if($fname eq "");

	#�ե������ɤ߹��� ---
	$fdata = &JE(&ReadFileData($fname,3));
	@fline = @fline2 = split(/\n/,$fdata);

	@fnc = grep {
		$_ =~ /sub (.*) {/;
		$_ = $1;
	} @fline2;

	$fnccnt = @fnc;

	for($i = 0;$i <= $#fnc; $i++) {

		#�������δؿ�̾�򥻥å� ---
		$prevfnc = $fnc[$i - 1];
		$nextfnc = $fnc[$i + 1];

		#���ȼ��Υڡ���ʸ����򥻥å� ---
		$prev = "";
		$next = "";
		if($prevfnc ne "") {
			$prev = "<a href='$prevfnc\.html'>���Υڡ���</a><br>";
		}
		if($nextfnc ne "") {
			$next = "<a href='$nextfnc\.html'>���Υڡ���</a><br>";
		}


		#�ؿ��Υ�������ʬ����� ---
		$strfuncsrc = &ConvHTMLTag(&getfuncsource(1,$fnc[$i],*fline));
		$strfuncsrc =~ s/<br>/\n/g;

		#�ؿ������������ ---
		$strfuncctt = &getfunccontent(1,$fnc[$i],*fline);

		#�ºݤ˻ȤäƤ��륽�����Υ���ץ����� ---
		@spath = qw(../sample/no2/ ../sample/no2/lib/ ../sample/no2/lib/admin/ ../sample/no4/ ../sample/no3/ ../sample/no5/ ../sample/no1/);
		$strfuncsample = &ConvHTMLTag(&getfuncsample(1,$fnc[$i],@spath));
		if($strfuncsample ne "") {

			$strfuncsample =~ s/_FR_/<font style='color:#FF0000;font-size:9pt;font-weight:bold;'>/g;
			$strfuncsample =~ s/_FC_/<\/font>/g;

			$strfuncsample = join("","
				<!\-\- �ºݤ˻ȤäƤ��륽�����Υ���ץ� \-\->
				����ץ�
				<table border='0' bgcolor='#000000' cellpadding='5' cellspacing='1'><tr><td bgcolor='#FFFFFF'><pre><font style='font-size:8pt;'>$strfuncsample</font></pre></td></tr></table>
				");
		} else {
			$strfuncsample = "����ץ�ʤ�";
		}

		#�Ϥ��ͼ��� ---
		$strfuncparam = &getfuncparam(1,$fnc[$i],*fline);
		$strfuncparam =~ s/(.\(\w)/<br>$1/g;

		#����ͼ��� ---
		$strfuncreturn = &getfuncreturn(1,$fnc[$i],*fline);


		#����ȥ��룱ʸ������� ---
		$control1 = join("","
			<table border='0' width='100%' style='font-size:11pt;'><tr>
			<td align='left'> $prev$prevfnc </td>
			<td align='right'> $next$nextfnc </td>
			</tr></table>
			");


		$strhtml = join("","
			<html>
			<body>
			<center><font style='font-weight:bold;'>kstd.pl�ޥ˥奢��</font></center>
			$control1
			<hr>
			<font style='font-size:15pt;font-weight:bold'>$fnc[$i]</font> --- $strfuncctt
			<p>
			<table style='font-size:10pt;'><tr><td valign='top'>�Ϥ���</td><td valign='top'>$strfuncparam</td></tr></table>
			<table style='font-size:10pt;'><tr><td valign='top'>�����</td><td valign='top'>$strfuncreturn</td></tr></table>
			<p>
			<!-- ������������ -->
			<table border='0'><tr><td><pre><font style='font-size:8pt;'>$strfuncsrc</font></pre></td></tr></table>

			$strfuncsample

			<hr>
			$control1
			</body>
			</html>
			");

		&RecordFileData($opath . $fnc[$i] . ".html",3,&JS($strhtml),"");
	}

}

#---------------------------------------
#�ؿ��Υ�������ʬ���������
#---------------------------------------
sub getfuncsource {
	local($mode,$fncname,*src) = @_;
	local($i,$j,$strtmp);

	for($i = 0;$i <= $#src; $i++) {
		if($src[$i] =~ /^sub $fncname {/) {
			#print "catch!";
			for($j = $i; $j <= $#src; $j++) {
				#print $src[$j] . "\n";
				$strtmp .= $src[$j] . "\n";
				last if($src[$j] eq "}");
			}
			last;
		}
	}

	return $strtmp;
}

#---------------------------------------
#�ؿ����������������
#---------------------------------------
sub getfunccontent {
	local($mode,$fncname,*src) = @_;
	local($i,$j,$strtmp);

	for($i = 0;$i <= $#src; $i++) {
		if($src[$i] =~ /^# \[Function\t\t\] $fncname/) {
			($strtmp) = $src[$i + 1] =~ /# \[Contents     \] (.*)/;
			$strtmp = &ConvHTMLTag($strtmp);
			last;
		}
	}

	return $strtmp;
}

#---------------------------------------
#�ºݤ˻ȤäƤ��륽�����Υ���ץ�����
#---------------------------------------
sub getfuncsample {
	local($mode,$fncname,@spath) = @_;
	local($i0,$i,$j,$k,$flag,$tmp01,$strtmp,$fdata,@fline,@farray);

	for($i0 = 0;$i0 <= $#spath; $i0++) {

		$spath = $spath[$i0];

		#print $spath . "\n";

		#�ǥ��쥯����Υե������������� ---
		@farray = &GetFileArray(1,$spath);
		@farray = grep { $_ ne $rfname } @farray;

		$flag = 0;
		for($i = 0;$i <= $#farray; $i++) {
			if(-e "$spath$farray[$i]") {
				#print $farray[$i] . " ok...\n";
				if($fdata{$farray[$i]} eq "") {
					$fdata{$farray[$i]} = &ReadFileData($spath . $farray[$i],3);
				}

				@fline = split(/\n/,$fdata{$farray[$i]});

				for($j = 0;$j <= $#fline; $j++) {
					if($fline[$j] =~ /$fncname/) {
						for($k = $j - 5; $k <= $j + 5; $k++) {
							$tmp01 = $fline[$k];
							$tmp01 =~ s/^\t+(.*)/$1/g;
							if($tmp01 =~ /$fncname/) {
								$tmp01 = "_FR_" . $tmp01 . "_FC_";
							}
							$strtmp .=  $tmp01 . "\n";
						}
						#print "sample found... $strtmp\n";

						$strtmp .= "\n\n" . "($farray[$i]�������)";

						$flag = 1;
						last;
					}
				}

				if($flag) {
					print ++$found . "/" . $fnccnt . "\t". $fncname . "\n";
					return $strtmp;
				}
			}
		}
	}

	return "";
}

#---------------------------------------
#����ͼ���
#---------------------------------------
sub getfuncreturn {
	local($mode,$fncname,*src) = @_;
	local($i,$j,$tmp,$strtmp);

	for($i = 0;$i <= $#src; $i++) {
		if($src[$i] =~ /^# \[Function\t\t\] $fncname/) {
			for($j = $i + 3;$j <= $#src; $j++) {
				if($src[$j] =~ /# \[Return       \] (.*)/) {
					$tmp = $src[$j];
					last;
				}
			}
			($strtmp) = $tmp =~ /# \[Return       \] (.*)/;
			$strtmp = &ConvHTMLTag($strtmp);
			last;
		}
	}

	return $strtmp;
}

#---------------------------------------
#�Ϥ��ͼ���
#---------------------------------------
sub getfuncparam {
	local($mode,$fncname,*src) = @_;
	local($i,$j,$tmp01,$strtmp);

	for($i = 0;$i <= $#src; $i++) {
		if($src[$i] =~ /^# \[Function\t\t\] $fncname/) {
			for($j = $i + 4;$j <= $#src; $j++) {
				if($j eq $i + 4) {
					($strtmp) = $src[$j] =~ /# \[Input        \] (.*)/;
				} elsif($src[$j] =~ /#\-\-\-/) {
					$strtmp =~ s/<br>$//g;
					last;
				} else {
					$tmp01 = $src[$j];
					$tmp01 =~ s/^#//g;
					$tmp01 =~ s/^\t+//g;
					$strtmp .= $tmp01;
				}
			}
			last;
		}
	}

	return $strtmp;
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

	print $q . "\n";
	exit(0);
}