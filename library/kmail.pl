
$base64a = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
@base64as = split(//,$base64a);

#--------------------------------------------------------------------------
# バイナリでファイルを開く
#--------------------------------------------------------------------------

sub ReadBinFileData {
	local($fname) = @_;
	local($strline);

	open(BD,$fname);
	binmode(BD);
	while(<BD>) {
		$strline = $strline . $_;
	}
	close(BD);

	return $strline;
}

#--------------------------------------------------------------------------
# メール文字列からメッセージＩＤを抽出する
#--------------------------------------------------------------------------

sub GrabMidFromMailStr {
	local($strtmp) = @_;
	local($strline) = @_;

	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;
	($dum,$strline,$dum) = $strtmp =~ /Message-[Ii][Dd]:(.*)<(.*)>(.*)/;

	return $strline;
}

#--------------------------------------------------------------------------
# メール文字列からＵＩＤＬを抽出する
#--------------------------------------------------------------------------

sub GrabUidFromMailStr {
	local($strtmp) = @_;
	local($strline) = @_;

	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;
	($strline) = $strtmp =~ /X-UIDL: (.*)/;

	return $strline;
}


#--------------------------------------------------------------------------
# メール文字列から件名を抽出して配列で返す
#--------------------------------------------------------------------------

sub GrabSbjArrayFromMailStr {
	local($fname) = @_;
	local($i,$StrAllMail,$Sbjstr,@StrArray,@strarray);



	$StrAllMail = &ReadFileData($fname,1);
	@StrArray = split(/\n/,$StrAllMail);

	for($i = 0; $i <= $#StrArray; $i++) {
		$Sbjstr = &GrabSbjFromMailStr($StrArray[$i]);
		if(&TrimL($Sbjstr) eq "") {
			$Sbjstr = "No Title";
		}
		#$Sbjstr =~ s/ /\&nbsp;/g;

		$strarray[$i] = $Sbjstr;

		#print "$Sbjstr<br>";

	}

	return @strarray;
}

#--------------------------------------------------------------------------
# メール文字列からＵＩＤ・ＭＩＤを抽出して配列で返す
#--------------------------------------------------------------------------

sub GrabMidorUidArrayFromMailStr {
	local($fname) = @_;
	local($i,$StrAllMail,$Midstr,@StrArray,@strarray);



	$StrAllMail = &ReadFileData($fname,1);
	@StrArray = split(/\n/,$StrAllMail);

	for($i = 0; $i <= $#StrArray; $i++) {
		$Midstr = &GrabMidFromMailStr($StrArray[$i]);
		if($Midstr eq "") {
			$Midstr = $INI{'GROBAL-StrUidHead'} . &GrabUidFromMailStr($StrArray[$i]);
		}

		$strarray[$i] = $Midstr;
	}

	return @strarray;
}

#--------------------------------------------------------------------------
# メール文字列からＵＩＤ・ＭＩＤを抽出して返す
#--------------------------------------------------------------------------

sub GrabMidorUidFromMailStr {
	local($strtmp) = @_;
	local($Midstr);


	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;

	$Midstr = &GrabMidFromMailStr($strtmp);
	if($Midstr eq "") {
		$Midstr = $INI{'GROBAL-StrUidHead'} . &GrabUidFromMailStr($strtmp);
	}

	$Midstr =~ s/[\n| ]//g;

	return $Midstr;
}


#--------------------------------------------------------------------------
# メール文字列から添付ファイルを抽出する
#--------------------------------------------------------------------------

sub GrabAtcFromMailStr {
	local($strtmp) = @_;
	local($i,$strline,@tmparray,@tmparray2,@strarray);

	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;
	$strtmp =~ s/boundary="(.*)"/boundary="$1"/;
	$boundary = $1;

	if($boundary ne "") {
		@tmparray = split(/--$boundary\n/,$strtmp);
		
		for($i = 1; $i <= $#tmparray; $i++) {
			$tmparray[$i] =~ /Content-Type: (.*);\n[\t ]name=(.*)\n/; #Content-Type: ($1);\n\tname=$2\n/;
			#print "CT > $1<br>\n";
			$ctttype = $1;
			$atcname = $2;
			$atcname =~ s/"//g;
			$atcname = &JE(&DirectISO($atcname));
			#print "NM > $atcname<br>\n";


			@tmparray2 = split(/\n\n/,$tmparray[$i]);
			#print "\n$fred\n$tmparray2[1]\n$fc\n";

			$tmparray2[1] =~ s/\n//g;

			$tmparray2[1] = &DecodeBase64a($tmparray2[1]);


			if($ctttype =~ /msword/) {
				#binmode(STDOUT);
				#print STDOUT "Content-Type: $ctttype\n\n";
				#print STDOUT $tmparray2[1];
				print &PH;
				print $tmparray2[1];
			}
			
		}
	}

	return @strarray;
}

#--------------------------------------------------------------------------
# 『=?ISO-2022-JP?B?文字列?=』 をそのまま受け取りデコードする
#--------------------------------------------------------------------------

sub DirectISO {
	
	local($strline) = @_;

	if($strline =~ /(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/) {
		local ($str1, $str2, $str3) = $strline =~ /(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/;
		$strline = &DecodeBase64a($str2);
	} else {
	}

	return $strline;
}

#--------------------------------------------------------------------------
# メール文字列から内容を抽出する
#--------------------------------------------------------------------------

sub GrabCttFromMailStr {
	local($strtmp) = @_;
	local($strline,@tmparray);




	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;


	if($strtmp =~ /boundary="(.*)"/) {
		#($dum,$StrArray[$mid]) = split(/\n\n/,$StrArray[$mid]);
		$ThisMailIsMulti = 1;	#global
		$boundary = $1;
		$strtmp =~ s/$boundary//;
		@tmparray = split(/--$boundary/,$strtmp);

		if($tmparray[2] =~ /text\/html(.*)(\n\n?)(.*)/) {
			$tmparray[2] =~ /(.*text\/html)(.*)(\n\n?)(.*)/s;
			#print "$1";
			#exit(0);
			return $tmparray[2];
		} else {
			return $tmparray[1];
		}
	} else {
		$strtmp =~ s/\n\n/$INI{'GROBAL-MailStrSp'}/;
		($dum,$strline) = split(/$INI{'GROBAL-MailStrSp'}/,$strtmp);

		return $strline;
	}

}

#--------------------------------------------------------------------------
# メール文字列から『Content-Type』を抽出する
#--------------------------------------------------------------------------

sub GrabCtpFromMailStr {
	local($strtmp) = @_;
	local($strline,@tmparray);

	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;
	$strline = "";

	if($strtmp =~ /[Cc]ontent-[Tt]ype: (.*)/) {
		$strline = $1 . " " . $2;
	}

	if($strtmp =~ /[Cc]ontent-[Tt]ype: (.*)/) {
		$strline = $1;
	}

	return $strline;
}

#--------------------------------------------------------------------------
# メール文字列から『Content-Type』を抽出して配列で返す
#--------------------------------------------------------------------------

sub GrabCtpArrayFromMailStr {
	local($fname) = @_;
	local($i,$StrAllMail,$Ctpstr,@StrArray,@strarray);



	$StrAllMail = &ReadFileData($fname,1);
	@StrArray = split(/\n/,$StrAllMail);

	for($i = 0; $i <= $#StrArray; $i++) {
		$Ctpstr = &GrabCtpFromMailStr($StrArray[$i]);
		if($Ctpstr eq "") {
			$Ctpstr = "No Title";
		}

		$strarray[$i] = $Ctpstr;

	}

	return @strarray;
}


#--------------------------------------------------------------------------
# メール文字列から件名を抽出する
#--------------------------------------------------------------------------

sub GrabSbjFromMailStr {
	local($strtmp) = @_;
	local($i,$Sbj_Flag,$strline,@strarray);

	$Sbj_Flag = 0;
	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;
	
	@strarray = split(/\n/,$strtmp);

	for($i = 0; $i <= $#strarray; $i++) {
		if($strarray[$i] =~ /^Subject:/i) {
			$Sbj_Flag = 1;
			if($strarray[$i] =~ /(.*)Subject:(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/) {
				$strline = $strline . $2 . &DecodeBase64a($3);
			} elsif($strarray[$i] =~ /(.*)Subject:(.*)/) {
				$strline = $strline . $2;
			}
		} elsif(($strarray[$i] =~ /(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/) && $Sbj_Flag eq 1) {
			$strline = $strline . &DecodeBase64a($2);
		}
	}


	return $strline;
}

#--------------------------------------------------------------------------
# メール文字列から送信者を抽出する
#--------------------------------------------------------------------------

sub GrabFrmFromMailStr {
	local($strtmp) = @_;
	local($i,$Frm_Flag,$strline,@strarray);

	$Frm_Flag = 0;
	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;
	
	@strarray = split(/\n/,$strtmp);

	for($i = 0; $i <= $#strarray; $i++) {
		if($strarray[$i] =~ /^From:/i) {
			$Frm_Flag = 1;
			if($strarray[$i] =~ /(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/) {
				$strline = $strline . &DecodeBase64a($2);
				$gFrmp3 = $3;
				#$strline = $strline . $3;
			} elsif($strarray[$i] =~ /(.*)From:(.*)/i) {
				$strline = $strline . $2;
			}
			last;
		} elsif(($strarray[$i] =~ /(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/) && $Frm_Flag eq 1) {
			$strline = $strline . &DecodeBase64a($2) . $3;
		}
	}


	return $strline;
}


#--------------------------------------------------------------------------
# メール文字列から送信者を抽出して配列で返す
#--------------------------------------------------------------------------

sub GrabFrmArrayFromMailStr {
	local($fname) = @_;
	local($i,$StrAllMail,$Frmstr,@StrArray,@strarray);



	$StrAllMail = &ReadFileData($fname,1);
	@StrArray = split(/\n/,$StrAllMail);

	for($i = 0; $i <= $#StrArray; $i++) {
		$Frmstr = &GrabFrmFromMailStr($StrArray[$i]);
		if($Frmstr eq "") {
			$Frmstr = "No Title";
		}
		$Frmstr =~ s/ //g;


		if($Frmstr =~ /"(.*)"(.*)/) {
			$Frmstr = $1;
		}

		$strarray[$i] = $Frmstr;

	}

	return @strarray;
}


#--------------------------------------------------------------------------
# メール文字列から宛先を抽出する
#--------------------------------------------------------------------------

sub GrabToFromMailStr {
	local($strtmp) = @_;
	local($i,$To_Flag,$strline,@strarray);

	$To_Flag = 0;
	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;
	
	@strarray = split(/\n/,$strtmp);

	for($i = 0; $i <= $#strarray; $i++) {
		if($strarray[$i] =~ /^To:/i) {
			$To_Flag = 1;
			if($strarray[$i] =~ /(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/) {
				$strline = $strline . &DecodeBase64a($2);
			} elsif($strarray[$i] =~ /(.*)To:(.*)/i) {
				$strline = $strline . $2;
			}
			last;
		} elsif(($strarray[$i] =~ /(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/) && $To_Flag eq 1) {
			$strline = $strline . &DecodeBase64a($2);
		}
	}


	return $strline;
}


#--------------------------------------------------------------------------
# メール文字列から宛先を抽出して配列で返す
#--------------------------------------------------------------------------

sub GrabToArrayFromMailStr {
	local($fname) = @_;
	local($i,$StrAllMail,$Tostr,@StrArray,@strarray);



	$StrAllMail = &ReadFileData($fname,1);
	@StrArray = split(/\n/,$StrAllMail);

	for($i = 0; $i <= $#StrArray; $i++) {
		$Tostr = &GrabToFromMailStr($StrArray[$i]);
		if($Tostr eq "") {
			$Tostr = "No Title";
		}
		$Tostr =~ s/ //g;


		if($Tostr =~ /"(.*)"(.*)/) {
			$Tostr = $1;
		}

		$strarray[$i] = $Tostr;

	}

	return @strarray;
}




#--------------------------------------------------------------------------
# メール文字列から日付を抽出する
#--------------------------------------------------------------------------

sub GrabDtFromMailStr {
	local($strtmp) = @_;
	local($i,$Dt_Flag,$strline,@strarray);

	$Dt_Flag = 0;
	$strtmp =~ s/$INI{'GROBAL-MailStrSp'}/\n/g;
	
	@strarray = split(/\n/,$strtmp);

	for($i = 0; $i <= $#strarray; $i++) {
		if($strarray[$i] =~ /^Date:/i) {
			$Dt_Flag = 1;
			if($strarray[$i] =~ /(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/) {
				$strline = $strline . &DecodeBase64a($2);
			} elsif($strarray[$i] =~ /(.*)Date:(.*)/) {
				$strline = $strline . $2;
			}
			last;
		} elsif(($strarray[$i] =~ /(.*)=\?[Ii][Ss][Oo]-2022-[Jj][Pp]\?B\?(.*)\?=(.*)/) && $Dt_Flag eq 1) {
			$strline = $strline . &DecodeBase64a($2);
		}
	}


	return $strline;
}

#--------------------------------------------------------------------------
# メール文字列から日付を抽出して配列で返す
#--------------------------------------------------------------------------

sub GrabDtArrayFromMailStr {
	local($fname) = @_;
	local($i,$StrAllMail,$Dtstr,@StrArray,@strarray);



	$StrAllMail = &ReadFileData($fname,1);
	@StrArray = split(/\n/,$StrAllMail);

	for($i = 0; $i <= $#StrArray; $i++) {
		$Dtstr = &GrabDtFromMailStr($StrArray[$i]);
		if($Dtstr eq "") {
			$Dtstr = "No Date";
		}


		$strarray[$i] = $Dtstr;

	}

	return @strarray;
}



#--------------------------------------------------------------------------
# 接続中のソケットにコマンドを送る
#--------------------------------------------------------------------------

sub SendCmdToSocket {
	local($strtmp) = @_;
	local($strline);

	if($strtmp eq "_") {
		recv(MSCK, $strline, 512, 0);
	} else {
		send(MSCK, "$strtmp\r\n", 0);
		recv(MSCK, $strline, 512, 0);
	}

	return $strline;
}

#--------------------------------------------------------------------------
# ソケットを開く
#--------------------------------------------------------------------------

sub OpenSocket {
	local($server, $port) = @_;

	$proto = getprotobyname('tcp');
	socket(MSCK, PF_INET, SOCK_STREAM, $proto);
	$ipadr = gethostbyname($server);
	$sin = pack('Sna4x8', AF_INET, $port, $ipadr);


	if(connect(MSCK, $sin)) {
		$strline = 1;
	} else {
		$strline = 0;
	}

	return $strline;
}

#--------------------------------------------------------------------------
# サーバーから指定のメールを受信する
#--------------------------------------------------------------------------

sub GetSpecMailFromPOP3 {
	local($strtmp) = @_;
	local($strline,$junk);


	send(MSCK, "RETR $strtmp\r\n", 0);

	while(<MSCK>) {
		$junk = $_;
		$junk =~ s/\r\n/\n/g;
		if($junk =~ /^\.\n/) {
			last;
		}
		$strline .= $junk;
	}

	return $strline;
}




#--------------------------------------------------------------------------
# サーバーから指定のメールＴＯＰを受信する
#--------------------------------------------------------------------------

sub GetSpecMailTOPFromPOP3 {
	local($strtmp) = @_;
	local($strline,$junk);


	send(MSCK, "TOP $strtmp 10\r\n", 0);

	while(<MSCK>) {
		$junk = $_;
		$junk =~ s/\r\n/\n/g;
		if($junk =~ /^\.\n/) {
			last;
		}
		$strline .= $junk;
	}

	return $strline;
}


#--------------------------------------------------------------------------
# Base64デコーダー（コーダー：FayWay管理者）
#--------------------------------------------------------------------------

sub xxDecodeBase64a {
	local ($_) = @_;
	eval qq{ tr!$base64a!\0-\77!; };
	$_ = unpack('B*', $_);
	s/(..)(......)/$2/g;
	s/((........)*)(.*)/$1/;
	$_ = pack('B*', $_);
	#&jcode'convert(*_, 'sjis');
	return $_;
}

#--------------------------------------------------------------------------
# Base64デコーダー（標準）
#--------------------------------------------------------------------------

sub DecodeBase64a {
	local ($_) = @_;
	$_ = &decode_base64($_);
	return $_;
}

#--------------------------------------------------------------------------
# Base64エンコーダー（標準）
#--------------------------------------------------------------------------

sub EncodeBase64a {
	local ($_) = @_;
	$_ = &encode_base64($_);
	return $_;
}

#--------------------------------------------------------------------------
# Base64デコーダー（作：浜田宏次郎）
#--------------------------------------------------------------------------

sub xDecodeBase64a {
	local($strtmp) = @_;
	local($i,$j,$k,$l,$strline,$tmp01,$lenA,$last_flag,@strarray,@tmparray);

	@strarray = split(//,$strtmp);
	for($i = 0; $i <= $#strarray; $i++) {

		#print "<br>moji $strtmp no $strarray[$i] $i";

		if($strarray[$i+1] ne "=") {
			$last_flag = 0;
		} else {
			$last_flag = 1;
		}

		#print "<br>$strarray[$i] = " . index($base64a,$strarray[$i]);
		#print unpack("B6","100");
		#print "<br>" . &NumberToBinary(index($base64a,$strarray[$i]));

		if($last_flag eq 0) {
			$strline = $strline . &Sprint(2,&NumberToBinary(index($base64a,$strarray[$i])),6);

		} elsif($last_flag eq 1) {
			$tmp01 = &NumberToBinary(index($base64a,$strarray[$i]));
			$l = $tmp01;
			$j = length($tmp01);
			@tmparray = split(//,$tmp01);
			@tmparray = reverse(@tmparray);

			#print "@tmparray";

			for($k = 0; $k <= $#tmparray; $k++) {
				if($tmparray[$k] eq "1") {
					last;
				} else {
					shift(@tmparray);
					#print "<br>@tmparray";
					$k--;
					
				}
			}

			@tmparray = reverse(@tmparray);
			$tmp01 = join("",@tmparray);

			#print "<br>SAIGO $l kara $tmp01";
			$strline = $strline . $tmp01;

			last;
		}

		#print "<br>pc $strline";

	}


	#print "<br>end $strline";

	$lenA = length($strline);

	#print "<h6>$lenA</h6>\n";

	#$lenA = $lenA * 8;
	$strline = pack("B$lenA",$strline);




	return $strline;
}

#--------------------------------------------------------------------------
# Base64エンコーダー（作：浜田宏次郎）
#--------------------------------------------------------------------------

sub xEncodeBase64a {
	local($strtmp) = @_;
	local($i,$strline,$lenA,$x,$x2,$lack_flag);

	#$strtmp = &JS($strtmp);	
	#print "L > " . length($strtmp) . "<br>";
	$lenA = length($strtmp);
	$lenA = $lenA * 8;
	$strtmp = unpack("B$lenA",$strtmp);
	#print "<br>8bit $strtmp";

	for($i = 0; $i < length($strtmp); $i+=6) {
		$x = substr($strtmp,$i,6);
		#print "<br>x ha > $x de<br>i - $i " . &BinaryToNumber($x);
		while(6 > length($x)) {
			$x = $x . "0";
			$lack_flag = 1;
		}
		$x2 = &BinaryToNumber($x);
		#print "<br>$base64as[$x2]";
		$strline = $strline . $base64as[$x2];
		if($lack_flag eq 1) {
			last;
		}
	}


	#$xx = length($strline) % 4;
	#print $xx;

	while((length($strline) % 4) != 0) {
		$strline = $strline . "=";
	}


	return $strline;
}

#--------------------------------------------------------------------------
# ２進数から１０進数へ
#--------------------------------------------------------------------------

sub BinaryToNumber {
	local($strtmp) = @_;
	local($x,$i,$total,@strarray);

	$total = 0;

	@strarray = split(//,$strtmp);
	@strarray = reverse(@strarray);

	for($i = 0; $i < length($strtmp); $i++) {

		$total = $total + $strarray[$i] * (2 ** $i);
		$x = 2 ^ $i;
		#print "<br>x = $x";
		#print "<br> - $total";
	}

	return $total;
}

#--------------------------------------------------------------------------
# １０進数から２進数へ
#--------------------------------------------------------------------------

sub NumberToBinary {

	local($strtmp) = @_;
	local($n,$x,$m,$strline,@strarray);

	$x = $strtmp;

	while(true) {
		$m = $x % 2;
		$x = int($x / 2);

		$strline = $strline . $m;

		if($x eq 0) {
			last;
		}
	} 


	@strarray = split(//,$strline);
	@strarray = reverse(@strarray);
	$strline = join("",@strarray);

	return $strline;

}


#--------------------------------------------------------------------------
# ＣＳＶ文字列を一般文字列にして配列にして返す
#--------------------------------------------------------------------------

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


1;