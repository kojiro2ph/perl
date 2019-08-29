#=====================================================================
# [Function		] Init_Form
# [Contents     ] ブラウザ引数文字コード変換処理
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)charcode:変換する文字コード
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] multipart/form-data のデータを form に格納する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)charcode:変換する文字コード
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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

		#データファイルならば
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
		#変数ならば
		else {
			($key) = $formhead =~ /name="(.*)"/;
			chop($formbody);

			$formbody =~ s/[\r|\n]//g;

			#print "<B>$key = $formbody</b><br>";

			#renovate at ITS 2002/01/21 K.Hamada EUCに変換する

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
# [Contents     ] ファイル読込処理
#---------------------------------------------------------------------
# [Return       ] (string or string array)ファイルの文字列
# [Input        ] (string)fname:ファイル名（パス抜き）
#				  (string)way:オプション
#						1:文字列で返す
#						2:配列で返す
#						3:文字列で返す
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ファイル書込処理
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)fname:ファイル名（パス抜き）
#				  (string)way:オプション
#						1:各文字列配列に改行を付加して書き込む 
#						2:各文字列配列をそのまま書き込む 
#						3:文字列をそのまま書き込む 
#				  (string)strline:文字列変数
#				  (string array)strArray:文字列配列 
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] サーバー時刻を取得する
#---------------------------------------------------------------------
# [Return       ] (string)datestr:年月日時分秒文字列
# [Input        ] なし
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ヘッダー文字列作成処理
#---------------------------------------------------------------------
# [Return       ] (string)ＨＴＭＬヘッダ文字列
# [Input        ] なし
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub PH {
	return "Content-Type: text/html\n\n";
}

#=====================================================================
# [Function		] MakeRefresh
# [Contents     ] 更新ページ文字列作成処理
#---------------------------------------------------------------------
# [Return       ] (string)ＨＴＭＬ文字列
# [Input        ] (string)url:ジャンプ先ＵＲＬ（http:// から記入）
#				  (string)sec:更新アクションの間　（$sec秒)
#				  (string)str:ページに表示する文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub MakeRefresh {
	local($url,$sec,$str) = @_;
	local($strline);

	$strline = "<html><head><title>更新中・・・</title><META HTTP-EQUIV='Content-Type' Content=\"text/html; charset=x-euc-jp\"><META HTTP-EQUIV='Refresh' Content=\"$sec ; url='$url'\"></head><body>$str</body></html>";
	
	return $strline;
}

#=====================================================================
# [Function		] ConvHTMLTag
# [Contents     ] ＨＴＭＬ用文字列変換処理
#---------------------------------------------------------------------
# [Return       ] (string)ＨＴＭＬ文字列
# [Input        ] (string)strtmp:変換する文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 時刻文字列変換処理
#---------------------------------------------------------------------
# [Return       ] (string)時刻文字列
# [Input        ] (string)strtmp:変換する文字列
#				  (string)way:オプション
#						1:年月日時で返す
#						2:年月日時分で返す
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ConvDateString {
	local($strtmp,$way,$sp) = @_;
	local($year,$mon,$date,$hour,$min,$sec);

	$sp = "_" if($sp eq "");

	if($way eq 1) {
		($year,$mon,$date,$hour,$min,$sec) = split(/$sp/,$strtmp);
		return "$year年$mon月$date日$hour時";
	} elsif($way eq 2) {
		($year,$mon,$date,$hour,$min,$sec) = split(/$sp/,$strtmp);
		return "$year年$mon月$date日$hour時$min分";
	}
}

#=====================================================================
# [Function		] PrintMETA
# [Contents     ] METAタグ文字列作成処理
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:METAタグ文字列
# [Input        ] (string)way:オプション
#						euc:charset を ＥＵＣコードにする
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 設定ファイル初期化処理
#---------------------------------------------------------------------
# [Return       ] (string or hash)
#							1:連想配列 2:文字列
# [Input        ] (string)mode:オプション
#							1:標準モード
#							2:セクション内の文字列を返す
#				  (string)fname:ファイル名
#				  (string)section:セクション
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub InitINIData {
	local($mode, $fname, $section) = @_;
	local($i,$strline,$strtmp,$MatchFlag,$StrCurSection,$StrCurKey,$StrCurVal,$StrCurSecKey,@strarray);


	#------------------------
	#	標準モード
	#------------------------

	if($mode eq 1) {
		$strline = &ReadFileData($fname, 1);	#設定ファイルの読み込み
		$strline = &JE($strline);
		$strline =~ s/\r//g;
		@strarray = split(/\n/,$strline);		#改行ごとに区切る

		#設定ファイル文字列を 連想配列 INIData に格納するループ　--- 開始 ---
		for($i = 0; $i <= $#strarray; $i++) {
			#セクション初期化・及び変更
			if($strarray[$i] =~ /\[.*\]/) {
				#print "Section:$strarray[$i]<br>\n";	#デバグ用
				$strarray[$i] =~ s/(\[|\])//g;		#中括弧をはずす
				$StrCurSection = $strarray[$i];		#カレントセクション変数の格納する
				next;
			#キーと値のの初期化
			} elsif($strarray[$i] =~ /.*=.*/) {
				$strarray[$i] =~ s/(\t|;.*|\/\*.*\*\/)//g;	#タブ・スペース・コメントを除去する
				($StrCurKey,$StrCurVal) = split(/=/,$strarray[$i],2);	#キーと値に分ける
				#print "Key:$StrCurKey Value:$StrCurVal<br>\n";		#デバグ用
				$StrCurSecKey = join("",$StrCurSection,"-",$StrCurKey);	#文字列 -> "キー-値"を作る
				#print "MainKey:$StrCurSecKey<br>\n";		#デバグ用
				$StrCurVal = &TrimL($StrCurVal);	#NEW
				$StrCurVal =~ s/(^"|"$)//g;		#両恥に " があった場合取り除く
				$INIData{$StrCurSecKey} = $StrCurVal;	#連想配列に格納する
			}
		}
		#設定ファイル文字列を 連想配列 INIData に格納するループ　--- 終了 ---


		#キャンペーンルール、値の初期化
		#renovate at ITS 2002/01/16 K.Hamada _campaignrule_と_carriagefee_を利用可能にする
		$campaignrule = $INIData{"GROBAL-campaign_rule"}	= &ReadFileData("dtf/admin/campaignrule",3);
		$carriagefee = $INIData{"GROBAL-carriage_fee"}	= &ReadFileData("dtf/admin/carriagefee",3);
		$taxfee = $INIData{"GROBAL-tax_fee"} = &ReadFileData("dtf/admin/taxfee",3);

		return %INIData;

	#------------------------
	#	ＨＴＭＬモード
	#------------------------
	} elsif($mode eq 2) {

		$MatchFlag = 0;
		$strtmp = "";

		$strline = &ReadFileData($fname, 1);	#設定ファイルの読み込み
		$strline = &JE($strline);
		$strline =~ s/\r//g;
		@strarray = split(/\n/,$strline);		#改行ごとに区切る


		#設定ファイル文字列を 連想配列 INIData に格納するループ　--- 開始 ---
		for($i = 0; $i <= $#strarray; $i++) {
			if($MatchFlag eq 0) {
				#セクション初期化・及び変更
				if($strarray[$i] =~ /\[.*\]/) {
					#print "Section:$strarray[$i]<br>\n";	#デバグ用
					$strarray[$i] =~ s/(\[|\])//g;		#中括弧をはずす
					#print "$strarray[$i] $section<br>";	#デバグ用
					if($strarray[$i] eq $section) {
						$MatchFlag = 1;
						#print "match";	#デバグ用
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
		#設定ファイル文字列を 連想配列 INIData に格納するループ　--- 終了 ---


		return $strtmp;
	}
}

#=====================================================================
# [Function		] Sprint
# [Contents     ] 指定数値フォーマット変換処理
#---------------------------------------------------------------------
# [Return       ] (integer)数字
# [Input        ] (string)mode:オプション
#							1:標準モード
#							2:セクション内の文字列を返す
#				  (string)str:ファイル名
#				  (string)cmd01:セクション
#				  (string)cmd02:セクション
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub Sprint {
	local($mode,$str,$cmd01,$cmd02) = @_;
	local($Flg,$i,$j,$k,$strtmp,@strarray);

	# ４桁数字文字列の数字化 (例：0234 -> 234) 
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
	# 数字文字列を指定した桁の文字列に変換
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
# [Contents     ] ＣＳＶファイル読み込み
#---------------------------------------------------------------------
# [Return       ] (hash)座標連想配列 (0_1,0_2...n_m)
# [Input        ] (string)mode:オプション
#							1:連想配列に格納する
#				  (string)fname:ファイル名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ReadCSVFile {
	local($mode,$fname) = @_;
	local($i,$j,$k,$strCSVKey,$InValFlag,$strline,@strarray,@chararray);

	if($mode eq 1) {

		$InValFlag = 0;

		$strline = &ReadFileData($fname,1);
		#ＥＵＣに変換する
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
						#区切りカンマの場合
						if($InValFlag eq 0) {
						#値カンマの場合
						} elsif($InValFlag eq 1) {
							$chararray[$j] =~ s/$chararray[$j]/_VALKAM_/g;
						}
					}
				}
			}

			$strarray[$i] = join("",@chararray);
			$strarray[$i] =~ s/"//g;

			#デバグ用
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
# [Contents     ] 指定文字カウント処理
#---------------------------------------------------------------------
# [Return       ] (integer)一致数
# [Input        ] (string)mode:オプション
#							1:標準
#				  (string)str:探すところの文字列
#				  (charF)str:カウントする文字
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 頭の空白を削除する
#---------------------------------------------------------------------
# [Return       ] (string)削除した文字列
# [Input        ] (string)strtmp:文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub TrimL {
	local($strtmp) = @_;

	$strtmp =~ s/^\s+//g;

	return $strtmp;
}

#=====================================================================
# [Function		] SandWitch
# [Contents     ] 文字をはさむ
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:文字列
# [Input        ] (string)mode:オプション
#						1:標準
#				  (string)str:中央の文字
#				  (string)substr:端の文字
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ＥＵＣコード変換
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:文字列
# [Input        ] (string)strtmp:文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub JE {
	local($strtmp) = @_;

	&jcode'convert(*strtmp, 'euc');

	return $strtmp;
}

#=====================================================================
# [Function		] JS
# [Contents     ] ＳＨＩＦＴ−ＪＩＳコード変換
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:文字列
# [Input        ] (string)strtmp:文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub JS {
	local($strtmp) = @_;

	&jcode'convert(*strtmp, 'sjis');

	return $strtmp;
}

#=====================================================================
# [Function		] Init_Tag
# [Contents     ] ＨＴＭＬタグ変数初期化
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] なし
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] CSVをHTMLで表示する(<table>...)
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (integer)mode:オプション
#						1:標準
#				  (hash)csv:CSV連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] iniファイルの指定セクションからselectを作成する
#---------------------------------------------------------------------
# [Return       ] select文字列
# [Input        ] (integer)mode:オプション
#						1:標準
#				  (string)section:セクション
#				  (string)selname:select名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] CSV連想配列からCSV行を作成する
#---------------------------------------------------------------------
# [Return       ] CSVデータ文字列
# [Input        ] (integer)mode:オプション
#				  (string)strJ:含まれる文字 (標準:1_ etc...)
#				  (hash)hash:連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] CSV連想配列からCSV行を作成する
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:CSV変換後の1データ
# [Input        ] (string)strtmp:CSV変換前の1データ
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 一行が１データになるための文字列変換関数
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:変換した文字列
# [Input        ] (string)strtmp:変換する文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ConvInputString {
	local($strtmp) = @_;

	$strtmp =~ s/_N_/\n/g;

	return $strtmp;
}

#=====================================================================
# [Function		] UpdateINIFile
# [Contents     ] 設定ファイルの指定項目の値を更新する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (integer)mode:オプション
#				  (string)fname:ファイル名
#				  (string)section:セクション
#				  (string)strFkey:キー
#				  (string)strCval:新しい値
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub UpdateINIFile {
	local($mode,$fname,$section,$strFkey,$strCval) = @_;
	local($i,$StrCurSection,$strline,@strarray);
	

	$strline = &ReadFileData($fname, 1);	#設定ファイルの読み込み
	$strline = &JE($strline);
	@strarray = split(/\n/,$strline);		#改行ごとに区切る


	for($i = 0; $i <= $#strarray; $i++) {
		#セクション初期化・及び変更
		if($strarray[$i] =~ /\[.*\]/) {
			#print "Section:$strarray[$i]<br>\n";	#デバグ用
			
			$StrCurSection = $strarray[$i];		#カレントセクション変数の格納する
			$StrCurSection =~ s/(\[|\])//g;		#中括弧をはずす
			next;
		#キーと値のの初期化
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
# [Contents     ] ファイル配列を取得する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (integer)mode:オプション
#						1:全部取得する
#						2:".",".."を除いた状態で取得する
#						3:ディレクトリのみ取得する
#				  (string)path:取得するディレクトリのパス
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] テーブルのリスト作成時の背景色交換関数
#---------------------------------------------------------------------
# [Return       ] RGB文字列 (#FFFFF or $color)
# [Input        ] (string)color:色
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 配列中に指定した文字列が要素内になるかどうか
#---------------------------------------------------------------------
# [Return       ] (boolean): 1=ある,0=ないか
# [Input        ] (string)strF:探す文字列
#				  (string array)strarray:配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] アルファベットの月情報を数字の月に変換する
#---------------------------------------------------------------------
# [Return       ] 数字の月
# [Input        ] (string)strtmp:英語の月
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] バイナリでファイル読み込み
#---------------------------------------------------------------------
# [Return       ] ファイルデータ
# [Input        ] (string)fname:ファイル名 (パスを含む)
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] バイナリでファイル書き込み
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)fname:ファイル名 (パスを含む)
#				  (string)fdata:データ (バイナリ)
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 標準入力をTmpに保存する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] なし
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] REQUEST_FROMの?の後を利用して連想配列formを作成する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)strtmp:?k=v....文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ＪＩＳコード変換
#---------------------------------------------------------------------
# [Return       ] (string)変換した文字
# [Input        ] (string)strtmp:変換する文字
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub JJ {
	local($strtmp) = @_;

	&jcode'convert(*strtmp, 'jis');

	return $strtmp;
}

#=====================================================================
# [Function		] FileTransferVer1
# [Contents     ] Tmpを利用してファイルアップロード処理 
#					※SaveSTDINDataを先に呼ぶ必要がある。
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] なし
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub FileTransferVer1 {
	#送れるファイルのサイズの制限はここの数字で指定
	return if($ENV{'CONTENT_LENGTH'} > 500000);

	#ファイル名クリア
	$filedata='';
	#ヘッダ獲得
	open(TMP,"Tmp");

	while(<TMP>){
		#動作がきになる人は下のコメントをはずしてみよう
		#print &PH;
		#print "decode0:$_<br>\n";

		#ファイル転送。CR+LFで終了
		last if($_=~/^\r\n/);

		#-----っていうヘッダの後ろについている数字を取り出す。終了判別のため
		$bound = $_ if($_=~/^--/);

		#ヘッダの中から実ファイル名を取り出す
		if ($_=~/filename=/i){
			#効率悪いのは正規表現苦手だから♪　まず”の削除
			$file =$_;
			@filename=split(/\"/,$file);
			foreach $file (@filename) {
				if ($file =~/\./){$filedata =$file;}
			}
			#効率悪いのは正規表現苦手だから♪　￥の削除。ファイル名の判別は.で行う
			$file ="test\\$filedata\\test";
			@filename=split(/\\/,$file);
			foreach $file (@filename) {
				if ($file =~/\./){$filedata =$file;}
			}
		}
	}

	#ファイルの転送を行うの
	if ($filedata ne ''){
		#print "$filedataの転送：";
		$bound=~s/\r\n//;
		open(DATA,">$datdir$filedata") || print "オープン失敗<br>\n";
		while(<TMP>){
			last if($_=~/^$bound/);
			print DATA $_;
		}
		#print "終了";
		close (DATA);
		#print "<br>\n";
	}else{
		#print "ファイル名をちゃんと入れてね<br>\n";
		print &PH;
		print &WmErrMsg("アップロードエラー","<h3>ファイル名を入力して下さい</h3>");
		exit(0);
	}
}

#=====================================================================
# [Function		] GetMaxNumberFromINIHash
# [Contents     ] 設定ファイルの指定セクションの最大値を取得する
#---------------------------------------------------------------------
# [Return       ] (integer)strtmp:最大値
# [Input        ] (integer)mode:オプション
#				  (string)section:セクション
#				  (hash)hash:設定ファイルデータの連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 設定ファイルの指定セクションを配列に格納する
#---------------------------------------------------------------------
# [Return       ] (string array)tmparray:配列
# [Input        ] (integer)mode:オプション
#				  (string)section:セクション
#				  (hash)hash:設定ファイルデータの連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 自作ＳＱＬ
#---------------------------------------------------------------------
# [Return       ] (string or string array)
# [Input        ] (integer)mode:オプション
#				  (string)fname:ファイル名 (パスを含む)
#				  (string)lsp:行データの区切り
#				  (string)dsp:項目データの区切り
#				  (string)id:ユニークのID
#				  (string)idx:取得する項目の位置
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 全角の数字を半角の数字に変換する
#---------------------------------------------------------------------
# [Return       ] (integer)strtmp:変換した数値
# [Input        ] (string)strtmp:変換する文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ConvPrice {
	local($strtmp) = @_;



	$strtmp =~ s/１/1/g;
	$strtmp =~ s/２/2/g;
	$strtmp =~ s/３/3/g;
	$strtmp =~ s/４/4/g;
	$strtmp =~ s/５/5/g;
	$strtmp =~ s/６/6/g;
	$strtmp =~ s/７/7/g;
	$strtmp =~ s/８/8/g;
	$strtmp =~ s/９/9/g;
	$strtmp =~ s/０/0/g;

	$strtmp =~ s/\D//g;	

	if($strtmp eq "") {
		$strtmp = "0";
	}


	return $strtmp;
}

#=====================================================================
# [Function		] MakeHiddenValueWithFilter
# [Contents     ] 連想配列を<input type=hidden..に作成する
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:作成した文字列
# [Input        ] (string)remove:"v:v"フォーマットのhiddenにしないキー
#				  (hash)hash:連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 読み込んだファイルをCurFileDataに確保しておく
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)fname:ファイル名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub StockFileData {
	local($fname) = @_;

	$CurFileData = &ReadFileData($fname,1);
}

#=====================================================================
# [Function		] ListArray
# [Contents     ] 配列を表示する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (integer)mode:オプション
#						1:標準
#				  (string array)strarray:配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ファイルが存在しない場合は作成する
#---------------------------------------------------------------------
# [Return       ] (boolean):1=作らない,0=作る
# [Input        ] (string)fpath:ファイルパス(パス+ファイル名)
#				  (string)fperm:ファイルのパーミッション
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub CheckAndMakeFile {
	local($fpath,$fperm) = @_;

	if(-e $fpath) {
		return "1";
	} else {
		#なければ作る
		mkdir($fpath,$fperm);
		return "0";
	}
}

#=====================================================================
# [Function		] MakeAccountStr
# [Contents     ] アカウント文字列作成
#---------------------------------------------------------------------
# [Return       ] (string)strline:アカウント文字列
# [Input        ] (string)Id:ID
#				  (string)Pwd:PASSWORD
#				  (string)sp:暗号化したパスワード
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 文字列を逆にする
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:逆にした文字列
# [Input        ] (string)strtmp:逆に文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 文字列にある"_変数名_"をその変数名の値に変換する
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:変換した文字列
# [Input        ] (string)strtmp:変換する文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ConvVal {
	local($strtmp) = @_;
		$strtmp =~ s/_(\w+)_/${$1}/g;
	return $strtmp;
}


#=====================================================================
# [Function		] URLEncode
# [Contents     ] 文字列をURLエンコードする
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:エンコードした文字列
# [Input        ] (string)strtmp:エンコードする文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub URLEncode {
	local($strtmp) = @_;
	$strtmp =~ s/(\W)/'%'.unpack("H2", $1)/ego;
	return $strtmp;
}

#=====================================================================
# [Function		] URLDecode
# [Contents     ] 文字列をURLデコードする
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:デコードした文字列
# [Input        ] (string)strtmp:デコードする文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub URLDecode {
	local($strtmp) = @_;
	$strtmp =~ s/%([0-9a-f][0-9a-f])/pack("C",hex($1))/egi;
	return $strtmp;
}

#=====================================================================
# [Function		] ListHash
# [Contents     ] 連想配列をk=vにして配列に格納する
#---------------------------------------------------------------------
# [Return       ] (string array)k=vフォーマットの配列
# [Input        ] (integer)mode:オプション
#				  (hash)hash:連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] クッキーを%COOKIE連想配列で取得する ->$COOKIE{k-v}
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] なし
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] クッキーを埋め込む
#---------------------------------------------------------------------
# [Return       ] (string):"Set-Cookie..." の文字列
# [Input        ] (string)c_name:クッキーの名前
#				  (string)c_value:クッキーの値
#				  (string)c_time:保存する期間
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub PutCookie {

	local($c_name,$c_value,$c_time) = @_;

	($c_sec,$c_min,$c_hour,$c_mday,$c_mon,$c_year,$c_wday,$c_yday,$c_isdst) = localtime(time + $c_time * 60 * 60);

	$c_year = $c_year + 1900; #重要！ これで c_year は "2000" になる
	if ($c_year < 10)  { $c_year = "0$c_year"; }
	if ($c_sec < 10)   { $c_sec  = "0$c_sec";  }
	if ($c_min < 10)   { $c_min  = "0$c_min";  }
	if ($c_hour < 10)  { $c_hour = "0$c_hour"; }
	if ($c_mday < 10)  { $c_mday = "0$c_mday"; }

	#曜日配列作成
	@day = qw(		Sun		Mon		Tue		Wed		Thu		Fri		Sat	);
	#月配列作成
	@month = qw(		Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec	);

	#曜日設定
	$c_day = @day[$c_wday];
	#月設定
	$c_month = @month[$c_mon];

	#期限文字列作成
	$c_expires = "$c_day, $c_mday\-$c_month\-$c_year $c_hour:$c_min:$c_sec GMT";

	#値を返す
	return "Set-Cookie: $c_name=$c_value; expires=$c_expires\n";
}

#=====================================================================
# [Function		] GetSpecDateString
# [Contents     ] 指定の秒数から日付を取得する
#---------------------------------------------------------------------
# [Return       ] (string):keyの値
# [Input        ] (time)time:time
#				  (string)key:取得する情報の名称
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ファイル情報を取得する
#---------------------------------------------------------------------
# [Return       ] (string):keyの値
# [Input        ] (string)fpath:ファイルパス
#				  (string)key:取得する情報の名称
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 配列から Select を作成する
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:select文字列
# [Input        ] (integer)mode:オプション
#				  (string)selname:select名
#				  (string array)strarray:値
#				  (string array)strarray02:見出し
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 配列から Hash を作成する
#---------------------------------------------------------------------
# [Return       ] (hash)連想配列
# [Input        ] (string array)strarray:k=vの配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 日付のselectionを作成する
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:コンボ文字列
# [Input        ] (integer)mode:オプション
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 連想配列をグローバル変数に取り込む
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (hash)hash:取り込み連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ImportHash {
	local(*hash) = @_;
	local($k,$v);
	#print &PH;
	while(($k,$v) = each %hash) {
		#デバグ用
		#print "$k = $v<br>\n";
		${$k} = $v;
	}
}

#=====================================================================
# [Function		] ExportHash
# [Contents     ] 連想配列をコピーする
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (hash)hash:コピー元の連想配列
#				  (hash)hash2:コピー先の連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ExportHash {
	local(*hash,*hash2) = @_;
	local($k,$v);

	#print &PH;
	while(($k,$v) = each %hash) {
		#デバグ用
		#print "$k = $v<br>\n";
		$hash2{$k} = $v;
		#print "$k<BR>";
	}
}

#=====================================================================
# [Function		] CheckFileDateAndDelete
# [Contents     ] ファイル日付を確認して削除する
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:ラベル化した文字列
# [Input        ] (string)mode:オプション
#						hour:v時間で比較
#				  (string)fpath:ファイルのパス
#				  (integer)v:作成してからv時間までなら削除しない
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub CheckFileDateAndDelete {
	local($mode,$fpath,$v) = @_;
	local($ctime,$ftime);

	#エラー処理
	if(!(-e $fpath)) {
		return "0";
	}

	if($mode eq "hour") {
		#デバグ用
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
# [Contents     ] ラベル作成
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:ラベル化した文字列
# [Input        ] (string)strtmp:ラベル化する文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub MakeTempLabel {
	local($strtmp) = @_;

	$strtmp = "<br> <br> <center> $f4<b>$strtmp</b>$fc </center>";

	return $strtmp;
}

#=====================================================================
# [Function		] SortInOne
# [Contents     ] 配列中の重複をなくす
#---------------------------------------------------------------------
# [Return       ] (string array)tmpArray:重複をなくした配列
# [Input        ] (string array)strArray:重複をなくす配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] sendmailでメールを送信する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)mode:オプション
#						1:標準
#						2:添付付きメール ($form{'attach1'},$form{'attach_dat1'})
#						3:ＨＴＭＬメール ($content に html文字列を入れる)
#				  (string)mailprog:sendmailのフルパス(ルートから)
#				  (string)from:送信者情報
#				  (string)to:宛先情報
#				  (string)subject:件名
#				  (string)content:内容
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
			#送信エラー
			$form{'msg'} = "$f4$fred$fb 送信できませんでした。$fc$fc$fc <br><br>";
			$form{'step'} = "";
			&Admin;
			exit(0);
		}
	}
	#添付ファイル付き -------------
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


		## ヘッダー出力部分 ------------------------
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


		## ボディー出力部分 -----------------------

		print SEND "--$bdry\n";
		print SEND 'Content-Type: text/plain; charset=ISO-2022-JP'."\n";
		print SEND "\n";
		print SEND "$msg\n";
		print SEND "\n";

		## 添付出力部分 -----------------------

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
	#ＨＴＭＬメール -------------
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
			#送信エラー
			$form{'msg'} = "$f4$fred$fb 送信できませんでした。$fc$fc$fc <br><br>";
			$form{'step'} = "";
			&Admin;
			exit(0);
		}

	}
}

#=====================================================================
# [Function		] KstdNETxSMTP
# [Contents     ] NETモジュールでメールを送信する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)mode:オプション
#						1:標準
#				  (string)smtpsrv:smtpサーバー情報
#				  (string)from:送信者情報
#				  (string)to:宛先情報
#				  (string)subject:件名
#				  (string)content:内容
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 連想配列の中での空チェック
#---------------------------------------------------------------------
# [Return       ] (integer)1 or 0
# [Input        ] (string array)remove:チェックしないキー
#				  (hash)hash:連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 数値にカンマをつける
#---------------------------------------------------------------------
# [Return       ] (integer)カンマつきの数値
# [Input        ] (integer)カンマをつける数値
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ConvPriceComma {
    local($_) = @_;
    1 while s/(.*\d)(\d\d\d)/$1,$2/;
    $_;
}

#=====================================================================
# [Function		] MakeHashFromString
# [Contents     ] 文字列から連想配列を作成する
#---------------------------------------------------------------------
# [Return       ] (hash or global variable)1:連想配列,2:グローバル変数
# [Input        ] (integer)mode:オプション
#				  (string)strtmp:連想配列フォーマット文字列
#				  (string)sp:大区切り
#				  (string)sp2:小区切り
#				  (string)hn:連想配列の代わりとなる名前
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 四捨五入する
#---------------------------------------------------------------------
# [Return       ] (integer)四捨五入した数字
# [Input        ] (integer)num:数字
#				  (integer)decimals:四捨五入する桁
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 日付フォーマットを所得する
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:YYYY/MM/DD
# [Input        ] なし
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ○Ｘ判定
#---------------------------------------------------------------------
# [Return       ] (integer)q=1だったら○,q=0だったら×
# [Input        ] (integer)q:1か0
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub MaruBatu {
	local($q) = @_;

	if($q) {
		return "○";
	} else {
		return "×";
	}
}

#=====================================================================
# [Function		] IchiZero
# [Contents     ] １と０を交換する
#---------------------------------------------------------------------
# [Return       ] (integer)q=1だったら0,q=0だったら1
# [Input        ] (integer)q:1か0
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] 配列を混ぜる
#---------------------------------------------------------------------
# [Return       ] (string array)new:混ぜた配列
# [Input        ] (string array)old:混ぜる配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ファイルタイプ判別
#---------------------------------------------------------------------
# [Return       ] (string)strline:拡張子情報
# [Input        ] (string)strtmp:ファイル名(拡張子込み)
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ストップウォッチ(version1.0)
#---------------------------------------------------------------------
# [Return       ] (integer)かかった時間(秒)
# [Input        ] (string)flag:フラグ
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
# [Contents     ] ＣＳＶ文字列を一般文字列にして配列にして返す
#---------------------------------------------------------------------
# [Return       ] (string array)strarray:データ配列
# [Input        ] (string)strtmp:CSV一行
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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
				#区切りカンマの場合
				if($InValFlag eq 0) {
				#値カンマの場合
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
# [Contents     ] 強調文字列作成
#---------------------------------------------------------------------
# [Return       ] (string)文字列
# [Input        ] (string)strtmp:強調する文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
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