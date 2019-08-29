#=====================================================================
# [Function		] Init_SQL
# [Contents     ] ＳＱＬ環境を初期化する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] なし
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub Init_SQL {

	if($ENV{'HTTP_HOST'} eq "www.kojirohamada.com") {
		$mysql_dbn	= "";
		$mysql_host	= "";
		$mysql_user	= "";
		$mysql_pass	= "";
	}
	elsif($ENV{'HTTP_HOST'} =~ /abc/) {
		$mysql_dbn	= "";
		$mysql_host	= "";
		$mysql_user	= "";
		$mysql_pass	= "";
	}
	else {
		$mysql_dbn	= "";
		$mysql_host	= "";
		$mysql_user	= "";
		$mysql_pass	= "";
	}

}

#=====================================================================
# [Function		] ConnectSQL
# [Contents     ] ＳＱＬに接続する
#				  ※ここはOracle,PGSQL,MySql,Sybase,MSSQL異なる場合が
#				    あるので自作で作ることをおすすめします。
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)driver:ドライバ文字列
#				  (string)database:データベース名
#				  (string)hostname:ホスト名
#				  (string)port:ポート番号
#				  (string)user:ユーザー名
#				  (string)password:パスワード
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ConnectSQL {
	local($driver,$database,$hostname,$port,$user,$password) = @_;
	local($dsn);

 	$dsn = "DBI:$driver:database=$database;host=$hostname;port=$port"; #ＤＳＮ変数初期化
	$dbh = DBI->connect($dsn, $user, $password);	#接続実行
	print "$dbh->errstr" if(not $dbh);
	$drh = DBI->install_driver("mysql");	#ドライバインストール
	print "$dbh->errstr" if(not $dbh);


}

#=====================================================================
# [Function		] DisconnectSQL
# [Contents     ] ＳＱＬを切断する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] なし
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub DisconnectSQL {

	$dbh->disconnect();	# 切断実行
	$SQL_CONNECTED = 0;

}

#=====================================================================
# [Function		] MakeTableFromSTH
# [Contents     ] sthをTABLE化にする
#---------------------------------------------------------------------
# [Return       ] (string)strline:HTML文字列
# [Input        ] (string)tname:テーブル名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub MakeTableFromSTH {
	local($tname) = @_;
	local($i,$strline,$numRows,$numFields,@field);

	#フィールド名をヘッドに挿入
	&ExecSQL("DESC $tname"); #ＳＱＬ文実行
	@fldname = &MakeArrayBySpecCat("Field");

	for($i = 0; $i <= $#fldname; $i++) {

		if($fldname[$i] eq "") {
			$fldname[$i] = "\&nbsp;";
		}
		$strline .= "<td><b>$fldname[$i]</b></td>\n";
	}

	$strline = "<tr bgcolor=\"pink\">\n$strline</tr>\n";

	&ExecSQL("SELECT * from $tname"); #ＳＱＬ文実行
	$numRows 	= $sth->rows;			#行数
	$numFields 	= $sth->{'NUM_OF_FIELDS'};	#項目数

	#項目に対するバインドをする
	for($i = 1; $i <= $numFields; $i++) {
		$sth->bind_col($i, \$field[$i], undef);
	}


	#メインテーブルを作成する
	while ( $sth->fetch ){
		$strline .= "<tr>\n";
		for($i = 1; $i <= $#field; $i++) {
			if($field[$i] eq "") {
				$field[$i] = "\&nbsp;";
			}
			$field[$i] = &ConvHTMLTag($field[$i]);
			$strline .= "<td nowrap>$field[$i]</td>\n";
		}
		$strline .= "</tr>\n";
	} 


	#テーブル整理
	$strline = join("","
		<table style=\"font-size:10pt\" border=\"1\">
		$strline
		</table>
		");

	return $strline;
}

#=====================================================================
# [Function		] ExecSQL
# [Contents     ] ＳＱＬ実行
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)cmd:SQLコマンド文字列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub ExecSQL {
	local($cmd) = @_;	

	$sth = $dbh->prepare($cmd);
	$sth->execute();

}

#=====================================================================
# [Function		] MakeArrayBySpecCat
# [Contents     ] 指定フィールドを配列に入れる
#---------------------------------------------------------------------
# [Return       ] (string array)strarray:指定フィールドの配列
# [Input        ] (string)name:フィールド名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub MakeArrayBySpecCat {
	local($name) = @_;
	local(@strarray);

	while ($ref = $sth->fetchrow_hashref()) {
		push(@strarray,$ref->{$name});
	}

	return @strarray;

}

#=====================================================================
# [Function		] MakeTableFromCSVFile
# [Contents     ] ファイルtoテーブル
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)fname:ファイル名
#				  (string)tname:テーブル名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub MakeTableFromCSVFile {
	local($fname,$tname) = @_;
	local($i,$fdata,$fldstat,$query,$fld,@fdataarray,@fldstatarray);

	$fld = "";

	#ファイル読み込み（タブ区切り）
	$fdata = &JE(&ReadFileData("$fname",3));
	@fdataarray = split(/\n/,$fdata);

	#一行目を取り除く
	shift(@fdataarray);
	$fldstat = shift(@fdataarray);

	#項目処理
	$fldstat =~ s/\t/,/g;
	@fldstatarray = split(/,/,$fldstat);



	#テーブル作成  --------------ここから
	for($i = 0; $i <= $#fldstatarray; $i++) {

		$fldname 	= "";
		$fldtype 	= "";
		$typename 	= "";
		$typebyte 	= "";

		($fldname,$fldtype) = split(/_/,$fldstatarray[$i],2);
		($typename,$typebyte) = split(/:/,$fldtype,2);


		$typename =~ s/vc/VARCHAR/g;
		$typename =~ s/txt/TEXT/g;


		if($typename eq "VARCHAR") {
			$fldtype = "$typename\($typebyte\)";
		} else {
			$fldtype = "$typename";
		}
		
		$query .= "$fldname $fldtype,";
		$fld .= "$fldname,";
	}

	chop($query);
	chop($fld);



	$sth = $dbh->prepare("CREATE TABLE $tname($query)");
	$sth->execute();

	#print "CREATE TABLE $tname($query)";


	#行ごとのＩＮＳＥＲＴループ --------------ここから
	for($i = 0; $i <= $#fdataarray; $i++) {
		$query = "";

		if($fdataarray[$i] eq "") {
			next;
		}

		$fdataarray[$i] = &JE($fdataarray[$i]); #５月追加（重要）

		@tmp = split(/\t/,$fdataarray[$i],$#fldstatarray + 1);



		for($j = 0; $j <= $#tmp; $j++) {
			$tmp[$j] =~ s/_T_/\t/g;
			$tmp[$j] =~ s/_N_/\n/g;
			$query .= "'$tmp[$j]',";
		}

		chop($query);

		#print "<font =\"2\"><b>$i</b>$query</font><br>\n";
		#print "$i INSERT INTO $tname($fld) VALUES ($query)<br>\n";


		$sth = $dbh->prepare("INSERT INTO $tname($fld) VALUES ($query)");
		$sth->execute();

	}
}

#=====================================================================
# [Function		] MakeCSVFileFromTable
# [Contents     ] 指定テーブルから指定キーの指定項目を取得する
#---------------------------------------------------------------------
# [Return       ] (string)strline:CSVデータ文字列
# [Input        ] (string)fname:ファイル名
#				  (string)tname:テーブル名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub MakeCSVFileFromTable {
	local($fname,$tname) = @_;
	local($i,$numRows,$numFields,$fldtype,$fldbyte,$fldlabel,$strline,@field,@fldname,@fldtype,@tmparray);

	#フィールド名をヘッドに挿入
	&ExecSQL("DESC $tname"); #ＳＱＬ文実行
	@fldname = &MakeArrayBySpecCat("Field");

	&ExecSQL("DESC $tname");
	@fldtype = &MakeArrayBySpecCat("Type");

	for($i = 0; $i <= $#fldname; $i++) {

		if($fldname[$i] eq "") {
			$fldname[$i] = "\&nbsp;";
		}

		$fldtype = &GetFieldType(1,$tname,$fldname[$i]);

		# VARCHAR の場合
		if(($fldtype =~ /varchar/)) {
			$fldtype =~ /varchar\((.*)\)/;
			$fldbyte = $1;
			$fldlabel = "$fldname[$i]_vc:$fldbyte";
		}
		#CAHR の場合
		if(($fldtype =~ /char/)) {
			$fldtype =~ /char\((.*)\)/;
			$fldbyte = $1;
			$fldlabel = "$fldname[$i]_vc:$fldbyte";
		}
		# TEXTの場合
		elsif($fldtype =~ /text/) {
			$fldlabel = "$fldname[$i]_txt";
		}

		push(@tmparray,$fldlabel);
	}

	$strline .= (join("\t",@tmparray) . "\n") x 2;


	@tmparray = ();

	&ExecSQL("SELECT * from $tname"); #ＳＱＬ文実行
	$numRows 	= $sth->rows;			#行数
	$numFields 	= $sth->{'NUM_OF_FIELDS'};	#項目数

	#項目に対するバインドをする
	for($i = 1; $i <= $numFields; $i++) {
		$sth->bind_col($i, \$field[$i], undef);
	}


	#メインテーブルを作成する
	while ( $sth->fetch ){

		for($i = 1; $i <= $#field; $i++) {
			#if($field[$i] eq "") {
			#	$field[$i] = "\&nbsp;";
			#}
			#$field[$i] = &ConvHTMLTag($field[$i]);
			$field[$i] =~ s/\r//g;
			$field[$i] =~ s/\n/_N_/g;
			$field[$i] =~ s/\t/_T_/g;
			push(@tmparray,$field[$i]);
		}
		$strline = $strline . join("\t",@tmparray);
		$strline = $strline . "\n";
		@tmparray = ();

		#print "|";
		$len = length($strline);

		if($br++ % 100 eq 0) {
			#print " $len<BR>\n";
		}


		if($len > 30000) {
			&RecordFileData($fname,4,&JS($strline));
			$strline = "";
		}

	} 


	#ファイル書き込み
	&RecordFileData($fname,4,&JS($strline));

	return $strline;


}

#=====================================================================
# [Function		] GetSpecFieldBySpecKeyFromSpecTable
# [Contents     ] 指定テーブルから指定キーの指定項目を取得する
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:該当したデータ文字列
# [Input        ] (string)mode:オプション
#							1:標準
#				  (string)tname:テーブル名
#				  (string)key_fldname:フィールド名
#				  (string)key_fldvalue:フィールドの値
#				  (string)fldname:取得するフィールド名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub GetSpecFieldBySpecKeyFromSpecTable {
	local($mode,$tname,$key_fldname,$key_fldvalue,$fldname) = @_;

	if($mode eq 1) {
		&ExecSQL("SELECT $fldname FROM $tname WHERE $key_fldname = '$key_fldvalue'");

		#変数格納
		$ref = $sth->fetchrow_hashref();
		$strtmp = $ref->{$fldname};
		$rc = $sth->finish;


		return $strtmp;
	}


}

#=====================================================================
# [Function		] GetFieldType
# [Contents     ] 指定項目のフィールドタイプを取得する
#---------------------------------------------------------------------
# [Return       ] (string)fldtype:フィールドのタイプ
# [Input        ] (integer)mode:オプション
#						1:標準
#				  (string)tname:テーブル名
#				  (string)fldname:フィールド名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub GetFieldType {
	local($mode,$tname,$fldname) = @_;
	local($i);

	if($mode eq 1) {
		&ExecSQL("DESC $tname");
		@fldname = &MakeArrayBySpecCat("Field");
		&ExecSQL("DESC $tname");
		@fldtype = &MakeArrayBySpecCat("Type");

		for($i = 0; $i <= $#fldname; $i++) {
			if($fldname[$i] eq $fldname) {
				return $fldtype[$i];
			}
		}

		return "0";
	}
}

#=====================================================================
# [Function		] GetByteFromFieldType
# [Contents     ] 指定フィールドタイプからバイト数を取得する
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:バイト数
# [Input        ] (string)fldtype:フィールドのタイプ
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub GetByteFromFieldType {
	local($fldtype) = @_;

	if($fldtype =~ /varchar/) {
		$fldtype =~ /varchar\((.*)\)/;
		$strtmp = $1;
	}
	elsif($fldtype =~ /text/) {
		$strtmp = 5000;
	}

	return $strtmp;
}

#=====================================================================
# [Function		] MakeStrSETFromHashWithFilter
# [Contents     ] 連想配列を SET 文字列にする（フィルターつき）
#---------------------------------------------------------------------
# [Return       ] SET k=v....の文字列
# [Input        ] (integer)mode:オプション
#				  (string array)remove:SETしないフィールドの配列
#				  (hash)hash:SETする連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub MakeStrSETFromHashWithFilter {
	local($mode,*remove,*hash) = @_;
	local($k,$v);

	while(($k,$v) = each %hash) {
		if(&StringMatchToArray($k,@remove) eq "0") {
			$strtmp .= " $k = '$v',";
		}
	}

	chop($strtmp);

	$strtmp = "SET $strtmp";


	return $strtmp;
}

#=====================================================================
# [Function		] GetRows
# [Contents     ] 行数を取得する
#---------------------------------------------------------------------
# [Return       ] (integer)strtmp:行数
# [Input        ] (string)q:SQLコマンド
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub GetRows {
	local($q) = @_;
	local($strtmp);

	&ExecSQL($q);
	$strtmp = $sth->rows;
	$rc = $sth->finish;

	return $strtmp;
}

#=====================================================================
# [Function		] SetFieldToArray
# [Contents     ] 項目ごとを配列化する
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string array)strarray:項目の配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub SetFieldToArray {
	local(@strarray) = @_;
	local($TMP);

	while ($ref = $sth->fetchrow_hashref()) {
		foreach $TMP (@strarray) {
			push(@{$TMP},$ref->{$TMP});
		}
	}
}

#=====================================================================
# [Function		] IsOverString
# [Contents     ] バイト数を超えてないか確認 (formを参照)
#---------------------------------------------------------------------
# [Return       ] (boolean)1=超えてる,0=超えてない
# [Input        ] (string)tname:テーブル名
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub IsOverString {
	local($tname) = @_;

	#フィールド名をヘッドに挿入
	&ExecSQL("DESC $tname"); #ＳＱＬ文実行
	@fldname = &MakeArrayBySpecCat("Field");
		
	for($i = 0; $i <= $#fldname; $i++) {
		if(length($form{"$fldname[$i]"}) > &GetByteFromFieldType(&GetFieldType(1,$tname,$fldname[$i]))) {
			$pOverString = $fldname[$i];
			return 1;
		}
	}

	return 0;
}

#=====================================================================
# [Function		] GetValueFromSTH
# [Contents     ] sth から指定項目の値を取得
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:modeが1の時は値を返す
# [Input        ] (integer)mode:オプション
#						1:一つの値を取得
#						2:グローバル変数にセットする
#						3:連想配列にセットする
#				  (string)q:項目名
#				  (string array)strarray:項目の配列
#				  (hash)hash:連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub GetValueFromSTH {
	local($mode,$q,*strarray,*hash) = @_;
	local($strtmp);

	if($mode eq 1) {
		$ref = $sth->fetchrow_hashref();
		$strtmp = $ref->{$q};
		$rc = $sth->finish;

		return $strtmp;
	} elsif($mode eq 2) {
		$ref = $sth->fetchrow_hashref();
		foreach $tmp (@strarray) {
			${$tmp} = $ref->{$tmp};
		}
		$rc = $sth->finish;		
	} elsif($mode eq 3) {
		$ref = $sth->fetchrow_hashref();
		foreach $tmp (@strarray) {
			$hash{$tmp} = $ref->{$tmp};
		}
		$rc = $sth->finish;		
	}
}

#=====================================================================
# [Function		] InsertFromHash
# [Contents     ] form 変数を指定テーブルに登録
#---------------------------------------------------------------------
# [Return       ] なし
# [Input        ] (string)tname:テーブル名
#				  (hash)hash:連想配列
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl用
# [Update       ] 
#=====================================================================
sub InsertFromHash {
	local($tname,*hash) = @_;
	local($q,$TMP,$StrSET,@qfld);

	#INSERT文作成
	&ExecSQL("DESC $tname");
	@qfld = &MakeArrayBySpecCat("Field");

	foreach $TMP (@qfld) {
		$StrSET .= "$TMP = \'$hash{$TMP}\',";
	}
	chop($StrSET);

	$q = join("","
		INSERT INTO $tname SET 
			$StrSET
		");


	#登録実行 --------------- ここから
	&ExecSQL($q);
}

#### #    # ####
#    ##   # #   #
#### # #  # #   #
#    #  # # #   #
#### #   ## ####
1;