#=====================================================================
# [Function		] Init_Form
# [Contents     ] �֥饦������ʸ���������Ѵ�����
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)charcode:�Ѵ�����ʸ��������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub Init_Form {
	local($query, @assocarray, $assoc, $property, $value, $charcode, $method);
		$charcode = $_[0];
		$method = $ENV{'REQUEST_METHOD'};
		$method =~ tr/A-Z/a-z/;

		#-------------------------------
		if($ENV{'CONTENT_TYPE'} =~ /multipart/) {
			&Init_Multipart($charcode);
			return 0;
		}
		#-------------------------------

		if ($method eq 'post') {
			read(STDIN, $query, $ENV{'CONTENT_LENGTH'});
		} else {
	  		$query = $ENV{'QUERY_STRING'};
		}
		@assocarray = split(/&/, $query);
		foreach $assoc (@assocarray) {
			($property, $value) = split(/=/, $assoc);
			$value =~ tr/+/ /;
			$value =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			&jcode'convert(*value, $charcode);
			$value =~ s/\r//g;
			$form{$property} = $value;
	    	}
}

#=====================================================================
# [Function		] Init_Multipart
# [Contents     ] multipart/form-data �Υǡ����� form �˳�Ǽ����
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)charcode:�Ѵ�����ʸ��������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub Init_Multipart {
	local($i,$key,$dum,$boundary,$fname,$formdata,$formhead,$formbody,$charcode,@formdata);

	$charcode = $_[0];

	($dum,$boundary) = $ENV{'CONTENT_TYPE'} =~ /(.*)boundary=(.*)/;
	$formdata .= $_ while(<STDIN>);

	#print &PH;
	#print $formdata;
	#exit(0);
	@formdata = split(/--$boundary/,$formdata);
	#print &Impact("$#formdata<hr>");

	for($i = 0; $i <= $#formdata; $i++) {

		#print "$formdata[$i]<br>";

		if($ENV{"HTTP_HOST"} =~ /www/) {
			($formhead,$formbody) = split(/\r\n\r\n/,$formdata[$i],2);
		} else {
			($formhead,$formbody) = split(/\n\n/,$formdata[$i],2);
		}

		#�ǡ����ե�����ʤ��
		if($formhead =~ /filename/) {

			#&Err001("o");

			($key) = $formhead =~ /name="(.*?)"/;
			($fname) = $formhead =~ /filename="(.*?)"/;
			($dum,$fname) = $fname =~ /(.*)\\(.*)/;


			$formdata{"$key\_fname"} = $fname;
			$formdata{"$key\_fdata"} = $formbody;

			#print "$fred $fname<hr> $formbody $fc";
			#exit(0);
		}
		#�ѿ��ʤ��
		else {
			($key) = $formhead =~ /name="(.*)"/;
			chop($formbody);

			$formbody =~ s/[\r|\n]//g;

			#print "<B>$key = $formbody</b><br>";

			#renovate at ITS 2002/01/21 K.Hamada EUC���Ѵ�����

			$formbody =~ tr/+/ /;
			$formbody =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			&jcode'convert(*formbody, $charcode);
			$formbody =~ s/\r//g;

			$form{$key} = $formbody;
		}
	}



}

#=====================================================================
# [Function		] ReadFileData
# [Contents     ] �ե������ɹ�����
#---------------------------------------------------------------------
# [Return       ] (string or string array)�ե������ʸ����
# [Input        ] (string)fname:�ե�����̾�ʥѥ�ȴ����
#				  (string)way:���ץ����
#						1:ʸ������֤�
#						2:������֤�
#						3:ʸ������֤�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ReadFileData {
	local($fname,$way) = @_;
	local(@strarray,$strline,$strtmp,$DebugPath);

	open(DB,"$fname");
	@strarray = <DB>;
	close(DB);

	if($way eq 1) {
		$strline = join("",@strarray);
		return "$strline";
	} elsif($way eq 2) {
		return @strarray;
	} elsif($way eq 3) {
		$strline = join("",@strarray);
		return "$strline";
	}
}

#=====================================================================
# [Function		] RecordFileData
# [Contents     ] �ե�����������
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)fname:�ե�����̾�ʥѥ�ȴ����
#				  (string)way:���ץ����
#						1:��ʸ��������˲��Ԥ��ղä��ƽ񤭹��� 
#						2:��ʸ��������򤽤Τޤ޽񤭹��� 
#						3:ʸ����򤽤Τޤ޽񤭹��� 
#				  (string)strline:ʸ�����ѿ�
#				  (string array)strArray:ʸ�������� 
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub RecordFileData {
	local($fname,$way,$strline,@strArray) = @_;
	local($strtmp);


	
	if($way eq 1) {
		open(DB,">$fname");
		foreach $strtmp (@strArray) {
			if($strtmp !=~ /\n$/) {
				$strtmp = join("",$strtmp,"\n");
			}
			print DB "$strtmp";	
		}
		close(DB);
	} elsif($way eq 2) {
		open(DB,">$fname");
		$strtmp = join("",@strArray);
		print DB "$strtmp";	
		close(DB);
	} elsif($way eq 3) {
		open(DB,">$fname");
		print DB "$strline";	
		close(DB);
	} elsif($way eq 4) {
		open(DB,">>$fname");
		print DB "$strline";	
		close(DB);
	}

	return;
}

#=====================================================================
# [Function		] GetDateString
# [Contents     ] �����С�������������
#---------------------------------------------------------------------
# [Return       ] (string)datestr:ǯ������ʬ��ʸ����
# [Input        ] �ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub GetDateString {
	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$datestr);
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon++;
		
	if($sec < 10) {$sec = "0$sec";};
	if($min < 10) {$min = "0$min";};
	if($hour < 10) {$hour = "0$hour";};
	if($mday < 10) {$mday = "0$mday";};
	if($mon < 10) {$mon = "0$mon";};
	if($year < 99) {$year = $year + 2000}
	else {$year = $year + 1900;};

	$datestr = "$year:$mon:$mday:$hour:$min:$sec";

	return $datestr;
}

#=====================================================================
# [Function		] PH
# [Contents     ] �إå���ʸ�����������
#---------------------------------------------------------------------
# [Return       ] (string)�ȣԣ̥ͣإå�ʸ����
# [Input        ] �ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub PH {
	return "Content-Type: text/html\n\n";
}

#=====================================================================
# [Function		] MakeRefresh
# [Contents     ] �����ڡ���ʸ�����������
#---------------------------------------------------------------------
# [Return       ] (string)�ȣԣͣ�ʸ����
# [Input        ] (string)url:��������գң̡�http:// ���鵭����
#				  (string)sec:�������������δ֡���$sec��)
#				  (string)str:�ڡ�����ɽ������ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeRefresh {
	local($url,$sec,$str) = @_;
	local($strline);

	$strline = "<html><head><title>�����桦����</title><META HTTP-EQUIV='Content-Type' Content=\"text/html; charset=x-euc-jp\"><META HTTP-EQUIV='Refresh' Content=\"$sec ; url='$url'\"></head><body>$str</body></html>";
	
	return $strline;
}

#=====================================================================
# [Function		] ConvHTMLTag
# [Contents     ] �ȣԣͣ���ʸ�����Ѵ�����
#---------------------------------------------------------------------
# [Return       ] (string)�ȣԣͣ�ʸ����
# [Input        ] (string)strtmp:�Ѵ�����ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConvHTMLTag {
	local($strtmp) = @_;

	$strtmp =~ s/ /\&nbsp;/g;
	$strtmp =~ s/</\&lt;/g;
	$strtmp =~ s/>/\&gt;/g;
	$strtmp =~ s/\r\n/\n/g;
	$strtmp =~ s/\n/<br>/g;
	$strtmp =~ s/<br><br>/<br> <br>/g;
	$strtmp =~ s/_N_/<br>/g;

	return $strtmp;
}

#=====================================================================
# [Function		] ConvDateString
# [Contents     ] ����ʸ�����Ѵ�����
#---------------------------------------------------------------------
# [Return       ] (string)����ʸ����
# [Input        ] (string)strtmp:�Ѵ�����ʸ����
#				  (string)way:���ץ����
#						1:ǯ���������֤�
#						2:ǯ������ʬ���֤�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConvDateString {
	local($strtmp,$way,$sp) = @_;
	local($year,$mon,$date,$hour,$min,$sec);

	$sp = "_" if($sp eq "");

	if($way eq 1) {
		($year,$mon,$date,$hour,$min,$sec) = split(/$sp/,$strtmp);
		return "$yearǯ$mon��$date��$hour��";
	} elsif($way eq 2) {
		($year,$mon,$date,$hour,$min,$sec) = split(/$sp/,$strtmp);
		return "$yearǯ$mon��$date��$hour��$minʬ";
	}
}

#=====================================================================
# [Function		] PrintMETA
# [Contents     ] META����ʸ�����������
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:META����ʸ����
# [Input        ] (string)way:���ץ����
#						euc:charset �� �ţգå����ɤˤ���
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub PrintMETA {
	local($way) = @_;
	local($strtmp);

	if($way eq "euc") {
		$strtmp = q#<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=x-euc-jp">#;
		return $strtmp;
	}
}

#=====================================================================
# [Function		] InitINIData
# [Contents     ] ����ե�������������
#---------------------------------------------------------------------
# [Return       ] (string or hash)
#							1:Ϣ������ 2:ʸ����
# [Input        ] (string)mode:���ץ����
#							1:ɸ��⡼��
#							2:������������ʸ������֤�
#				  (string)fname:�ե�����̾
#				  (string)section:���������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub InitINIData {
	local($mode, $fname, $section) = @_;
	local($i,$strline,$strtmp,$MatchFlag,$StrCurSection,$StrCurKey,$StrCurVal,$StrCurSecKey,@strarray);


	#------------------------
	#	ɸ��⡼��
	#------------------------

	if($mode eq 1) {
		$strline = &ReadFileData($fname, 1);	#����ե�������ɤ߹���
		$strline = &JE($strline);
		$strline =~ s/\r//g;
		@strarray = split(/\n/,$strline);		#���Ԥ��Ȥ˶��ڤ�

		#����ե�����ʸ����� Ϣ������ INIData �˳�Ǽ����롼�ס�--- ���� ---
		for($i = 0; $i <= $#strarray; $i++) {
			#����������������ڤ��ѹ�
			if($strarray[$i] =~ /\[.*\]/) {
				#print "Section:$strarray[$i]<br>\n";	#�ǥХ���
				$strarray[$i] =~ s/(\[|\])//g;		#���̤�Ϥ���
				$StrCurSection = $strarray[$i];		#�����ȥ���������ѿ��γ�Ǽ����
				next;
			#�������ͤΤν����
			} elsif($strarray[$i] =~ /.*=.*/) {
				$strarray[$i] =~ s/(\t|;.*|\/\*.*\*\/)//g;	#���֡����ڡ����������Ȥ�����
				($StrCurKey,$StrCurVal) = split(/=/,$strarray[$i],2);	#�������ͤ�ʬ����
				#print "Key:$StrCurKey Value:$StrCurVal<br>\n";		#�ǥХ���
				$StrCurSecKey = join("",$StrCurSection,"-",$StrCurKey);	#ʸ���� -> "����-��"����
				#print "MainKey:$StrCurSecKey<br>\n";		#�ǥХ���
				$StrCurVal = &TrimL($StrCurVal);	#NEW
				$StrCurVal =~ s/(^"|"$)//g;		#ξ�Ѥ� " �����ä���������
				$INIData{$StrCurSecKey} = $StrCurVal;	#Ϣ������˳�Ǽ����
			}
		}
		#����ե�����ʸ����� Ϣ������ INIData �˳�Ǽ����롼�ס�--- ��λ ---


		#�����ڡ���롼�롢�ͤν����
		#renovate at ITS 2002/01/16 K.Hamada _campaignrule_��_carriagefee_�����Ѳ�ǽ�ˤ���
		$campaignrule = $INIData{"GROBAL-campaign_rule"}	= &ReadFileData("dtf/admin/campaignrule",3);
		$carriagefee = $INIData{"GROBAL-carriage_fee"}	= &ReadFileData("dtf/admin/carriagefee",3);
		$taxfee = $INIData{"GROBAL-tax_fee"} = &ReadFileData("dtf/admin/taxfee",3);

		return %INIData;

	#------------------------
	#	�ȣԣ̥ͣ⡼��
	#------------------------
	} elsif($mode eq 2) {

		$MatchFlag = 0;
		$strtmp = "";

		$strline = &ReadFileData($fname, 1);	#����ե�������ɤ߹���
		$strline = &JE($strline);
		$strline =~ s/\r//g;
		@strarray = split(/\n/,$strline);		#���Ԥ��Ȥ˶��ڤ�


		#����ե�����ʸ����� Ϣ������ INIData �˳�Ǽ����롼�ס�--- ���� ---
		for($i = 0; $i <= $#strarray; $i++) {
			if($MatchFlag eq 0) {
				#����������������ڤ��ѹ�
				if($strarray[$i] =~ /\[.*\]/) {
					#print "Section:$strarray[$i]<br>\n";	#�ǥХ���
					$strarray[$i] =~ s/(\[|\])//g;		#���̤�Ϥ���
					#print "$strarray[$i] $section<br>";	#�ǥХ���
					if($strarray[$i] eq $section) {
						$MatchFlag = 1;
						#print "match";	#�ǥХ���
					}
				}
				
				next;
			} elsif($MatchFlag eq 1) {
				if($strarray[$i] =~ /^\[.*\]/) {
					last;
				} else {
					$strtmp = join("",$strtmp,$strarray[$i],"\n");
				}
			}
		}
		#����ե�����ʸ����� Ϣ������ INIData �˳�Ǽ����롼�ס�--- ��λ ---


		return $strtmp;
	}
}

#=====================================================================
# [Function		] Sprint
# [Contents     ] ������ͥե����ޥå��Ѵ�����
#---------------------------------------------------------------------
# [Return       ] (integer)����
# [Input        ] (string)mode:���ץ����
#							1:ɸ��⡼��
#							2:������������ʸ������֤�
#				  (string)str:�ե�����̾
#				  (string)cmd01:���������
#				  (string)cmd02:���������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub Sprint {
	local($mode,$str,$cmd01,$cmd02) = @_;
	local($Flg,$i,$j,$k,$strtmp,@strarray);

	# �������ʸ����ο����� (�㡧0234 -> 234) 
	if($mode eq 1) {
		#$Flg = 0;
		#$strtmp = "";
		#
		#@strarray = split(//,$str);
		#
		#for($i = 0; $i <= $#strarray; $i++) {
		#	if(($strarray[$i] eq 0) && $Flg eq 0) {
		#	
		#	} else {
		#		$strtmp = join("",$strtmp,$strarray[$i]);
		#		if($Flg eq 0) {
		#			$Flg = 1;
		#		}
		#	}
		#}

		$strtmp = $str + 0;
	}
	# ����ʸ�������ꤷ�����ʸ������Ѵ�
	elsif($mode eq 2) {
		#$j = $cmd01 - length($str);
		#
		#$strtmp = $str;
		#
		#for($i = 1; $i <= $j; $i++) {
		#	$strtmp = join("0","",$strtmp);
		#}

		$strtmp = sprintf("%0$cmd01\d",$str);
	}

	return $strtmp;
}

#=====================================================================
# [Function		] ReadCSVFile
# [Contents     ] �ãӣ֥ե������ɤ߹���
#---------------------------------------------------------------------
# [Return       ] (hash)��ɸϢ������ (0_1,0_2...n_m)
# [Input        ] (string)mode:���ץ����
#							1:Ϣ������˳�Ǽ����
#				  (string)fname:�ե�����̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ReadCSVFile {
	local($mode,$fname) = @_;
	local($i,$j,$k,$strCSVKey,$InValFlag,$strline,@strarray,@chararray);

	if($mode eq 1) {

		$InValFlag = 0;

		$strline = &ReadFileData($fname,1);
		#�ţգä��Ѵ�����
		&jcode'convert(*strline,'euc');

		@strarray = split(/\n/,$strline);
	
		for($i = 0;$i <= $#strarray; $i++) {
			$strarray[$i] =~ s/;.*//g;
			$strarray[$i] =~ s/""/_DBLAP_/g;
			@chararray = split("",$strarray[$i]);

			for($j = 0; $j <= $#chararray; $j++) {
				if($chararray[$j] eq "\"") {
					if($InValFlag eq 0) {
						$InValFlag = 1;
					} elsif($InValFlag eq 1) {
						$InValFlag = 0;
					}
					next;
				} else {
					if($chararray[$j] eq ",") {
						#���ڤꥫ��ޤξ��
						if($InValFlag eq 0) {
						#�ͥ���ޤξ��
						} elsif($InValFlag eq 1) {
							$chararray[$j] =~ s/$chararray[$j]/_VALKAM_/g;
						}
					}
				}
			}

			$strarray[$i] = join("",@chararray);
			$strarray[$i] =~ s/"//g;

			#�ǥХ���
			if($strarray[$i] ne "") {
				#print "$f2<b>$strarray[$i]</b>$fc<br>";
			}


			@valarray = split(/,/,$strarray[$i]);

			for($k = 0;$k <= $#valarray; $k++) {
				$strCSVKey = join("",$i,"_",$k);
				$valarray[$k] =~ s/_DBLAP_/"/g;
				$valarray[$k] =~ s/_VALKAM_/,/g;

				#print "CSVKey : $strCSVKey CSVVal : $valarray[$k]<br>";

				$CSVData{$strCSVKey} = $valarray[$k];
			}

			$strCSVKey = join("","MAX","_",$i);
			$CSVData{$strCSVKey} = $#valarray;
			
		}

		$strCSVKey = "MAXRECORD";
		$CSVData{$strCSVKey} = $#strarray;

		return %CSVData;
	}
}

#=====================================================================
# [Function		] CountChar
# [Contents     ] ����ʸ��������Ƚ���
#---------------------------------------------------------------------
# [Return       ] (integer)���׿�
# [Input        ] (string)mode:���ץ����
#							1:ɸ��
#				  (string)str:õ���Ȥ����ʸ����
#				  (charF)str:������Ȥ���ʸ��
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub CountChar {
	local($mode,$str,$charF) = @_;
	local($i,$cnt,@strarray);

	if($mode eq 1) {
		$cnt = 0;
		@strarray = split(//,$str);

		for($i = 0; $i <= $#strarray; $i++) {
			if($strarray[$i] eq $charF) {
				$cnt++;
			}
		}

		$strtmp = $cnt;
	}

	return $strtmp;
}

#=====================================================================
# [Function		] TrimL
# [Contents     ] Ƭ�ζ����������
#---------------------------------------------------------------------
# [Return       ] (string)�������ʸ����
# [Input        ] (string)strtmp:ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub TrimL {
	local($strtmp) = @_;

	$strtmp =~ s/^\s+//g;

	return $strtmp;
}

#=====================================================================
# [Function		] SandWitch
# [Contents     ] ʸ����Ϥ���
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:ʸ����
# [Input        ] (string)mode:���ץ����
#						1:ɸ��
#				  (string)str:�����ʸ��
#				  (string)substr:ü��ʸ��
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub SandWitch {
	local($mode,$str,$substr) = @_;
	local($strtmp);


	if($mode eq 1) {
		$strtmp = join("",$substr,$str,$substr);
	}

	return $strtmp;
}

#=====================================================================
# [Function		] JE
# [Contents     ] �ţգå������Ѵ�
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:ʸ����
# [Input        ] (string)strtmp:ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub JE {
	local($strtmp) = @_;

	&jcode'convert(*strtmp, 'euc');

	return $strtmp;
}

#=====================================================================
# [Function		] JS
# [Contents     ] �ӣȣɣƣԡݣʣɣӥ������Ѵ�
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:ʸ����
# [Input        ] (string)strtmp:ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub JS {
	local($strtmp) = @_;

	&jcode'convert(*strtmp, 'sjis');

	return $strtmp;
}

#=====================================================================
# [Function		] Init_Tag
# [Contents     ] �ȣԣ̥ͣ����ѿ������
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] �ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub Init_Tag {
	$f1 				= "<font size=\"1\">";
	$f2 				= "<font size=\"2\">";
	$f3 				= "<font size=\"3\">";
	$f4 				= "<font size=\"4\">";
	$f5 				= "<font size=\"5\">";
	$f6 				= "<font size=\"6\">";
	$f7 				= "<font size=\"7\">";
	$f8 				= "<font size=\"8\">";
	$fred  				= "<font color=\"red\">";
	$fpink  			= "<font color=\"pink\">";
	$fblue  			= "<font color=\"blue\">";
	$fwhite  			= "<font color=\"white\">";
	$fblack  			= "<font color=\"black\">";
	$flblue  			= "<font color=\"lblue\">";
	$fb  				= "<b>";
	$fi  				= "<i>";
	$fc  				= "</font>";

	$al  				= "align=\"left\"";
	$ar  				= "align=\"right\"";
	$am  				= "align=\"center\"";
	$ac  				= "align=\"center\"";
	$vab 				= "valign=\"bottom\"";
	$vat 				= "valign=\"top\"";
	$vam 				= "valign=\"middle\"";

	$t					= "<table>";
	$tc 				= "</table>";

	$htdoc				= "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">";

	%wper	= (
		10 => "width=\"10%\"",
		20 => "width=\"20%\"",
		30 => "width=\"30%\"",
		40 => "width=\"40%\"",
		50 => "width=\"50%\"",
		60 => "width=\"60%\"",
		70 => "width=\"70%\"",
		80 => "width=\"80%\"",
		90 => "width=\"90%\"",
		100 => "width=\"100%\""
	);

	%wpix	= (
		10 => "width=\"10\"",
		20 => "width=\"20\"",
		30 => "width=\"30\"",
		40 => "width=\"40\"",
		50 => "width=\"50\"",
		60 => "width=\"60\"",
		70 => "width=\"70\"",
		80 => "width=\"80\"",
		90 => "width=\"90\"",
		100 => "width=\"100\""
	);


	%cp	= (
		0 => "cellpadding=\"0\"",
		1 => "cellpadding=\"1\"",
		2 => "cellpadding=\"2\"",
		3 => "cellpadding=\"3\"",
		4 => "cellpadding=\"4\"",
		5 => "cellpadding=\"5\"",
		6 => "cellpadding=\"6\"",
		7 => "cellpadding=\"7\"",
		8 => "cellpadding=\"8\"",
		9 => "cellpadding=\"9\"",
		10 => "cellpadding=\"10\""
	);

	%cs	= (
		0 => "cellspacing=\"0\"",
		1 => "cellspacing=\"1\"",
		2 => "cellspacing=\"2\"",
		3 => "cellspacing=\"3\"",
		4 => "cellspacing=\"4\"",
		5 => "cellspacing=\"5\"",
		6 => "cellspacing=\"6\"",
		7 => "cellspacing=\"7\"",
		8 => "cellspacing=\"8\"",
		9 => "cellspacing=\"9\"",
		10 => "cellspacing=\"10\""
	);

}

#=====================================================================
# [Function		] MakeCSVHtmlTable
# [Contents     ] CSV��HTML��ɽ������(<table>...)
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (integer)mode:���ץ����
#						1:ɸ��
#				  (hash)csv:CSVϢ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeCSVHtmlTable {
	local($mode,%csv) = @_;
	local($strtmp,$i,$tmp01,$tmp02);

	if($mode eq 1) {
		$strtmp .= "<table border='1'>";
		for($i = 0;$i <= $csv{'MAXRECORD'}; $i++) {
			$tmp01 = join("",MAX,"_",$i);
			$strtmp .= "<tr>";	
			for($j = 0; $j <= $csv{$tmp01}; $j++) {
				$tmp02 = join("",$i,"_",$j);
				$csv{$tmp02} = &ConvHTMLTag($csv{$tmp02});
				$strtmp .= "<td>$csv{$tmp02}</td>";
			}
			$strtmp .= "</tr>";
		}
		$strtmp .= "</table>";
		return $strtmp;
	}
}

#=====================================================================
# [Function		] MakeSelectionBySectionArray
# [Contents     ] ini�ե�����λ��ꥻ������󤫤�select���������
#---------------------------------------------------------------------
# [Return       ] selectʸ����
# [Input        ] (integer)mode:���ץ����
#						1:ɸ��
#				  (string)section:���������
#				  (string)selname:select̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeSelectionBySectionArray {
	local($mode, $section, $selname) = @_;
	local($i,$tmp01,$strtmp);

	if($mode eq 1) {
		for($i = 0;$i <= 1000; $i++) {
			$tmp01 = join("",$section,"-",$i);
			if($INI{$tmp01} eq "") {
				last;
			}
			$strtmp .= "<option value='$i'>$INI{$tmp01}</option>\n";
		}

		$strtmp	= join("","<select name='$selname'>\n",$strtmp,"</select>\n");

		return $strtmp;
	}

}

#=====================================================================
# [Function		] MakeCSVLineFromHash
# [Contents     ] CSVϢ�����󤫤�CSV�Ԥ��������
#---------------------------------------------------------------------
# [Return       ] CSV�ǡ���ʸ����
# [Input        ] (integer)mode:���ץ����
#				  (string)strJ:�ޤޤ��ʸ�� (ɸ��:1_ etc...)
#				  (hash)hash:Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeCSVLineFromHash {
	local($mode, $strJ, %hash) = @_;
	local($i,$strtmp,$strHname,$key,$val,$max_i,@strarray);

	$i = 0;
	$max_i = -1;

	while(($key, $val) = each %hash) {
		if($key =~ /$strJ/) {
			$max_i++;
		}
	}


	for($i = 0; $i <= $max_i; $i++) {
		$strHname = join("",$strJ,$i);
		$hash{$strHname} = &ConvCSVString($hash{$strHname});
		print "$strHname = $hash{$strHname}<br>";
		push(@strarray,$hash{$strHname});
	}


	$strtmp = join(",",@strarray);

	return $strtmp;

}

#=====================================================================
# [Function		] ConvCSVString
# [Contents     ] CSVϢ�����󤫤�CSV�Ԥ��������
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:CSV�Ѵ����1�ǡ���
# [Input        ] (string)strtmp:CSV�Ѵ�����1�ǡ���
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConvCSVString {
	local($strtmp) = @_;

	$strtmp =~ s/"/""/g;
	if($strtmp =~ /,/) {
		$strtmp = &SandWitch(1,$strtmp,"\"");
	}

	$strtmp =~ s/\r\n/\n/g;
	$strtmp =~ s/\n/_N_/g;

	#$strtmp =~ s/&/&amp;/g;
	#$strtmp =~ s/"/&quot;/g;
	#$strtmp =~ s/</&lt;/g;
	#$strtmp =~ s/>/&gt;/g;
	#$strtmp =~ s/,/&#44;/g;

	return $strtmp;
}

#=====================================================================
# [Function		] ConvInputString
# [Contents     ] ��Ԥ����ǡ����ˤʤ뤿���ʸ�����Ѵ��ؿ�
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:�Ѵ�����ʸ����
# [Input        ] (string)strtmp:�Ѵ�����ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConvInputString {
	local($strtmp) = @_;

	$strtmp =~ s/_N_/\n/g;

	return $strtmp;
}

#=====================================================================
# [Function		] UpdateINIFile
# [Contents     ] ����ե�����λ�����ܤ��ͤ򹹿�����
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (integer)mode:���ץ����
#				  (string)fname:�ե�����̾
#				  (string)section:���������
#				  (string)strFkey:����
#				  (string)strCval:��������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub UpdateINIFile {
	local($mode,$fname,$section,$strFkey,$strCval) = @_;
	local($i,$StrCurSection,$strline,@strarray);
	

	$strline = &ReadFileData($fname, 1);	#����ե�������ɤ߹���
	$strline = &JE($strline);
	@strarray = split(/\n/,$strline);		#���Ԥ��Ȥ˶��ڤ�


	for($i = 0; $i <= $#strarray; $i++) {
		#����������������ڤ��ѹ�
		if($strarray[$i] =~ /\[.*\]/) {
			#print "Section:$strarray[$i]<br>\n";	#�ǥХ���
			
			$StrCurSection = $strarray[$i];		#�����ȥ���������ѿ��γ�Ǽ����
			$StrCurSection =~ s/(\[|\])//g;		#���̤�Ϥ���
			next;
		#�������ͤΤν����
		} elsif(($strarray[$i] =~ /^$strFkey/) && ($StrCurSection eq $section)) {
			$strFval = join("",$section,"-",$strFkey);
			$strarray[$i] =~ s/= $INI{$strFval}/= $strCval/g;
		}
	}

	$strline = join("\n",@strarray);
	&jcode'convert(*strline, $INI{'GROBAL-DecodeINITo'});
	&RecordFileData($fname, 3, $strline, @strarray);



}

#=====================================================================
# [Function		] GetFileArray
# [Contents     ] �ե�����������������
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (integer)mode:���ץ����
#						1:������������
#						2:".",".."����������֤Ǽ�������
#						3:�ǥ��쥯�ȥ�Τ߼�������
#				  (string)path:��������ǥ��쥯�ȥ�Υѥ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub GetFileArray {
	local($mode,$path) = @_;
	local($i,$strtmp,@tmparray);

	if($mode eq 1) {
		opendir(DIR,"$path");
		@tmparray = readdir(DIR);
		closedir(DIR);

		return @tmparray;
	} elsif($mode eq 2) {
		opendir(DIR,"$path");
		@tmparray = grep(!/^(\.|\.\.)$/,readdir(DIR));
		closedir(DIR);

		return @tmparray;
	} elsif($mode eq 3) {
		opendir(DIR,"$path");
		@tmparray = grep { (-d "$path$_") && (!/^(\.|\.\.)$/) } readdir(DIR);
		closedir(DIR);

		return @tmparray;
	}
	
}

#=====================================================================
# [Function		] Parapara
# [Contents     ] �ơ��֥�Υꥹ�Ⱥ��������طʿ��򴹴ؿ�
#---------------------------------------------------------------------
# [Return       ] RGBʸ���� (#FFFFF or $color)
# [Input        ] (string)color:��
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub Parapara {

	local($color) = @_;

	if($Parapara_i eq "") {
		$Parapara_i = 1;
	}

	if($Parapara_i eq "1") {
		$color = "#FFFFFF";
		$Parapara_i = "0";
	} else {
		$Parapara_i = "1";		
	}

	return $color;
}

#=====================================================================
# [Function		] StringMatchToArray
# [Contents     ] ������˻��ꤷ��ʸ����������ˤʤ뤫�ɤ���
#---------------------------------------------------------------------
# [Return       ] (boolean): 1=����,0=�ʤ���
# [Input        ] (string)strF:õ��ʸ����
#				  (string array)strarray:����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub StringMatchToArray {

	local($strF,@strarray) = @_;
	local($TMP);


	foreach $TMP (@strarray) {
		if(($TMP eq $strF) && ($strF ne "")) {
			return "1";
		}
	}

	return "0";
}

#=====================================================================
# [Function		] ConvNumMon
# [Contents     ] ����ե��٥åȤη���������η���Ѵ�����
#---------------------------------------------------------------------
# [Return       ] �����η�
# [Input        ] (string)strtmp:�Ѹ�η�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConvNumMon {
	local($strtmp) = @_;

	if($strtmp eq "Jan") {$strtmp = "1";}
	elsif($strtmp eq "Feb") {$strtmp = "2";}
	elsif($strtmp eq "Mar") {$strtmp = "3";}
	elsif($strtmp eq "Apr") {$strtmp = "4";}
	elsif($strtmp eq "May") {$strtmp = "5";}
	elsif($strtmp eq "Jun") {$strtmp = "6";}
	elsif($strtmp eq "Jul") {$strtmp = "7";}
	elsif($strtmp eq "Aug") {$strtmp = "8";}
	elsif($strtmp eq "Sep") {$strtmp = "9";}
	elsif($strtmp eq "Oct") {$strtmp = "10";}
	elsif($strtmp eq "Nov") {$strtmp = "11";}
	elsif($strtmp eq "Dec") {$strtmp = "12";}

	return $strtmp;
}

#=====================================================================
# [Function		] OpenBinaryFileData
# [Contents     ] �Х��ʥ�ǥե������ɤ߹���
#---------------------------------------------------------------------
# [Return       ] �ե�����ǡ���
# [Input        ] (string)fname:�ե�����̾ (�ѥ���ޤ�)
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub OpenBinaryFileData {
	local($fname) = @_;
	local($strline);

	open(BD,$fname);
	while(<BD>) {
		$strline = $strline . $_;
	}
	close(BD);

	return $strline;
}

#=====================================================================
# [Function		] RecordBinaryFileData
# [Contents     ] �Х��ʥ�ǥե�����񤭹���
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)fname:�ե�����̾ (�ѥ���ޤ�)
#				  (string)fdata:�ǡ��� (�Х��ʥ�)
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub RecordBinaryFileData {
	local($fname,$fdata) = @_;

	open(BD,">$fname");
	binmode(BD);
	print BD "$fdata";
	close(BD);

}

#=====================================================================
# [Function		] SaveSTDINData
# [Contents     ] ɸ�����Ϥ�Tmp����¸����
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] �ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub SaveSTDINData {
	open(DB,">Tmp");
	binmode(DB);
	binmode(STDIN);
	while(<STDIN>){
		print DB $_;
	}
	close(DB);
}

#=====================================================================
# [Function		] InitFromString
# [Contents     ] REQUEST_FROM��?�θ�����Ѥ���Ϣ������form���������
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)strtmp:?k=v....ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub InitFromString {

	local($strtmp) = @_;

	($dum,$q) = split(/\?/,$strtmp, 2);
	@qs = split(/&/, $q);
	foreach $tmp (@qs) {
		($k,$v) = split(/=/, $tmp);
		$v =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
		$form{$k} = $v;
	}
}

#=====================================================================
# [Function		] JJ
# [Contents     ] �ʣɣӥ������Ѵ�
#---------------------------------------------------------------------
# [Return       ] (string)�Ѵ�����ʸ��
# [Input        ] (string)strtmp:�Ѵ�����ʸ��
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub JJ {
	local($strtmp) = @_;

	&jcode'convert(*strtmp, 'jis');

	return $strtmp;
}

#=====================================================================
# [Function		] FileTransferVer1
# [Contents     ] Tmp�����Ѥ��ƥե����륢�åץ��ɽ��� 
#					��SaveSTDINData����˸Ƥ�ɬ�פ����롣
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] �ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub FileTransferVer1 {
	#�����ե�����Υ����������¤Ϥ����ο����ǻ���
	return if($ENV{'CONTENT_LENGTH'} > 500000);

	#�ե�����̾���ꥢ
	$filedata='';
	#�إå�����
	open(TMP,"Tmp");

	while(<TMP>){
		#ư����ˤʤ�ͤϲ��Υ����Ȥ�Ϥ����Ƥߤ褦
		#print &PH;
		#print "decode0:$_<br>\n";

		#�ե�����ž����CR+LF�ǽ�λ
		last if($_=~/^\r\n/);

		#-----�äƤ����إå��θ��ˤĤ��Ƥ����������Ф�����λȽ�̤Τ���
		$bound = $_ if($_=~/^--/);

		#�إå����椫��¥ե�����̾����Ф�
		if ($_=~/filename=/i){
			#��Ψ�����Τ�����ɽ��������������ޤ��ɤκ��
			$file =$_;
			@filename=split(/\"/,$file);
			foreach $file (@filename) {
				if ($file =~/\./){$filedata =$file;}
			}
			#��Ψ�����Τ�����ɽ���������������κ�����ե�����̾��Ƚ�̤�.�ǹԤ�
			$file ="test\\$filedata\\test";
			@filename=split(/\\/,$file);
			foreach $file (@filename) {
				if ($file =~/\./){$filedata =$file;}
			}
		}
	}

	#�ե������ž����Ԥ���
	if ($filedata ne ''){
		#print "$filedata��ž����";
		$bound=~s/\r\n//;
		open(DATA,">$datdir$filedata") || print "�����ץ���<br>\n";
		while(<TMP>){
			last if($_=~/^$bound/);
			print DATA $_;
		}
		#print "��λ";
		close (DATA);
		#print "<br>\n";
	}else{
		#print "�ե�����̾�����������Ƥ�<br>\n";
		print &PH;
		print &WmErrMsg("���åץ��ɥ��顼","<h3>�ե�����̾�����Ϥ��Ʋ�����</h3>");
		exit(0);
	}
}

#=====================================================================
# [Function		] GetMaxNumberFromINIHash
# [Contents     ] ����ե�����λ��ꥻ�������κ����ͤ��������
#---------------------------------------------------------------------
# [Return       ] (integer)strtmp:������
# [Input        ] (integer)mode:���ץ����
#				  (string)section:���������
#				  (hash)hash:����ե�����ǡ�����Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub GetMaxNumberFromINIHash {
	local($mode, $section, %hash) = @_;
	local($i,$tmp01,$strtmp);


	if($mode eq 1) {
		for($i = 1;$i <= 1000; $i++) {
			$tmp01 = join("",$section,"-",$i);
			if($hash{$tmp01} eq "") {
				$strtmp = $i - 1;
				last;
			}
		}

		return $strtmp;
	}
}

#=====================================================================
# [Function		] GetArrayFromINIHash
# [Contents     ] ����ե�����λ��ꥻ������������˳�Ǽ����
#---------------------------------------------------------------------
# [Return       ] (string array)tmparray:����
# [Input        ] (integer)mode:���ץ����
#				  (string)section:���������
#				  (hash)hash:����ե�����ǡ�����Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub GetArrayFromINIHash {
	local($mode, $section, %hash) = @_;
	local($i,$tmp01,$strtmp,@tmparray);

	if($mode eq 1) {
		for($i = 1;$i <= 1000; $i++) {
			$tmp01 = join("",$section,"-",$i);
			if($hash{$tmp01} eq "") {
				last;
			} else {
				push(@tmparray,$hash{$tmp01});
			}
		}

		return @tmparray;
	}

}

#=====================================================================
# [Function		] FunnySQL
# [Contents     ] ����ӣѣ�
#---------------------------------------------------------------------
# [Return       ] (string or string array)
# [Input        ] (integer)mode:���ץ����
#				  (string)fname:�ե�����̾ (�ѥ���ޤ�)
#				  (string)lsp:�ԥǡ����ζ��ڤ�
#				  (string)dsp:���ܥǡ����ζ��ڤ�
#				  (string)id:��ˡ�����ID
#				  (string)idx:����������ܤΰ���
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub FunnySQL {
	local($mode,$fname,$lsp,$dsp,$id,$idx) = @_;
	local($i,$strtmp,$fdata,@flines,@dlines,@strarray);


	if($mode eq "1") {
		if($fname eq "") {
			$fdata = $CurFileData;
		} else {
			$fdata = &ReadFileData($fname,1);
		}

		@flines = split(/$lsp/,$fdata);

		for($i = 0; $i <= $#flines; $i++) {
			@dlines = split(/$dsp/,$flines[$i]);
			if($dlines[0] eq $id) {
				$strtmp = $dlines[$idx];
				last;
			}
		}

		return $strtmp;
	}
	elsif($mode eq "2") {
		if($fname eq "") {
			$fdata = $CurFileData;
		} else {
			$fdata = &ReadFileData($fname,1);
		}

		@flines = split(/$lsp/,$fdata);

		for($i = 0; $i <= $#flines; $i++) {
			@dlines = split(/$dsp/,$flines[$i]);
			push(@strarray,$dlines[$idx]);
		}

		return @strarray;
	}


}

#=====================================================================
# [Function		] ConvPrice
# [Contents     ] ���Ѥο�����Ⱦ�Ѥο������Ѵ�����
#---------------------------------------------------------------------
# [Return       ] (integer)strtmp:�Ѵ���������
# [Input        ] (string)strtmp:�Ѵ�����ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConvPrice {
	local($strtmp) = @_;



	$strtmp =~ s/��/1/g;
	$strtmp =~ s/��/2/g;
	$strtmp =~ s/��/3/g;
	$strtmp =~ s/��/4/g;
	$strtmp =~ s/��/5/g;
	$strtmp =~ s/��/6/g;
	$strtmp =~ s/��/7/g;
	$strtmp =~ s/��/8/g;
	$strtmp =~ s/��/9/g;
	$strtmp =~ s/��/0/g;

	$strtmp =~ s/\D//g;	

	if($strtmp eq "") {
		$strtmp = "0";
	}


	return $strtmp;
}

#=====================================================================
# [Function		] MakeHiddenValueWithFilter
# [Contents     ] Ϣ�������<input type=hidden..�˺�������
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:��������ʸ����
# [Input        ] (string)remove:"v:v"�ե����ޥåȤ�hidden�ˤ��ʤ�����
#				  (hash)hash:Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeHiddenValueWithFilter {
	local($remove, %hash,) = @_;
	local($strtmp, $key, $value, $tmp, $rem_flag, @removes);


	@removes = split(/:/, $remove);

	while(($key, $value) = each %hash) {

		$rem_flag = 0;

		foreach $tmp (@removes) {
			if($tmp eq $key) {
				$rem_flag = 1;
				next;
			}
		}

		if($rem_flag ne 1) {
			$strtmp = $strtmp . "<input type=\"hidden\" name=\"$key\" value=\"$value\">\n";
		}
	}


	return $strtmp;
}

#=====================================================================
# [Function		] StockFileData
# [Contents     ] �ɤ߹�����ե������CurFileData�˳��ݤ��Ƥ���
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)fname:�ե�����̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub StockFileData {
	local($fname) = @_;

	$CurFileData = &ReadFileData($fname,1);
}

#=====================================================================
# [Function		] ListArray
# [Contents     ] �����ɽ������
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (integer)mode:���ץ����
#						1:ɸ��
#				  (string array)strarray:����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ListArray {
	local($mode,@strarray) = @_;
	local($strtmp);

	if($mode eq "1") {
		foreach $strtmp (@strarray) {
			print "$strtmp<br>\n";
		}
	}
}

#=====================================================================
# [Function		] CheckAndMakeFile
# [Contents     ] �ե����뤬¸�ߤ��ʤ����Ϻ�������
#---------------------------------------------------------------------
# [Return       ] (boolean):1=���ʤ�,0=���
# [Input        ] (string)fpath:�ե�����ѥ�(�ѥ�+�ե�����̾)
#				  (string)fperm:�ե�����Υѡ��ߥå����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub CheckAndMakeFile {
	local($fpath,$fperm) = @_;

	if(-e $fpath) {
		return "1";
	} else {
		#�ʤ���к��
		mkdir($fpath,$fperm);
		return "0";
	}
}

#=====================================================================
# [Function		] MakeAccountStr
# [Contents     ] ���������ʸ�������
#---------------------------------------------------------------------
# [Return       ] (string)strline:���������ʸ����
# [Input        ] (string)Id:ID
#				  (string)Pwd:PASSWORD
#				  (string)sp:�Ź沽�����ѥ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeAccountStr {

	local($Id,$Pwd,$sp) = @_;
	local($strline,@strarray);


	$Pwd = crypt($Pwd,substr($Pwd,0,2));

	$Id = &ConvCSVString($Id);
	$Pwd = &ConvCSVString($Pwd);
	$strline = join($sp,$Id,$Pwd);

	$strline = crypt($strline,substr($strline,0,2));

	$strline = &ReverseString($strline);

	return $strline;

}

#=====================================================================
# [Function		] ReverseString
# [Contents     ] ʸ�����դˤ���
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:�դˤ���ʸ����
# [Input        ] (string)strtmp:�դ�ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ReverseString {
	local($strtmp) = @_;
	local(@strarray);

	@strarray = split(//,$strtmp);
	@strarray = reverse(@strarray);
	$strtmp = join("",@strarray);

	return $strtmp;
}

#=====================================================================
# [Function		] ConvVal
# [Contents     ] ʸ����ˤ���"_�ѿ�̾_"�򤽤��ѿ�̾���ͤ��Ѵ�����
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:�Ѵ�����ʸ����
# [Input        ] (string)strtmp:�Ѵ�����ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConvVal {
	local($strtmp) = @_;
		$strtmp =~ s/_(\w+)_/${$1}/g;
	return $strtmp;
}


#=====================================================================
# [Function		] URLEncode
# [Contents     ] ʸ�����URL���󥳡��ɤ���
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:���󥳡��ɤ���ʸ����
# [Input        ] (string)strtmp:���󥳡��ɤ���ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub URLEncode {
	local($strtmp) = @_;
	$strtmp =~ s/(\W)/'%'.unpack("H2", $1)/ego;
	return $strtmp;
}

#=====================================================================
# [Function		] URLDecode
# [Contents     ] ʸ�����URL�ǥ����ɤ���
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:�ǥ����ɤ���ʸ����
# [Input        ] (string)strtmp:�ǥ����ɤ���ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub URLDecode {
	local($strtmp) = @_;
	$strtmp =~ s/%([0-9a-f][0-9a-f])/pack("C",hex($1))/egi;
	return $strtmp;
}

#=====================================================================
# [Function		] ListHash
# [Contents     ] Ϣ�������k=v�ˤ�������˳�Ǽ����
#---------------------------------------------------------------------
# [Return       ] (string array)k=v�ե����ޥåȤ�����
# [Input        ] (integer)mode:���ץ����
#				  (hash)hash:Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ListHash {
	local($mode,%hash) = @_;
	local(@strarray);

	if($mode eq "1") {
		while(($k,$v) = each %hash) {
			push(@strarray,"$k=$v");
		}

		return @strarray;
	}

}

#=====================================================================
# [Function		] GetCookie
# [Contents     ] ���å�����%COOKIEϢ������Ǽ������� ->$COOKIE{k-v}
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] �ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub GetCookie {
	local($strtmp,$c,$p,$n,$v,$vn,$vv,@p,@parray);
	$c = $ENV{'HTTP_COOKIE'};
	@parray = split(/;/,$c);
	foreach $p (@parray) {
		($n,$v) = split(/=/,$p);
		$n =~ s/ //g;
		@varray = split(/,/,$v);
		foreach $v (@varray) {
			($vn,$vv) = split(/:/,$v);
			$strtmp = $n . "x" . $vn;
			${$strtmp} = $COOKIE{"$n\-$vn"} = $vv;
		}
	}
}

#=====================================================================
# [Function		] PutCookie
# [Contents     ] ���å�����������
#---------------------------------------------------------------------
# [Return       ] (string):"Set-Cookie..." ��ʸ����
# [Input        ] (string)c_name:���å�����̾��
#				  (string)c_value:���å�������
#				  (string)c_time:��¸�������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub PutCookie {

	local($c_name,$c_value,$c_time) = @_;

	($c_sec,$c_min,$c_hour,$c_mday,$c_mon,$c_year,$c_wday,$c_yday,$c_isdst) = localtime(time + $c_time * 60 * 60);

	$c_year = $c_year + 1900; #���ס� ����� c_year �� "2000" �ˤʤ�
	if ($c_year < 10)  { $c_year = "0$c_year"; }
	if ($c_sec < 10)   { $c_sec  = "0$c_sec";  }
	if ($c_min < 10)   { $c_min  = "0$c_min";  }
	if ($c_hour < 10)  { $c_hour = "0$c_hour"; }
	if ($c_mday < 10)  { $c_mday = "0$c_mday"; }

	#�����������
	@day = qw(		Sun		Mon		Tue		Wed		Thu		Fri		Sat	);
	#���������
	@month = qw(		Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec	);

	#��������
	$c_day = @day[$c_wday];
	#������
	$c_month = @month[$c_mon];

	#����ʸ�������
	$c_expires = "$c_day, $c_mday\-$c_month\-$c_year $c_hour:$c_min:$c_sec GMT";

	#�ͤ��֤�
	return "Set-Cookie: $c_name=$c_value; expires=$c_expires\n";
}

#=====================================================================
# [Function		] GetSpecDateString
# [Contents     ] ������ÿ��������դ��������
#---------------------------------------------------------------------
# [Return       ] (string):key����
# [Input        ] (time)time:time
#				  (string)key:������������̾��
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub GetSpecDateString {
	local($time,$key) = @_;
	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$datestr);

	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
	$mon++;

	if($sec < 10) {$sec = "0$sec";};
	if($min < 10) {$min = "0$min";};
	if($hour < 10) {$hour = "0$hour";};
	if($mday < 10) {$mday = "0$mday";};
	if($mon < 10) {$mon = "0$mon";};
	if($year < 99) {$year = $year + 2000}
	else {$year = $year + 1900;};

	$datestr = "$year:$mon:$mday:$hour:$min:$sec";

	if($key eq "") {
		return $datestr;
	} else {
		return ${$key};
	}
}

#=====================================================================
# [Function		] GetSpecFileInfo
# [Contents     ] �ե����������������
#---------------------------------------------------------------------
# [Return       ] (string):key����
# [Input        ] (string)fpath:�ե�����ѥ�
#				  (string)key:������������̾��
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub GetSpecFileInfo {
	local($fpath,$key) = @_;
	local($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks);

	($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($fpath);

	return ${$key};
}

#=====================================================================
# [Function		] MakeSelectionByStrArray
# [Contents     ] ���󤫤� Select ���������
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:selectʸ����
# [Input        ] (integer)mode:���ץ����
#				  (string)selname:select̾
#				  (string array)strarray:��
#				  (string array)strarray02:���Ф�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeSelectionByStrArray {
	local($mode, $selname, @strarray,@strarray02) = @_;
	local($i,$tmp01,$strtmp);



	if($mode eq 1) {
		for($i = 0;$i <= $#strarray; $i++) {
			if($pselected eq $i) {
				$selected = "selected";
			} else {
				$selected = "";
			}

			$strtmp .= "<option value='$i' $selected>$strarray[$i]</option>\n";
		}

		$strtmp	= join("","<select name='$selname'>\n",$strtmp,"</select>\n");

		return $strtmp;
	}
	elsif($mode eq 2) {

		local($mode, $selname, *strarray,*strarray02) = @_;

		for($i = 0;$i <= $#strarray; $i++) {

			if($pselected eq $strarray[$i]) {
				$selected = "selected";
			} else {
				$selected = "";
			}

			$strtmp .= "<option value='$strarray[$i]' $selected>$strarray02[$i]</option>\n";
		}

		$strtmp	= join("","<select name='$selname'>\n",$strtmp,"</select>\n");

		return $strtmp;
	}

}

#=====================================================================
# [Function		] MakeHashFromStrArray
# [Contents     ] ���󤫤� Hash ���������
#---------------------------------------------------------------------
# [Return       ] (hash)Ϣ������
# [Input        ] (string array)strarray:k=v������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeHashFromStrArray {
	local(@strarray) = @_;
	local($i,$k,$v,%hash);


	for($i = 0; $i <= $#strarray; $i++) {
		($k,$v) = split(/=/,$strarray[$i]);
		$hash{$k} = $v;
	}

	return %hash;
}


#=====================================================================
# [Function		] MakeDateSelection
# [Contents     ] ���դ�selection���������
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:�����ʸ����
# [Input        ] (integer)mode:���ץ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeDateSelection {
	local($mode,$date,$sname) = @_;
	local($y_i,$m_i,$d_i,$y_max,$m_max,$d_max);

	$cur_y = &GetSpecDateString($date,"year");
	$cur_m = &GetSpecDateString($date,"mon");
	$cur_d = &GetSpecDateString($date,"mday");

	$y_max = $cur_y + 1;
	$m_max = 12;
	$d_max = 31;

	if($pselecteddate eq "") {
		$selecteddate = "$cur_y$cur_m$cur_d";
	} else {
		$selecteddate = "$pselecteddate";
	}

	if($mode eq 1) {
		for($y_i = $cur_y; $y_i <= $y_max; $y_i++) {
			for($m_i = 1; $m_i <= $m_max; $m_i++) {
				for($d_i = 1; $d_i <= $d_max; $d_i++) {

					$py = sprintf("%04d",$y_i);
					$pm = sprintf("%02d",$m_i);
					$pd = sprintf("%02d",$d_i);

					if($selecteddate eq "$py$pm$pd") {
						$selected = " selected";
					} else {
						$selected = "";
					}

					$pdate = join("/",$py,$pm,$pd);
					$strtmp .= "<option value=\"$pdate\"$selected>$pdate</option>\n";
				}
			}
		}

		$strtmp = "<select name=\"$sname\"> $strtmp </select>";

		return $strtmp;
	}
}

#=====================================================================
# [Function		] ImportHash
# [Contents     ] Ϣ������򥰥��Х��ѿ��˼�����
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (hash)hash:������Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ImportHash {
	local(*hash) = @_;
	local($k,$v);
	#print &PH;
	while(($k,$v) = each %hash) {
		#�ǥХ���
		#print "$k = $v<br>\n";
		${$k} = $v;
	}
}

#=====================================================================
# [Function		] ExportHash
# [Contents     ] Ϣ������򥳥ԡ�����
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (hash)hash:���ԡ�����Ϣ������
#				  (hash)hash2:���ԡ����Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ExportHash {
	local(*hash,*hash2) = @_;
	local($k,$v);

	#print &PH;
	while(($k,$v) = each %hash) {
		#�ǥХ���
		#print "$k = $v<br>\n";
		$hash2{$k} = $v;
		#print "$k<BR>";
	}
}

#=====================================================================
# [Function		] CheckFileDateAndDelete
# [Contents     ] �ե��������դ��ǧ���ƺ������
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:��٥벽����ʸ����
# [Input        ] (string)mode:���ץ����
#						hour:v���֤����
#				  (string)fpath:�ե�����Υѥ�
#				  (integer)v:�������Ƥ���v���֤ޤǤʤ������ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub CheckFileDateAndDelete {
	local($mode,$fpath,$v) = @_;
	local($ctime,$ftime);

	#���顼����
	if(!(-e $fpath)) {
		return "0";
	}

	if($mode eq "hour") {
		#�ǥХ���
		#print &PH;
		#print &GetSpecDateString(time + $v * 60 * 60); 
		#print "<br>";

		$ctime = time;
		$ftime = &GetSpecFileInfo($fpath,"mtime");

		$ltime = $ctime - $ftime;

		#print &GetSpecDateString($ftime) . "<br>";
		#print &GetSpecDateString($ctime) . "<br>";
		#print $v * 60 * 60 . "<br>";

		if($ltime < $v * 60 * 60) {
			return "0";
		} else {
			unlink $fpath;
			return "1";
		}
	}
}

#=====================================================================
# [Function		] MakeTempLabel
# [Contents     ] ��٥����
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:��٥벽����ʸ����
# [Input        ] (string)strtmp:��٥벽����ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeTempLabel {
	local($strtmp) = @_;

	$strtmp = "<br> <br> <center> $f4<b>$strtmp</b>$fc </center>";

	return $strtmp;
}

#=====================================================================
# [Function		] SortInOne
# [Contents     ] ������ν�ʣ��ʤ���
#---------------------------------------------------------------------
# [Return       ] (string array)tmpArray:��ʣ��ʤ���������
# [Input        ] (string array)strArray:��ʣ��ʤ�������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub SortInOne {
	local(@strArray) = @_;
	local(@tmpArray,$flag,$i,$pcnt,$j);

	$flag = 0;
	# $pcnt = 0;

		for($i = 0; $i <= $#strArray; $i++) {
			$flag = 0;	
			if(@tmpArray eq "") {
				$tmpArray[0] = $strArray[$i];
			} else {
				for($j = 0; $j <= $#tmpArray; $j++) {
					if($strArray[$i] eq $tmpArray[$j]) {
						$flag = 1;
					break;
					}
				}

				if($flag eq 0) {
					$tmpArray[$#tmpArray + 1] = $strArray[$i];
				}
			}
		}

	return @tmpArray;
}

#=====================================================================
# [Function		] KstdSendMail
# [Contents     ] sendmail�ǥ᡼�����������
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)mode:���ץ����
#						1:ɸ��
#						2:ź���դ��᡼�� ($form{'attach1'},$form{'attach_dat1'})
#						3:�ȣԣ̥ͣ᡼�� ($content �� htmlʸ����������)
#				  (string)mailprog:sendmail�Υե�ѥ�(�롼�Ȥ���)
#				  (string)from:�����Ծ���
#				  (string)to:�������
#				  (string)subject:��̾
#				  (string)content:����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub KstdSendMail {
	local($mode,$mailprog,$from,$to,$subject,$content) = @_;

	if($mode eq 1) {

		$content = &JJ($content);

		if($greturnpath ne "") {
			$returnpath = $greturnpath;
		} else {
			$returnpath = $from;
		}

		if(open(MAIL,"| $mailprog -t -oi")) {

			print MAIL "Return-Path: $returnpath\n";
	        print MAIL "Replay-To: $from\n";
			print MAIL "X-Mailer: $from\n";
			print MAIL "To: $to\n";
			print MAIL "From: $from\n";
			print MAIL "Subject: $subject\n";
			print MAIL "Content-Transfer-Encoding: 7bit\n";
			print MAIL "Content-Type: text/plain; charset=ISO-2022-JP\n\n";

			print MAIL "$content";

			print MAIL "\n\n";
			close(MAIL);

		} else {
			#�������顼
			$form{'msg'} = "$f4$fred$fb �����Ǥ��ޤ���Ǥ�����$fc$fc$fc <br><br>";
			$form{'step'} = "";
			&Admin;
			exit(0);
		}
	}
	#ź�եե������դ� -------------
	elsif($mode eq 2) {

		$bdry = int(rand(10000000));

		open(SEND,"|$mailprog $to");
		#FROM
		$return_path = $from;
		$from = "From: $from";
		$from=&mimeencode($from);
		#SUBJECT
		$subject="Subject: $subject";
		$subject=&mimeencode($subject);
		#MSG
		$msg = $content;
		&jcode'convert(*msg,'jis');


		## �إå���������ʬ ------------------------
		print MAIL "Return-Path: $return_path\n";
		print SEND "$from\n";
		print SEND 'MIME-Version: 1.0',"\n";
		print SEND "To: $form{'to'}\n";

		#if($form{'cc'} ne ""){
		#	$cc =&mimeencode($form{'cc'});
		#	print SEND "Cc: $cc\n";
		#}
		#if($form{'bcc'} ne ""){
		#	$bcc =&mimeencode($form{'bcc'});
		#	print SEND "Bcc: $bcc\n";
		#}
		
		print SEND "$subject\n";
		print SEND 'Content-Transfer-Encoding: 7bit'."\n";
		print SEND "Content-Type: multipart/mixed; boundary=\"$bdry\"\n";
		print SEND "\n\n";


		## �ܥǥ���������ʬ -----------------------

		print SEND "--$bdry\n";
		print SEND 'Content-Type: text/plain; charset=ISO-2022-JP'."\n";
		print SEND "\n";
		print SEND "$msg\n";
		print SEND "\n";

		## ź�ս�����ʬ -----------------------

		$attach_name = $form{'attach1'};
		$attach_type = &DetectFileType($form{'attach1'});
		$attach_dat = &EncodeBase64a($form{'attach_dat1'});

		print SEND "--$bdry\n";
		print SEND "Content-Type: $attach_type".'; '."name=\"$attach_name\"\n";
		print SEND 'Content-Disposition: attachment;'."\n";
	 	print SEND " filename=\"$attach_name\"\n";
	 	print SEND 'Content-Transfer-Encoding: base64'."\n";
		print SEND "\n";
		print SEND "$attach_dat";
		print SEND "\n";
		print SEND "--$bdry--\n";
		close SEND;
	}
	#�ȣԣ̥ͣ᡼�� -------------
	elsif($mode eq 3) {

		$content = &JJ($content);

		if($greturnpath ne "") {
			$returnpath = $greturnpath;
		} else {
			$returnpath = $from;
		}

		#SUBJECT
		$subject="Subject: $subject";
		$subject=&mimeencode($subject);


		if(open(MAIL,"| $mailprog -t -oi")) {

			print MAIL "Return-Path: $returnpath\n";
		        print MAIL "Replay-To: $from\n";
			print MAIL "To: $to\n";
			print MAIL "From: $from\n";
			print MAIL "$subject\n";
			print MAIL "Content-Transfer-Encoding: 7bit\n";
			print MAIL "Content-Type: text/html; charset=ISO-2022-JP\n\n";

			print MAIL "$content";

			print MAIL "\n\n";
			close(MAIL);

		} else {
			#�������顼
			$form{'msg'} = "$f4$fred$fb �����Ǥ��ޤ���Ǥ�����$fc$fc$fc <br><br>";
			$form{'step'} = "";
			&Admin;
			exit(0);
		}

	}
}

#=====================================================================
# [Function		] KstdNETxSMTP
# [Contents     ] NET�⥸�塼��ǥ᡼�����������
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)mode:���ץ����
#						1:ɸ��
#				  (string)smtpsrv:smtp�����С�����
#				  (string)from:�����Ծ���
#				  (string)to:�������
#				  (string)subject:��̾
#				  (string)content:����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub KstdNETxSMTP {
	local($mode,$smtpsrv,$from,$to,$subject,$content) = @_;

	if($smtpsrv =~ /(net|com|org)/) {
		($host,$domain) = $smtpsrv =~ /(.*?)\.(.*)/;
	} elsif($smtpsrv =~ /(ne\.jp|co\.jp|or\.jp)/) {
		($host,$domain) = $smtpsrv =~ /(.*?)\.(.*)/;
	}


	if($mode eq 1) {

		$smtp = Net::SMTP->new($smtpsrv,Hello=>$domain) or die "X $host,$domain";

		$smtp->mail($from);
		$smtp->to($to);

		$content = &JJ($content);

		$smtp->data();
		$smtp->datasend("Subject: $subject\n");
		$smtp->datasend("Content-Type: text/plain; charset=ISO-2022-JP\n");
		$smtp->datasend("From:$from\n");
		$smtp->datasend("To:$to\n");
		$smtp->datasend("\n");
		$smtp->datasend("$content\n");

		$smtp->dataend();
		$smtp->quit;
	}
}

#=====================================================================
# [Function		] CheckIsNULLInHashWithFilter
# [Contents     ] Ϣ���������Ǥζ������å�
#---------------------------------------------------------------------
# [Return       ] (integer)1 or 0
# [Input        ] (string array)remove:�����å����ʤ�����
#				  (hash)hash:Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub CheckIsNULLInHashWithFilter {
	local(*remove,*hash) = @_;
	local($k,$v);

	while(($k,$v) = each %hash) {
		if(&StringMatchToArray($k,@remove) ne 1) {
			if($v eq "") {
				$pNULL = $k;
				return 1;
			}
		}
	}

	return 0;
}

#=====================================================================
# [Function		] ConvPriceComma
# [Contents     ] ���ͤ˥���ޤ�Ĥ���
#---------------------------------------------------------------------
# [Return       ] (integer)����ޤĤ��ο���
# [Input        ] (integer)����ޤ�Ĥ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConvPriceComma {
    local($_) = @_;
    1 while s/(.*\d)(\d\d\d)/$1,$2/;
    $_;
}

#=====================================================================
# [Function		] MakeHashFromString
# [Contents     ] ʸ���󤫤�Ϣ��������������
#---------------------------------------------------------------------
# [Return       ] (hash or global variable)1:Ϣ������,2:�����Х��ѿ�
# [Input        ] (integer)mode:���ץ����
#				  (string)strtmp:Ϣ������ե����ޥå�ʸ����
#				  (string)sp:����ڤ�
#				  (string)sp2:�����ڤ�
#				  (string)hn:Ϣ�����������Ȥʤ�̾��
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeHashFromString {

	local($mode,$strtmp,$sp,$sp2,$hn) = @_;
	local($q,$tmp,$k,$v,@qs,%hash);
	
	if($mode eq 1) {
		@qs = split(/$sp/, $strtmp);
		foreach $tmp (@qs) {
			($k,$v) = split(/$sp2/, $tmp);
			$v =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			$hash{$k} = $v;
		}

		return %hash;
	} elsif($mode eq 2) {

		@qs = split(/$sp/, $strtmp);
		foreach $tmp (@qs) {
			($k,$v) = split(/$sp2/, $tmp);
			$v =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			$tmp = $hn . "x" . $k;
			$v =~ s/_N_/\n/g;

			${$tmp} = $v;
		}	
	}

}

#=====================================================================
# [Function		] Round
# [Contents     ] �ͼθ�������
#---------------------------------------------------------------------
# [Return       ] (integer)�ͼθ�����������
# [Input        ] (integer)num:����
#				  (integer)decimals:�ͼθ��������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub Round {
  local($num, $decimals) = @_;
  local($format, $magic);
  $format = '%.' . $decimals . 'f';
  $magic = ($num > 0) ? 0.5 : -0.5;
  sprintf($format, int(($num * (10 ** $decimals)) + $magic) /
                   (10 ** $decimals));
}

#=====================================================================
# [Function		] GetDltDateString
# [Contents     ] ���եե����ޥåȤ��������
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:YYYY/MM/DD
# [Input        ] �ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub GetDltDateString {
	local($strtmp);

	$strtmp = &GetDateString;
	$strtmp =~ s/:/\//g;
	($strtmp,$dum) = $strtmp =~ /(..........)(......)/;

	return $strtmp;

}

#=====================================================================
# [Function		] MaruBatu
# [Contents     ] ����Ƚ��
#---------------------------------------------------------------------
# [Return       ] (integer)q=1���ä����,q=0���ä����
# [Input        ] (integer)q:1��0
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MaruBatu {
	local($q) = @_;

	if($q) {
		return "��";
	} else {
		return "��";
	}
}

#=====================================================================
# [Function		] IchiZero
# [Contents     ] ���ȣ���򴹤���
#---------------------------------------------------------------------
# [Return       ] (integer)q=1���ä���0,q=0���ä���1
# [Input        ] (integer)q:1��0
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub IchiZero {
	local($q) = @_;

	if($q) {
		return "0";
	} else {
		return "1";
	}
}

#=====================================================================
# [Function		] SuffleArray
# [Contents     ] ����򺮤���
#---------------------------------------------------------------------
# [Return       ] (string array)new:����������
# [Input        ] (string array)old:����������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub SuffleArray {
	local(@old) = @_;
	local(@new);


	while (@old) {
		push(@new, splice(@old, int(rand() * $#old), 1));
	}

	return @new;

}

#=====================================================================
# [Function		] DetectFileType
# [Contents     ] �ե����륿����Ƚ��
#---------------------------------------------------------------------
# [Return       ] (string)strline:��ĥ�Ҿ���
# [Input        ] (string)strtmp:�ե�����̾(��ĥ�ҹ���)
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub DetectFileType {
	local($strtmp) = @_;
	local($fname,$fext);

	($fname,$fext) = split(/./,$strtmp);

	if($fext eq 'gif'){
		$strline = 'image/gif';
	}
	elsif(($fext eq 'jpeg') or ($f_type eq 'jpg')){
		$strline = 'image/jpeg';
	}
	elsif($fext eq 'bmp'){
		$strline = 'image/bmp';
	}
	else{
		$strline = 'application/octet-stream';
	}

	return $strline;
}

#=====================================================================
# [Function		] StopWatchVer1
# [Contents     ] ���ȥåץ����å�(version1.0)
#---------------------------------------------------------------------
# [Return       ] (integer)�����ä�����(��)
# [Input        ] (string)flag:�ե饰
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub StopWatchVer1 {

	local($flag) = @_;
	local($strtmp);

	if($flag eq "start") {
		$SW_START = time;
	} elsif($flag eq "stop") {
		$SW_STOP = time;
		$strtmp = $SW_STOP - $SW_START;
		return $strtmp;
	}
	
}

#=====================================================================
# [Function		] ConvCSVtoNormal
# [Contents     ] �ãӣ�ʸ��������ʸ����ˤ�������ˤ����֤�
#---------------------------------------------------------------------
# [Return       ] (string array)strarray:�ǡ�������
# [Input        ] (string)strtmp:CSV���
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConvCSVtoNormal {
	local($strtmp) = @_;
	local($k,$j,$InValFlag,@strarray,@chararray,@valarray);

	$InValFlag = 0;

	$strtmp =~ s/;.*//g;
	$strtmp =~ s/""/_DBLAP_/g;
	@chararray = split("",$strtmp);



	for($j = 0; $j <= $#chararray; $j++) {
		if($chararray[$j] eq "\"") {
			if($InValFlag eq 0) {
				$InValFlag = 1;
			} elsif($InValFlag eq 1) {
				$InValFlag = 0;
			}
			next;
		} else {
			if($chararray[$j] eq ",") {
				#���ڤꥫ��ޤξ��
				if($InValFlag eq 0) {
				#�ͥ���ޤξ��
				} elsif($InValFlag eq 1) {
					$chararray[$j] =~ s/$chararray[$j]/_VALKAM_/g;
				}
			}
		}
	}
	$strtmp = join("",@chararray);
	$strtmp =~ s/"//g;


	#print "<br> ato $strtmp<br>";

	@valarray = split(/,/,$strtmp);
	for($k = 0;$k <= $#valarray; $k++) {
		$valarray[$k] =~ s/_DBLAP_/"/g;
		$valarray[$k] =~ s/_VALKAM_/,/g;
		$strarray[$k] = $valarray[$k];
		#print $strarray[$k] . ":";
	}


	#print "\n<br>test " . @strarray;

	return @strarray;
}

#=====================================================================
# [Function		] Impact
# [Contents     ] ��Ĵʸ�������
#---------------------------------------------------------------------
# [Return       ] (string)ʸ����
# [Input        ] (string)strtmp:��Ĵ����ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub Impact {
	local($strtmp) = @_;

	return "$fred<b> $strtmp </b>$fc";
}

#### #    # ####
#    ##   # #   #
#### # #  # #   #
#    #  # # #   #
#### #   ## ####
1;