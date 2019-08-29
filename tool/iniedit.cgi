#!/usr/bin/perl

######################################################################
#
# [	作品名		]	iniファイルエディタ ver1.0
# [	作成者		]	浜田宏次郎
#
# [ 使用方法	]	以下参照.
#
#   以下のようなフォーマットでiniファイルを作成し、
#   iniフォルダ下の iniedit.ini でファイル保存して下さい。
#   このiniedit.iniはこのプログラムを動かすのに必要な設定ファイルです。
#
#   ▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
#   [GROBAL]
#   DecodeINITo	= sjis
#   [END]
#   △△△△△△△△△△△△△△△
#
#   またこのプログラムに必要な引数は編集するiniファイルのファイル名です。
#   起動するときは iniedit.cgi?inifile=iniファイルのパス
#   と入力して起動して下さい。
#   DecodeINITo = sjis は編集する設定ファイルの文字コードです。
#
# [	必要なもの	]	『kstd.pl』、『jcode.pl』 、『iniedit.ini』
#
######################################################################

#=================================================[初期化ルーチン]====

#グローバル変数の初期化
$StdLib 		= "lib/kstd.pl";
$JcodeLib 		= "lib/jcode.pl";
$ThisFile		= $ENV{"SCRIPT_NAME"};
$MainINIFile	= "ini/iniedit.ini";

#---------------------------------------------------------------------

$|=1;

push(@INC,"lib");

require "$StdLib";		#オリジナル標準ライブラリ初期化
require "$JcodeLib";	#文字コード変換ライブラリ初期化

&Init_Form("euc");
&Init_Tag;

%INI = {};
%INI = &InitINIData(1,$MainINIFile);

#==================================================================================[メインルーチン]==
#★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
#====================================================================================================

&EditINI;

#====================================================================================[サブルーチン]==
#★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
#====================================================================================================

sub EditINI {

	local($i,$strtm);

	if($form{'step'} eq "") {

		#エラー処理 --- ここから
		if(!defined($INI{"GROBAL-DecodeINITo"})) {
			&Err001("<h3>GROBALセクションにDecodeINITo（設定ファイルの文字コード）を設定して下さい。</h3>");
		}

		$strtmp = &JE(&ReadFileData($form{'inifile'},3));
		$strtmp =~ s/\r//g;
		@strarray = split(/\n/,$strtmp);
		$i_max = $#strarray;

		$tmp01 = &Parapara("#EAEAEA");

		@strarray = grep { $_ ne "" } @strarray;

		#エディットテーブル作成ループ ------------- ここから
		for($i = 0; $i <= $i_max; $i++) {

			# [文字列] で始まっていたらセクション宣言と見なす
			if($strarray[$i] =~ /^\[/) {
				($CurSection) = $strarray[$i] =~ /\[(.*)\]/;
				push(@secarray,$CurSection);
				$strhtml .= "<tr bgcolor=\"pink\"><td colspan=\"2\">$CurSection</td></tr>\n";
			}
			# "k = v" の場合 ---
			elsif($strarray[$i] =~ /((\w|\d)+)((\t|\s)+)=(\t|\s)(.*)/) {

				$tmp01 = &Parapara("#EAEAEA");

				($CurKey,$dum,$dum,,$dum,$dum,$CurVal) = $strarray[$i] =~ /((\w|\d)+)((\t|\s)+)=(\t|\s)(.*)/;
				#print "$CurKey + $CurVal<BR>";
				$CurVal =~ s/"/&quot;/g;
				$strhtml .= "<tr bgcolor=\"$tmp01\"><td>$CurKey </td><td> <input type=\"text\" name=\"$CurSection\XXX$CurKey\" value=\"$CurVal\"></td></tr>\n";
				push(@hiddenarray,"<input type=\"hidden\" name=\"o$CurSection\XXX$CurKey\" value=\"$CurVal\">\n");

			}
			# str の場合 ---
			elsif($strarray[$i] =~ /(.*)/ and $strarray[$i + 1] =~ /(.*)/ and $strarray[$i] ne "") {

				$tmp01 = &Parapara("#EAEAEA");

				($ctt,$dum) = $strtmp =~ /\[$CurSection\]\n(.*?)(\n\[.*\])/s;
				$strhtml .= "<tr bgcolor=\"$tmp01\"><td colspan=\"2\"> <textarea name=\"STR_$CurSection\" rows=\"5\" cols=\"50\">$ctt</textarea> <a href=\"$ThisFile?act=editini\&step=delstr\&sec=$CurSection\&inifile=$form{'inifile'}\">削除</a> </td></tr>\n";

				for($i; $i <= $i_max; $i++) {
					if($strarray[$i + 1] =~ /^\[/) {
						last;
					}
				}
			}
		}
		#エディットテーブル作成ループ ------------- ここまで

		#キーSelection 文字列取得
		$secsel = &MakeSelectionByStrArray(2,"targetsec",*secarray,*secarray);

		$msg = join("","

			<h3>設定ファイルエディタ</h3>

			<hr>

			<form action=\"$ThisFile\" method=\"post\">
			<table border=\"0\" $cp{'3'} width=\"80%\">
			$strhtml
			</table>
			<p>
			<input type=\"submit\" value=\"　ＯＫ　\">
			<input type=\"hidden\" name=\"act\" value=\"editini\">
			<input type=\"hidden\" name=\"step\" value=\"2\">
			<input type=\"hidden\" name=\"inifile\" value=\"$form{'inifile'}\">

			@hiddenarray

			</form>



			<form action=\"$ThisFile\" method=\"post\">
			<b>キーの作成</b> <BR>
			$secsel に キー：<input type=\"text\" name=\"newkey\" value=\"\"> 値：<input type=\"text\" name=\"newval\" value=\"\"> を追加 <input type=\"submit\" value=\"する\">。
			<input type=\"hidden\" name=\"act\" value=\"editini\">
			<input type=\"hidden\" name=\"step\" value=\"addkey\">
			<input type=\"hidden\" name=\"inifile\" value=\"$form{'inifile'}\">
			</form>

			<form action=\"$ThisFile\" method=\"post\">
			<b>文章の作成</b> <BR>
			キー：<BR>
			<input type=\"text\" name=\"newkey\" value=\"\"> <BR>
			値：<BR>
			<textarea name=\"newval\" rows=\"5\" cols=\"50\"></textarea> <BR>
			<input type=\"submit\" value=\"作成実行\">
			<input type=\"hidden\" name=\"act\" value=\"editini\">
			<input type=\"hidden\" name=\"act\" value=\"editini\">
			<input type=\"hidden\" name=\"step\" value=\"addstr\">
			<input type=\"hidden\" name=\"inifile\" value=\"$form{'inifile'}\">
			</form>


			<hr>
			<a href=\"$ThisFile?act=editini\&inifile=$form{'inifile'}\">更新</a>

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

		# k = v 更新 ------------ ここから
		$i_max = $#updatearray;
		for($i = 0; $i <= $i_max; $i++) {
			($sec,$key) = split(/XXX/,$updatearray[$i]);
			&WmUpdateINIFile(1,$form{'inifile'},$sec,$key,$form{"o$updatearray[$i]"},$form{"$updatearray[$i]"});
		}

		# str 更新 ------------ ここから
		$i_max = $#update2array;
		for($i = 0; $i <= $i_max; $i++) {
			($dum,$sec) = split(/_/,$update2array[$i]);

			$form{"$update2array[$i]"} =~ s/\r//g;

			$strtmp = &JE(&ReadFileData($form{'inifile'},3));
			$strtmp =~ s/\r//g;

			$strtmp =~ s/(\[$sec\]\n)(.*?)(\n\[(.*)\])/$1$form{"$update2array[$i]"}$3/sg; #値の最後に改行を入れる

			#&Err001($strtmp);

			&jcode'convert(*strtmp, $INI{'GROBAL-DecodeINITo'});
			&RecordFileData("$form{'inifile'}", 3, $strtmp);
			#sleep 1;
		}

		$msg = "$form{'inifile'} を更新しました。<p> <a href=\"$ThisFile\">$BBSTitle</a> <a href=\"$ThisFile?act=editini\&inifile=$form{'inifile'}\">見る</a>";
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

#====================================================================================[ライブラリ]====
#★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
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