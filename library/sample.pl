sub strcmp { (shift) cmp (shift) }
sub intcmp { (shift) <=> (shift) }
sub numcmp { $a <=> $b }




########################################
# ＳＱＬ接続
########################################

sub pConnectSQL {

	#ＳＱＬ接続
	if($SQL_CONNECTED ne 1) {
		&ConnectSQL("mysql",$mysql_dbn,$mysql_host,"3306",$mysql_user,$mysql_pass);
		$SQL_CONNECTED = 1;
	} else {
		#&Err001("すでに接続されています。");
	}

}

########################################
# ＳＱＬ初期化
########################################

sub pInit_SQL {

#print &PH;
#print $ENV{'HTTP_HOST'};

	$mysql_dbn = "tomato21";

	if($ENV{'HTTP_HOST'} eq "xxx") {
	}
	elsif($ENV{'HTTP_HOST'} eq "www.tomato21.jp") {
		$mysql_host	= "www.opengate1.com";
		$mysql_user	= "gurumene";
		$mysql_pass	= "mmNp7mj7";
	}
	else {
		$mysql_host	= "localhost";
		$mysql_user	= "kojiro";
		$mysql_pass	= "koji410";
	}

#print $mysql_user;
#exit(0);

}

########################################
#カート初期化
########################################

sub Init_Cart {

	local($tmp01);


	&GetCookie;
	$MyCartFile = "$INI{'GROBAL-CartFilePath'}$COOKIE{'CART-id'}";
	&CheckFileDateAndDelete("hour",$MyCartFile,"1");


	### カートＩＤ及びカートファイル存在確認
	if(($COOKIE{'CART-id'} eq "") || (!(-e $MyCartFile))) {

		#カートを新規に作成する
		$tmp01 = &GetDateString;
		$tmp01 =~ s/://g;
		$COOKIE{'CART-id'} = "c" . $tmp01;

#print &PH;
#print $COOKIE{'CART-id'} . "nomore";

		print &PutCookie("CART","id:$COOKIE{'CART-id'}",$INI{'GROBAL-CookieExpire'});
#exit(0);
		$MyCartFile = "$INI{'GROBAL-CartFilePath'}$COOKIE{'CART-id'}";
	}


	### 商品数カウント 及び 整理---
	#カートファイル読み込み
	$MyCartGx = 0;
	$MyCartGp = 0;
	$StrCartData = &ReadFileData($MyCartFile,3);
	@StrCartDataArray = split(/\n/,$StrCartData);

	@StrCartDataArray = &SortInOne(@StrCartDataArray);

	for($i = 0; $i <= $#StrCartDataArray; $i++) {
		@CurArray = split(/$INI{'GROBAL-StrODJ'}/,$StrCartDataArray[$i]);


		if($CurArray[0] ne "") {
			$MyCartGx++;
			$tmp01 = &GetGoodsPrice($CurArray[0]);
			$MyCartGp = $MyCartGp + $tmp01;
		} else {
			splice(@StrCartDataArray,$i,1);
			$i--;
		}
	}

	#書き込み実行
	&RecordFileData($MyCartFile,1,"",@StrCartDataArray);
}

########################################
# カート情報を取得する
########################################

sub GetCartTable {
	local($mode,$cid) = @_;
	local($i,$j,$strhtml,$Match_Flag,$StrCartData,@tmparray,@StrCartDataArray,@CurArray,$GidArray,@XArray,@OArray);


	#カート情報初期化
	&Init_Cart if($MyCartFile eq "");

	#カートＩＤが指定されていた場合設定する
	$MyCartFile = "$INI{'GROBAL-CartFilePath'}$cid" if($cid ne "");

	#カートファイル読み込み
	$StrCartData = &ReadFileData($MyCartFile,3);
	@StrCartDataArray = split(/\n/,$StrCartData);

	#カートファイルから項目別に配列化する
	for($i = 0; $i <= $#StrCartDataArray; $i++) {
		$Match_Flag = 0;
		@CurArray = split(/$INI{'GROBAL-StrODJ'}/,$StrCartDataArray[$i]);
		for($j = 0; $j <= $#GidArray; $j++) {
			if(($CurArray[0] eq $GidArray[$j]) && ($CurArray[2] eq $OArray[$j])) {
				$XArray[$j] = $XArray[$j] + $CurArray[1];
				$Match_Flag = 1;
				last;
			}
		}

		if($Match_Flag eq "0") {
			push(@GidArray,$CurArray[0]);
			push(@XArray,$CurArray[1]);
			push(@OArray,$CurArray[2]);
		}
	}

	#-------------------------------
	# 注文確認モード
	#-------------------------------
	if($mode eq "1") {



		#変数初期化--------

		&P006;

		$tpl_c1t = &JE(&ReadFileData("html/step02_c1tr.html",3));
		$tpl_oricogoodsinfo = &JE(&ReadFileData("html/oricogoodsinfo.html",3));

		$gSubTotalTotal 	= 0; #小計
		$gGoodsPriceTotal 	= 0; #商品 x 数 の合計
		$gTotalTax		= 0; #消費税
		$gTotalShipment		= 0; #送料
		$gTotalCharge		= 0; #手数料
		$gTotal			= 0; #総計

		#カート内の店舗数初期化
		#@SidArray = &GetSidArrayFromGidArray(@GidArray);
		#@gSidArray = @SidArray;

#print &PH;

		#テーブル作成及び商品ごとの計算処理ループ ********************** ここから
		for($i = 0; $i <= $#GidArray; $i++) {

			#print "aaa<br>";

			#この商品の店舗ＩＤを取得する
			#$sid = &GetSid($GidArray[$i]);


			#商品内容 [1,2,3] をつける
			#$CurGoodsPrice 		= "GoodsPrice$OArray[$i]";
			#$CurGoodsCapacity 	= "GoodsCapacity$OArray[$i]";

			#商品データベースから商品名・価格１を取得する
			&ExecSQL("SELECT * from productstb where master = '$GidArray[$i]'");

			#変数格納
			$ref = $sth->fetchrow_hashref();
			$id 		= $ref->{"id"};
			$brand 		= $ref->{"brand"};
			$category 	= $ref->{"category"};
			$product 	= $ref->{"product"};
			$level 		= $ref->{"level"};
			$size 	= $ref->{"size"};
			$tomatoprice 	= $ref->{"tomatoprice"};
			$rc = $sth->finish;

			$tax = &Round($tomatoprice * $taxfee,0);
			$taxprice = $tomatoprice + $tax;


			#renovate at ITS 2002/4/16 ORICO用にHIDDENを作成する --- ここから
			$NUM = sprintf("%02d",$i + 1);
			$oricotmp = &ConvVal($tpl_oricogoodsinfo);
			$oricotmp =~ s/_NUM/_$NUM/g;
			$oricogoodsinfo .= &JS($oricotmp);
			#renovate at ITS 2002/4/16 ORICO用にHIDDENを作成する --- ここまで


			#店舗小計合計計算
			#$shopsubtotal{$sid} += $SubTotal;


			#小計合計計算
			$gSubTotalTotal 	= $gSubTotalTotal + $tomatoprice;

			#消費税合計計算
			$gTotalTax = $gTotalTax + $tax;
			#$gTotalTax = $gTotalTax + $GoodsPricexTax * $XArray[$i];

			#数値カンマ処理
			$tomatoprice = &ConvPriceComma($tomatoprice);
			$tax = &ConvPriceComma($tax);
			$taxprice = &ConvPriceComma($taxprice);

			$displevel = $level{$level};
			&P005;


			#商品名 - 単価 - 数量 - 消費税 - 小計
			$Cart1Tr .= &ConvVal($tpl_c1t);

#print $strhtml;
			#引数用カート情報文字列
			push(@gStrCartInfoArray,"$GidArray[$i]");
		}
		#テーブル作成及び商品ごとの計算処理ループ ********************** ここまで


		#手数料処理 --------------------------------
		&SetChargeByPayment($payway);

		#送料処理 ----------------------------------

		#%shipment = &InitHashFromTable(1,"areatb","id","postage");

		#if($shipment{$sendtoaddress1} eq "1") {
			$gTotalShipment = 1000;
		#} else {
		#	$gTotalShipment = 500;
		#}


		#もし、campaign_rule以上の場合は送料を無料にする
		if($gSubTotalTotal >= $INI{"GROBAL-campaign_rule"}) {
			$gTotalShipment = 0;
			$carriage = $form{"carriage"} = 0;
		} else {
			$carriage = $form{"carriage"} = $INI{"GROBAL-carriage_fee"};
		}



		#ポイント処理 ------------------------------

		#$form{'pointrate'} = $pointrate = &ReadFileData("$INI{'GROBAL-RegiFilePath'}pointrate",3);
		#$disppointrate = $pointrate * 100;

		#if($form{'pointusepoint'} eq "") {
		#	$pointusepoint = "0";
		#}
	
		#if($form{'pointbefore'} eq "") {
		#	$form{'pointbefore'} = $pointbefore = 0;
		#}
	
		#$form{'pointnow'} = $pointnow = $pointbefore - $pointusepoint;
		#$form{'pointadd'} = $pointadd = $gSubTotalTotal * $pointrate;
		#$form{'pointnext'} = $pointnext = $pointnow + $pointadd;




		#合計処理 ----------------------------------
		#$gGoodsPriceTotal = $gSubTotalTotal;
		#$gTotal = $gSubTotalTotal + $gTotalTax + $gTotalShipment + $gTotalCharge - $pointusepoint;
		$gTotal = $gSubTotalTotal + $gTotalTax + $carriage;


		#&Err002("$form{'UserID'}");
















		#グローバル変数を%formに格納 ---------------
		$form{"gGoodsPriceTotal"} 	= $gGoodsPriceTotal;
		$form{"gTotal"} 		= $gTotal;
		$form{"gTotalTax"} 		= $gTotalTax;
		$form{"gTotalShipment"} 	= $gTotalShipment;
		$form{"gTotalCharge"} 		= $gTotalCharge;
		$form{"gOrdercfmMsg"} 		= $gOrdercfmMsg;

		$form{"orderamount"} 		= $MyCartGx;
		$form{"sumproducts"} 		= $gSubTotalTotal;
		$form{"sumtax"} 		= $gTotalTax;
		#$form{"carriage"} 		= $gTotalShipment;
		$form{"daibiki"} 		= $gTotalCharge;
		$form{"sumorder"} 		= $gTotal;


		$pgTotal 		= $gTotal;
		$pgGoodsPriceTotal 	= $gGoodsPriceTotal;
		$pgSubTotalTotal 	= $gSubTotalTotal;
		$pgTotalTax 		= $gTotalTax;
		$pgTotalShipment 	= $gTotalShipment;
		$pgTotalCharge 		= $gTotalCharge;



		#数値カンマ処理 ----------------------------
		$gTotal 		= &ConvPriceComma($gTotal);
		$gGoodsPriceTotal 	= &ConvPriceComma($gGoodsPriceTotal);
		$gSubTotalTotal 	= &ConvPriceComma($gSubTotalTotal);
		$gTotalTax 		= &ConvPriceComma($gTotalTax);
		$gTotalShipment 	= &ConvPriceComma($gTotalShipment);
		$gTotalCharge 		= &ConvPriceComma($gTotalCharge);
		$TMP_gSubTotalTotal 	= &ConvPriceComma($TMP_gSubTotalTotal);

		#カート情報を一つの文字列にまとめる --------
		$form{"gStrCartInfo"} = $gStrCartInfo = join(",",@gStrCartInfoArray);
		$form{'orderproducts'} = $form{"gStrCartInfo"};

		$strhtml = $Cart1Tr;



		return $strhtml;
	}
	#-------------------------------
	# メールモード
	#-------------------------------
	elsif($mode eq "2") {

		&P006;
		$tpl_c1t = &JE(&ReadFileData("html/ordercfmmail_cartinfo.txt",3));



		#ＳＱＬ接続
		&pConnectSQL;


		#テーブル作成
		for($i = 0; $i <= $#GidArray; $i++) {

			#$CurGoodsPrice = "GoodsPrice$OArray[$i]";
			#$CurGoodsCapacity = "GoodsCapacity$OArray[$i]";

			#商品データベースから商品名・価格１を取得する
			&ExecSQL("SELECT * from productstb where master = '$GidArray[$i]'");

			#変数格納
			$ref = $sth->fetchrow_hashref();
			$id 		= $ref->{"id"};
			$brand 		= $ref->{"brand"};
			$category 	= $ref->{"category"};
			$product 	= $ref->{"product"};
			$level 		= $ref->{"level"};
			$tomatoprice 	= $ref->{"tomatoprice"};

			$tax = &Round($tomatoprice * $taxfee,0);

			$rc = $sth->finish; 




			&P005;


			#商品名 - 単価 - 数量 - 消費税 - 小計
			$strhtml .= &ConvVal($tpl_c1t);


			#引数用カート情報文字列
			push(@gStrCartInfoArray,"$GidArray[$i]:$XArray[$i]");

			push(@gGidArray,$GidArray[$i]);
		}


		#ＳＱＬ切断
		&DisconnectSQL;

		return $strhtml;


	}
	#-------------------------------
	# カートモード
	#-------------------------------
	elsif($mode eq "3") {

		#変数初期化
		$tpl_c1t = &JE(&ReadFileData("html/c1tr.html",3));
		$Gmax = $#GidArray;
		$SubTotalTotal 	= 0;
		$gTotalTax	= 0;
		$gTotalShipment = 0;
		$carriage	= 0;
		$SubTotal	= 0;


		#ＳＱＬ接続
		&pConnectSQL;


		&P006;




		#カート内の店舗数初期化
		#@SidArray = &GetSidArrayFromGidArray(@GidArray);

		#テーブル作成
		for($i = 0; $i <= $#GidArray; $i++) {


			$tmp01 = $tpl_c1t;

			#$CurGoodsPrice = "GoodsPrice$OArray[$i]";
			#$CurGoodsCapacity = "GoodsCapacity$OArray[$i]";
			&ExecSQL("SELECT * from productstb where master = '$GidArray[$i]'");

			$ref = $sth->fetchrow_hashref();
			$brand 		= $ref->{"brand"};
			$category 	= $ref->{"category"};
			$product 	= $ref->{"product"};
			$level 		= $ref->{"level"};
			$tomatoprice 	= $ref->{"tomatoprice"};

			$SubTotal 	= $SubTotal + $tomatoprice;
			$SubTotalTotal 	= $SubTotalTotal + $tomatoprice;
			$rc = $sth->finish;




			#消費税合計計算
			$GoodsPricexTax = &Round($tomatoprice * $taxfee,0);
			$gTotalTax = $gTotalTax + $GoodsPricexTax;

			#数値カンマ処理
			$tomatoprice = &ConvPriceComma($tomatoprice);
			#$SubTotal = &ConvPriceComma($SubTotal);

			$x = $XArray[$i];
			$o = $OArray[$i];
			$master = $GidArray[$i];
			$displevel = $level{$level};

			&P005;


			$CartTr .= &ConvVal($tmp01);
		}


		#もし、campaign_rule以上の場合は送料を無料にする
		if($SubTotal >= $INI{"GROBAL-campaign_rule"} or $SubTotal eq 0) {
			$carriage = 0;
		} else {
			$carriage = $form{"carriage"} = $INI{"GROBAL-carriage_fee"};
		}


		$campaignrule = &ConvPriceComma($campaignrule);


		#合計処理
		$SubTotalTotal = $SubTotalTotal + $gTotalTax + $carriage;


		#数値カンマ処理
		$SubTotal = &ConvPriceComma($SubTotal);
		$SubTotalTotal = &ConvPriceComma($SubTotalTotal);
		$gTotalTax = &ConvPriceComma($gTotalTax);
		$gTotalShipment = &ConvPriceComma($gTotalShipment);
		$carriage = &ConvPriceComma($carriage);


		$strhtml = &ConvVal(&JE(&ReadFileData("html/c1t.html",3)));

		#ＳＱＬ切断
		&DisconnectSQL;

		return $strhtml;

	}

	#-------------------------------
	# 注文途中モード
	#-------------------------------
	elsif($mode eq "3B") {

		#変数初期化
		$tpl_c1t = &JE(&ReadFileData("html/step02_c1tr.html",3));
		$Gmax = $#GidArray;
		$SubTotalTotal 	= 0;
		$gTotalTax	= 0;
		$gTotalShipment = 0;
		$carriage	= 0;

		#ＳＱＬ接続
		&pConnectSQL;


		&P006;




		#カート内の店舗数初期化
		#@SidArray = &GetSidArrayFromGidArray(@GidArray);

		#テーブル作成
		for($i = 0; $i <= $#GidArray; $i++) {


			$tmp01 = $tpl_c1t;

			#$CurGoodsPrice = "GoodsPrice$OArray[$i]";
			#$CurGoodsCapacity = "GoodsCapacity$OArray[$i]";
			&ExecSQL("SELECT * from productstb where master = '$GidArray[$i]'");

			$ref = $sth->fetchrow_hashref();
			$id 		= $ref->{"id"};
			$brand 		= $ref->{"brand"};
			$category 	= $ref->{"category"};
			$product 	= $ref->{"product"};
			$level 		= $ref->{"level"};
			$size 	= $ref->{"size"};
			$tomatoprice 	= $ref->{"tomatoprice"};

			$SubTotal 	= $SubTotal + $tomatoprice;
			$SubTotalTotal 	= $SubTotalTotal + $tomatoprice;
			$rc = $sth->finish;




			#消費税合計計算
			$GoodsPricexTax = &Round($tomatoprice * $taxfee,0);
			$gTotalTax = $gTotalTax + $GoodsPricexTax;

			#数値カンマ処理
			$tomatoprice = &ConvPriceComma($tomatoprice);
			#$SubTotal = &ConvPriceComma($SubTotal);

			$x = $XArray[$i];
			$o = $OArray[$i];
			$master = $GidArray[$i];


			$displevel = $level{$level};

			&P005;


			$CartTr .= &ConvVal($tmp01);
		}


		#もし、campaign_rule以上の場合は送料を無料にする
		if($SubTotal >= $INI{"GROBAL-campaign_rule"}) {
			$carriage = 0;
		} else {
			$carriage = $form{"carriage"} = $INI{"GROBAL-carriage_fee"};
		}



		#合計処理
		$SubTotalTotal = $SubTotalTotal + $gTotalTax + $carriage;


		#数値カンマ処理
		$SubTotal = &ConvPriceComma($SubTotal);
		$SubTotalTotal = &ConvPriceComma($SubTotalTotal);
		$gTotalTax = &ConvPriceComma($gTotalTax);
		$carriage = &ConvPriceComma($carriage);


		$strhtml = $CartTr;

		#ＳＱＬ切断
		&DisconnectSQL;

		return $strhtml;

	}

	#-------------------------------
	# ＦＡＸモード
	#-------------------------------
	elsif($mode eq "4") {

		#カート内の店舗数初期化
		@SidArray = &GetSidArrayFromGidArray(@GidArray);

		#テーブル作成
		for($i = 0; $i <= $#GidArray; $i++) {

			#指定店舗でなければ次へ
			#if($GidArray[$i] !~ /^$form{'sid'}/) {
			#	next;
			#}

			$CurGoodsPrice = "GoodsPrice$OArray[$i]";
			$CurGoodsCapacity = "GoodsCapacity$OArray[$i]";


			#商品データベースから商品名・価格１を取得する
			&ExecSQL("SELECT * from $INI{'GROBAL-GDBName'} where GoodsID = '$GidArray[$i]'");

			#変数格納
			$ref = $sth->fetchrow_hashref();
			$GoodsName 	= $ref->{"GoodsName"};
			$GoodsCapacity 	= $ref->{$CurGoodsCapacity};
			$GoodsPrice 	= $ref->{$CurGoodsPrice};
			$SubTotal 	= $GoodsPrice * $XArray[$i];
			$gSubTotalTotal 	= $gSubTotalTotal + $SubTotal;
			$rc = $sth->finish;

			#消費税合計計算
			$GoodsPricexTax = &Round($GoodsPrice * $taxfee,0);
			$gTotalTax = $gTotalTax + $GoodsPricexTax * $XArray[$i];

			#数値カンマ処理
			$GoodsPrice = &ConvPriceComma($GoodsPrice);
			$SubTotal = &ConvPriceComma($SubTotal);


			#お酒ならば個数と小計を表示しない
			if($form{'step'} eq "o1s") {
				$XArray[$i] = "\&nbsp;";
				$SubTotal = "\&nbsp;";
			}


			#商品名 - 単価 - 数量 - 消費税 - 小計
			$strhtml .= join("","
				<tr>
				<td $ac> \&nbsp; </td>
				<td $ac>$GoodsName ($GoodsCapacity)</td>
				<td $ac>$GoodsPrice円</td>
				<td $ac> $XArray[$i] </td>
				<td $ac> $SubTotal </td>
				</tr>
				");

			#引数用カート情報文字列
			push(@gStrCartInfoArray,"$GidArray[$i]:$XArray[$i]:$OArray[$i]");
		}


		#手数料処理
		&SetChargeByPayment($form{'Payment'});



		#送料処理
		$gTotalShipment = &GetShipmentByGidxSidArray(*GidArray,*SidArray);



		#合計処理
		$gGoodsPriceTotal = $gSubTotalTotal;
		$gSubTotalTotal = $gSubTotalTotal + $gTotalTax + $gTotalShipment + $gTotalCharge;


		#グローバル変数を%formに格納
		$form{"gGoodsPriceTotal"} = $gGoodsPriceTotal;
		$gTotal = $form{"gTotal"} = $gSubTotalTotal;
		$form{"gTotalTax"} = $gTotalTax;
		$form{"gTotalShipment"} = $gTotalShipment;
		$form{"gTotalCharge"} = $gTotalCharge;
		$form{"gOrdercfmMsg"} = $gOrdercfmMsg;


		#数値カンマ処理
		$gTotal = &ConvPriceComma($gTotal);
		$gGoodsPriceTotal = &ConvPriceComma($gGoodsPriceTotal);
		
		$gSubTotalTotal = &ConvPriceComma($gSubTotalTotal);
		$gTotalTax = &ConvPriceComma($gTotalTax);
		$gTotalShipment = &ConvPriceComma($gTotalShipment);
		$gTotalCharge = &ConvPriceComma($gTotalCharge);

		$gStrCartInfo = join($INI{'GROBAL-StrODJ'},@gStrCartInfoArray);

		return $strhtml;


	}
}


########################################
# 検索イベント初期化
########################################

sub Init_Search {

	#ＪＳ初期化
	$JS = &ConvVal(&JE(&ReadFileData("html/SEARCH_JS.txt",3)));

	#検索ボックス表示用 $q 初期化
	if(($form{'act'} eq "area") || ($form{'act'} eq "cat")) {
		$q = "";
	} else {
		$q2 = $form{'q'};
	}

	#表示用クエリー初期化
	$form{'disp_q'} = $form{'q'};


	#検索表示数初期化
	if($form{'l'} eq "" and $form{'pl'} eq "") {
		$form{'l'} = 6;
	} elsif($form{'pl'} ne "") {
		$form{'l'} = $form{'pl'};
	} else {
		$form{'l'} = $form{'l'};
	}

	#検索開始位置初期化
	if($form{'st'} eq "") {
		$form{'st'} = 0;
		#表示用開始位置初期化
		$form{'disp_st'} = 1;
	} else {
		$form{'disp_st'} = $form{'st'};
	}

	#次の検索開始位置
	$form{'n_st'} 	= $form{'st'} + $form{'l'}; 

	#前の検索開始位置
	$form{'p_st'} = $form{'st'} - $form{'l'};

	#検索終了位置初期化
	$form{'en'} = $form{'st'} + $form{'l'};

	#ＯＲＤＥＢＹ文作成
	$q_orderby = "ORDER BY RAND()";


	#ＬＩＭＩＴ文作成
	$q_limit = "LIMIT $form{'st'},$form{'l'}";

	#キーワードをＵＲＬエンコードする
	$form{'q_encoded'} = &URLEncode($form{'q'});

	if($form{'m'} eq "") {
		$form{'m'} = "default";
	}


	#検索モードSelection 場所初期化
	while(($k,$v) = each %form) {
		if($k eq "m") {
			${"Fm$v"} = "selected";
		}
	}

}


########################################
# form 連想配列に検索一致数を代入する
########################################

sub SetFmc {
	local($q) = @_;

	if($form{'mc'} eq "") {
		#検索一致数取得
		$form{'mc'} = &GetRows($q);
	}

}

#====================================================================================[プロセス]======
#★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
#====================================================================================================

########################################
# プロセス番号 002　　honma変更あり
########################################

sub P002 {

	local($i,$strhtml,$tmp01,$tmp02,$tmp03,$tpl_TABLE1);

	#------------------------------------------------------------
	#検索の大事な部分（まとめた配列を加工する）
	#
	# 必要変数
	# @GoodsID
	# @GoodsName
	# @GoodsPrice
	# @GoodsCatch
	#
	#------------------------------------------------------------

	# 前処理 ---------------ここから

	@makerprice = grep { $_ = &ConvPriceComma($_) } @makerprice;
	@tomatoprice = grep { $_ = &ConvPriceComma($_) } @tomatoprice;

	# 前処理 ---------------ここまで


	################################
	#『標準モード
	################################

	if($form{'m'} eq "default") {


		#テンプレート初期化
		$tpl_TABLE1	= &JE(&ReadFileData("html/searchresult1t.html",3));
		$tpl_TR1	= &JE(&ReadFileData("html/searchresult1tr.html",3));

		$cnt = 0;
		$tmp01 = $tpl_TR1;





		#小テーブル作成ループ
		for($i = 0; $i <= $#master; $i++) {

			#変数準備 ---
			foreach(@qfld) {
				${$_} = ${$_}[$i];
			}

			#renovate at ITS 2002/01/21 K.Hamada 検索画面が表示されないのでcommentのみEUC変換する 後で削除したほうがいい
			#$comment = &JE($comment);


			$prevmaster = $master[$i - 1]; 
			$nextmaster = $master[$i + 1]; 

			$level = $level{$level};


			&P005;

			$searchresult1tr .= &ConvVal($tmp01);


		}


		$searchresult1t = &ConvVal($tpl_TABLE1);



	}

	################################
	#『テキストモード』
	################################

	elsif($form{'m'} eq "text") {

		for($i = 0; $i <= $#GoodsID; $i++) {
			$tmp01 = &Parapara($INI{'GROBAL-Paraparacolor'});
			$naiyou .= join("","
				<tr bgcolor=\"$tmp01\">
				 <td width=\"30%\"><img src=\"../images/shikaku.gif\">  <a href=\"$ThisFile?act=s1g\&gid=$GoodsID[$i]\">$GoodsName[$i]</a>  </td>
				 <td width=\"60%\"><img src=\"../images/sankaku.gif\">  $GoodsCatch[$i] </td>
				 <td width=\"10%\" $ar>$GoodsPrice[$i]円</td>
				</tr>
				");
		}

		$naiyou = join("","
			<table class=\"sit\" border=\"0\" width=\"95%\" $ac $cp{'6'} $cs{'2'}>
			<tr bgcolor=\"#FFA586\">
			<td $ac> 商品名</td>
			<td $ac> キャッチコピー </td>
			<td $ac> 価格</td>
			</tr>
			$naiyou
			</table>
			");




		$K = &ConvVal(&JE(&ReadFileData("html/kat.html",3)));

	}

	################################
	#『画像モード』
	################################

	elsif($form{'m'} eq "pic") {

		$tpl_TR1	= &JE(&ReadFileData("html/searchresult1tr_pic.html",3));




		for($i = 0; $i <= $#master; $i++) {

			#変数準備 ---
			foreach(@qfld) {
				${$_} = ${$_}[$i];
			}

			&P005;


			$level = $level{$level};
			$levelcol = $levelcol{$level};

			if($i % 3 eq 0) {
				$searchresult1tr .= "<tr>";
			}

			$searchresult1tr .= "<td>" . &ConvVal($tpl_TR1) . "</td>";

			#if($i % 3 eq 0) {
			#	$searchresult1tr .= "<td width=\"20\">\&nbsp;</td>";
			#}

			if($i ne 0 and ($i + 1) % 3 eq 0) {
				$searchresult1tr .= "</tr>\n";
			}

		}
		

		$searchresult1t = "<center><table border='0'>" . $searchresult1tr . "</table></center>";



	}
}

########################################
# プロセス番号 003  honma変更あり
########################################

sub P003 {
	local($i);


	@makerprice = grep { $_ = &ConvPriceComma($_) } @makerprice;
	@tomatoprice = grep { $_ = &ConvPriceComma($_) } @tomatoprice;



	#変数準備 ---
	foreach(@qfld) {
		${$_} = ${$_}[$i];
	}

	&P005;

	#$marks =~ s/_a/_b/g;
	#$flag =~ s/_a/_b/g;


	$level = $level{$level};
	$levelcol = $levelcol{$level};


	if($form{'photonum'} eq "") {
		$photo = $photo1;
	} else {
		$tmp01 = "photo" . $form{'photonum'};
		$photo = ${$tmp01};
	}

	if($ENV{"HTTP_REFERER"} =~ /medama/ or $COOKIE{'FLAG-frommedama'} eq "1") {

		if($COOKIE{'FLAG-frommedama'} eq "0") {
			print &PutCookie("FLAG","frommedama:1",$INI{'GROBAL-CookieExpire'});
		}

		$return = "$ThisFile?act=medama";
		$pmedama = "medama";
	} else {

		#renovate at ITS 2002/01/22 K.Hamada 一覧に戻るの検索条件をフルにする
		#$return = "$ThisFile?act=\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}";
		$return = "$ThisFile?act=\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}\&brand=$form{'brand'}\&category=$form{'category'}\&level=$form{'level'}\&status=$form{'status'}\&pricemin=$form{'pricemin'}\&pricemax=$form{'pricemax'}";
		$pmedama = "";
	}


	#renovate at ITS 2002/01/22 K.Hamada 拡大写真を押しても一覧に戻れるようにする
	#$showphoto1 = "$ThisFile?act=s1g\&mid=$form{'mid'}\&photonum=1";
	#$showphoto2 = "$ThisFile?act=s1g\&mid=$form{'mid'}\&photonum=2";
	$showphoto1 = "$ThisFile?act=s1g\&dum=$pmedama\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}\&mid=$form{'mid'}\&brand=$form{'brand'}\&category=$form{'category'}\&level=$form{'level'}\&status=$form{'status'}\&pricemin=$form{'pricemin'}\&pricemax=$form{'pricemax'}\&photonum=1";
	$showphoto2 = "$ThisFile?act=s1g\&dum=$pmedama\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}\&mid=$form{'mid'}\&brand=$form{'brand'}\&category=$form{'category'}\&level=$form{'level'}\&status=$form{'status'}\&pricemin=$form{'pricemin'}\&pricemax=$form{'pricemax'}\&photonum=2";




	#renovate at ITS 2002/01/22 K.Hamada 次・前の商品がない場合はボタンを表示しない
	if($form{'pmid'} ne "") {
		$ps1g = "$ThisFile?act=s1g\&dum=$pmedama\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}\&mid=$form{'pmid'}\&brand=$form{'brand'}\&category=$form{'category'}\&level=$form{'level'}\&status=$form{'status'}\&pricemin=$form{'pricemin'}\&pricemax=$form{'pricemax'}";
	} else {
		$ps1gcos = "<!--";
		$ps1gcoe = "-->";
	}

	if($form{'nmid'} ne "") {
		$ns1g = "$ThisFile?act=s1g\&dum=$pmedama\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}\&mid=$form{'nmid'}\&brand=$form{'brand'}\&category=$form{'category'}\&level=$form{'level'}\&status=$form{'status'}\&pricemin=$form{'pricemin'}\&pricemax=$form{'pricemax'}";
	} else {
		$ns1gcos = "<!--";
		$ns1gcoe = "-->";
	}


	#カートの確認リンク ---
	#カートの内容文字列作成 ---
	if($MyCartGx eq 0) {
	#	$viewcart = "#";
		$viewcart = "cart.cgi?act=viewcart";
		#$cartcomment = "現在買い物カゴには何も入っていません";
	} else {
		if((-e "$MyCartFile\.tmp")) {
			&RecordFileData($MyCartFile,3,"");
		} else {
			$cartcomment = "買い物カゴには現在 $MyCartGx個 の商品が入っています。合計金額は" . &ConvPriceComma($MyCartGp) . "円です。";
			$cartcommenttable = &ConvVal(&JE(&ReadFileData("html/cartcommenttable.html",3)));
		}

		$viewcart = "cart.cgi?act=viewcart";
	}


	#売約の場合『売約』の画像にする
	if($soldout eq 1) {
		$BuyButton = "<img src=\"/images/system/baiyaku.gif\" width=\"153\" height=\"28\">";
	#まだの場合は買えるようにする
	} else {
		$BuyButton = "<a href=\"cart.cgi?act=add&mid=$mid\" onMouseOut=\"MM_swapImgRestore()\" onMouseOver=\"MM_swapImage('get1','','/images/system/get2.gif',1)\"><img name=\"get1\" border=\"0\" src=\"/images/system/get.gif\" width=\"153\" height=\"28\" alt=\"この商品を購入する\"></a>";
	}



	$P003 = &ConvVal(&JE(&ReadFileData("html/productdetail.html",3)));

	# ####返値の判定
	if($gP003_RETURN) { 
		return $P003;
	} else {
		print $P003;
	}

}

sub P005 {

	#status 作成 ----
	$status =~ s/"//g;
	@s = ();
	if($status =~ /,/) {
		@s = split(/,/,$status);
	} else {
		push(@s,$status);
	}
	$marks = "";
	for($j = 0; $j <= $#s; $j++) {
		$marks .= "<img src=\"/images/icon/status/$s[$j].gif\"> ";
	}

	#category
	$category = $category{$category};
	#brand
	$brand = $brand{$brand};

	#flag
	if($soldout eq "1") {
		$flag = "<img src=\"/images/icon/soldout/1.gif\"> ";
	} elsif($soldout eq "2") {
		$flag = "<img src=\"/images/icon/soldout/2.gif\"> ";
	} elsif($soldout eq "0") {
		$flag = "<img src=\"/images/icon/soldout/sim.gif\"> ";
	} else {
		$flag = "";
	}
	

	#offer
	if($offer eq "1") {
		$offer = "<img src=\"/images/icon/offer.gif\"> ";
	} elsif($offer eq "0") {
		$offer = "<img src=\"/images/icon/sim.gif\"> ";
	} else {
		$offer = "<img src=\"/images/icon/sim.gif\"> ";
	}



	#level
	$levelcol = $levelcol{$level};



	$curdate = &GetSpecDateString(time,"year") . "/" . &GetSpecDateString(time,"mon") . "/" . &GetSpecDateString(time,"mday");
	$dif = &ConvDateToNum(1,$curdate) - &ConvDateToNum(1,$publicday);
	if($dif <= $new) {
		$flag = "<img src=\"/images/icon/new/1.gif\">";
	}



	#s1g
	$s1g = "$ThisFile?act=s1g\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}\&mid=$master\&brand=$form{'brand'}\&category=$form{'category'}\&level=$form{'level'}\&status=$form{'status'}\&pricemin=$form{'pricemin'}\&pricemax=$form{'pricemax'}";

}



sub P006 {


	%category = &InitHashFromTable(1,"categorytb","categoryid","category");


	%brand = &InitHashFromTable(1,"brandtb","brandid","japanese");
	%level = &InitHashFromTable(1,"leveltb","levelid","level");
	%levelcol = &InitHashFromTable(1,"leveltb","level","color");


	#%status = &InitHashFromTable(1,"statustb","statusid","comment");
	%soldout = &InitHashFromTable(1,"soldouttb","id","sallstatus");




}



sub GetCurTime {

	return time;

}



########################################
# 新しい注文ＩＤを作成する
########################################

sub GetNewOrderNumber {
	local($cur_time,$cur_y,$oy,$om,$od,$on,$oid);

	$cur_time = &GetCurTime; #アメリカ時間から日本時間に訂正

	$cur_y = &GetSpecDateString($cur_time,"year");
	$oy = $cur_y;
	$om = &GetSpecDateString($cur_time,"mon");
	$od = &GetSpecDateString($cur_time,"mday");

	$tmpoid = $oy . $om . $od;

	$q = "SELECT orderid FROM orderinfotb WHERE orderid LIKE '$tmpoid%' ORDER BY orderid DESC";

	&ExecSQL($q);

	$last_oid = &GetValueFromSTH(1,"orderid");
	($dum,$on) = $last_oid =~ /(........)(....)/;

	if($on eq "") {
		$on = "1";
	} else {
		$on++;
	}

	$on = sprintf("%04d",$on);
	$oid = $oy . $om . $od  . $on;

	return $oid;
}


########################################
# 新しい予約ＩＤを作成する
########################################

sub GetNewMLNumber {
	local($cur_time,$cur_y,$oy,$om,$od,$on,$oid);



	$q = "SELECT mailingid FROM maillisttb ORDER BY mailingid DESC";

	&ExecSQL($q);

	$last_oid = &GetValueFromSTH(1,"mailingid");
	($dum,$on) = $last_oid =~ /(..)(......)/;

	if($on eq "") {
		$on = "1";
	} else {
		$on++;
	}

	$on = sprintf("%06d",$on);
	$oid = "ml" . $on;

	return $oid;
}



########################################
# 新しい予約ＩＤを作成する
########################################

sub GetNewReserveNumber {
	local($cur_time,$cur_y,$oy,$om,$od,$on,$oid);



	$q = "SELECT reserveid FROM reservetb ORDER BY reserveid DESC";

	&ExecSQL($q);

	$last_oid = &GetValueFromSTH(1,"reserveid");
	($dum,$on) = $last_oid =~ /(.)(.....)/;

	if($on eq "") {
		$on = "1";
	} else {
		$on++;
	}

	$on = sprintf("%05d",$on);
	$oid = "r" . $on;

	return $oid;
}


########################################
# カートの中身を計算する
########################################

sub RecalcMyCart {
	local($i,$StrCartData);

	#カート情報初期化
	&Init_Cart if($MyCartFile eq "");

	for($i = 0; $i <= $form{'g_max'} - 1; $i++) {

		if($form{"g$i"} !~ /^\d/) {
			#&Err001("数字を入力して下さい");
		} else {
			$StrCartData .= join($INI{'GROBAL-StrODJ'},$form{"g$i"},$form{"x$i"},$form{"o$i"});
			$StrCartData .= "\n";
		}
	}

	&RecordFileData($MyCartFile,3,$StrCartData);
}



########################################
# エラーメッセージ出力関数
########################################

sub Err001 {

	local($msg) = @_;

	$K = &MakeTempLabel($msg);
	&PB;
	exit(0);

}

########################################
# 管理イベント 初期化
########################################

sub Init_Admin {


	#ログ保存 --------------------------
	#renovate at ITS 2002/01/16 K.Hamada トマトの場合ログは残さない
	#&MakeAccessLog(1,$INI{'GROBAL-StrODJ'},"=",$INI{'GROBAL-AdminLogFile'},*form);



	#認証処理 --------------------------

		&GetCookie;

		$MyAdminFile = "$INI{'GROBAL-AdminFilePath'}$COOKIE{'ADMIN-id'}";
		#&CheckFileDateAndDelete("hour",$MyAdminFile,"1.2"); #１０分前のファイルなら削除する

		$StrAdmin = &ReadFileData($MyAdminFile,3);
		($MyAdminID,$MyAdminPS) = split(/$INI{"GROBAL-StrODJ"}/,$StrAdmin);

		#ＳＱＬ接続 ▼▼▼▼▼▼▼
		&pConnectSQL;

		$q = "SELECT * FROM admintb WHERE AdminID = \'$MyAdminID\' AND AdminPS = \'$MyAdminPS\'";

		if(&GetRows($q) eq "0") {
			$Match_Flag = 0;
		} else {
			$Match_Flag = 1;
		}

		#ＳＱＬ切断 ▲▲▲▲▲▲▲
		&DisconnectSQL;


		if($Match_Flag) {
			if(($form{"act"} eq "") || ($form{"act"} eq "login")) {
				$form{"act"} = "menu";
			}
		} else {
			if(($form{"act"} eq "") || ($form{"act"} eq "login")) {
			} else {
				&Err001("もう一度ログインしてください<p> <a href=\"$ThisFile\">ログイン画面</a>");
			}
		}



	#一覧表示用変数 --------------------------


	#検索表示数初期化
	if($form{'l'} eq "") {
		$form{'l'} = 20;
	} else {
		$form{'l'} = $form{'l'};
	}

	#検索開始位置初期化
	if($form{'st'} eq "") {
		$form{'st'} = 0;
		#表示用開始位置初期化
		$form{'disp_st'} = 1;
	} else {
		$form{'disp_st'} = $form{'st'};
	}

	#次の検索開始位置
	$form{'n_st'} 	= $form{'st'} + $form{'l'}; 

	#前の検索開始位置
	$form{'p_st'} = $form{'st'} - $form{'l'};

	#検索終了位置初期化
	$form{'en'} = $form{'st'} + $form{'l'};

	#ＬＩＭＩＴ文作成
	$q_limit = "LIMIT $form{'st'},$form{'l'}";

	#グローバル変数 --------------------------

	$Title = "トマト - 管理画面";

}

########################################
# 注文イベント初期化
########################################

sub Init_Order {

	local(@strarray,%hash);


	#そのまま返す (重要)!!!
	return 1;


	&GetCookie;
	$MyRegiFile = "$INI{'GROBAL-RegiFilePath'}$COOKIE{'REGI-id'}";
	&CheckFileDateAndDelete("hour",$MyRegiFile,"0.5");

	### カートＩＤ及びカートファイル存在確認
	if(($COOKIE{'REGI-id'} eq "") || (!(-e $MyRegiFile))) {
		#カートを新規に作成する
		$tmp01 = &GetDateString;
		$tmp01 =~ s/://g;
		$COOKIE{'REGI-id'} = "r" . $tmp01;
		print &PutCookie("REGI","id:$COOKIE{'REGI-id'}",$INI{'GROBAL-CookieExpire'});

		$MyRegiFile = "$INI{'GROBAL-RegiFilePath'}$COOKIE{'REGI-id'}";
	}

	%form_bak = %form;


	if($form{'resetflag'} eq "1") {
		#&Err001("reset");
		&ResetForm;
		$form{'resetflag'} = "0";
	}
	

	%hash = &MakeHashFromString(1,&ReadFileData($MyRegiFile,3),$INI{'GROBAL-StrODJ'}," <> ");


	foreach $TMP (keys(%form)) {
		$hash{$TMP} = $form{$TMP};
	}



	foreach $TMP (keys(%hash)) {
		$form{$TMP} = $hash{$TMP};
	}


	while(($k,$v) = each %hash) {
		$v =~ s/\r//g;
		$v =~ s/\n/_N_/g;
		#空ならばファイルに保存しない（デバグ）
		if($v ne "") {
			push(@strarray,"$k <> $v");
		}
	}
	$cdata = join($INI{'GROBAL-StrODJ'},@strarray);

	#書き込み実行
	&RecordFileData($MyRegiFile,3,$cdata);

	chmod 0707, $MyRegiFile;


	&MakeHashFromString(2,&ReadFileData($MyRegiFile,3),$INI{'GROBAL-StrODJ'}," <> ","REGI");

}

########################################
# メンバーイベント初期化
########################################

sub Init_Member {

	#認証処理 --------------------------

	&GetCookie;
	
	$MyMemberFile = "$INI{'GROBAL-MemberFilePath'}$COOKIE{'MEMBER-id'}";
	#&CheckFileDateAndDelete("hour",$MyMemberFile,"0.2"); #１０分前のファイルなら削除する

	$StrMember = &ReadFileData($MyMemberFile,3);
	($MyUserID,$MyUserPS) = split(/$INI{"GROBAL-StrODJ"}/,$StrMember);

	$MyAddressBookFile = $INI{'GROBAL-AddressBookFilePath'} . $INI{'GROBAL-AddressBook_Intl'} . $MyUserID;
}

########################################
# カートに商品を追加する
########################################

sub PutGoodsToMyCart {



	#追加文字列作成
	$INI{'GROBAL-StrODJ'} =~ s/"//g;
	$InLine = join($INI{'GROBAL-StrODJ'},$form{'mid'},$form{'x'},$form{'o'});
	$InLine = $InLine . "\n";


	#書き込み実行
	if(!(-e $MyCartFile)) {
		&RecordFileData($MyCartFile,3,"");	
	}
	&RecordFileData($MyCartFile,4,$InLine);

}

########################################
# カートの中身を掃除する
########################################

sub CleanMyCart {

	local($i,$fpath,$StrCartData,$Match_Flag,@CurArray,@StrCartDataArray);

	$INI{'GROBAL-StrODJ'} =~ s/"//g;
	#ユーザーカートファイルパス作成
	$fpath = $INI{'GROBAL-CartFilePath'} . $COOKIE{'CART-id'};

	$StrCartData = &ReadFileData($fpath,3);
	$StrCartData =~ s/(\n+)/\n/g;
	$StrCartData =~ s/^(\n+)//g;
	@StrCartDataArray = split(/\n/,$StrCartData);


	#文字列整理
	$StrCartData = join("\n",@StrCartDataArray);
	$StrCartData .= "\n";

	#カートファイル上書き
	&RecordFileData($fpath,3,$StrCartData);

}

########################################
# ボディー出力
########################################

sub PB {

	if($K eq "") { $K = $form{'msg'}}


	if($ENV{'HTTP_HOST'} ne "www.tomato21.jp") {
		$K =~ s/="\/images/="\/tomato21\/images/g;
		$K =~ s/="\/photo/="\/tomato21\/photo/g;
	}

	$PB = &JS($K);


	if($PB_RETURN) {return $PB;}
	else { print &PH; print $PB;}


}

########################################
# ボディー出力２
########################################

sub PB2 {
	local($msg) = @_;

	print &PH;
	print $msg;

	exit(0);
}

########################################
# 支払方法から手数料、手数料ＭＳＧを作成する
########################################

sub SetChargeByPayment {
	local($payment) = @_;
	local($i,$total);


	if($payment eq "3" or $payment eq "4") {
		$total = $gSubTotalTotal + $GoodsPricexTax;

		if($total <= 100000) {
			$gTotalCharge = 500;
		} else {
			$gTotalCharge = 1000;
		}
	} else {

		$gTotalCharge = 0;

	}

}




sub KyouseiKaigyou {
	local($mode,$strline,$maxchar) = @_;

	if($mode eq 1) {
		$strline =~ s/([!-~])/$1$1/g;
		$tenten = '..' x $maxchar;
		$strline =~ s/($tenten)/$1\n/g;
		$strline =~ s/([!-~])\1/$1/g;
		#$strline =~ s/\n/<BR>/g;
		return $strline;
	} elsif($mode eq 2) {
		$strline =~ s/([!-~])/$1$1/g;
		$tenten = '..' x $maxchar;
		$strline =~ s/($tenten)/$1\n/g;
		$strline =~ s/([!-~])\1/$1/g;
		$strline =~ s/\n/<BR>/g;
		return $strline;
	}
}

sub ErrMsg {

	local($mode,$strtmp) = @_;

	if($mode eq "1") {
		$msg = &MakeTempLabel($strtmp);
		$K = &ConvVal(&ReadFileData("html/error.html",3));
		&PB;
		exit(0);
	}

}

sub GetGoodsPrice {
	local($mid) = @_;


	$q = "SELECT * FROM productstb WHERE master = '$mid'";
	&ExecSQL($q);
	$ref = $sth->fetchrow_hashref();
	$strtmp 	= $ref->{"tomatoprice"};
	$rc = $sth->finish;

	return $strtmp;

}

sub MakeSelFromTable {
	local($mode,$tname,$sname,$s1,$s2) = @_;
	local(@s1,@s2);

	if($mode eq 1) {
		&ExecSQL("SELECT $s1 from $tname");
		@s1= &MakeArrayBySpecCat($s1);
		&ExecSQL("SELECT $s2 from $tname");
		@s2 = &MakeArrayBySpecCat($s2);

		return &MakeSelectionByStrArray(2,$sname,*s1,*s2);
	}

}

########################################
#  Checkbox 作成
########################################

sub MakeCheckboxByStrArray {
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

		local($mode, $chkname, *strarray,*strarray02) = @_;

		for($i = 0;$i <= $#strarray; $i++) {

			if($pchecked eq $strarray[$i]) {
				$checked = "checked";
			} else {
				$checked = "";
			}

			$strtmp .= "<input type=\"checkbox\" name=\"$chkname\" value=\"$strarray[$i]\" $checked>$strarray02[$i] \n";
		}

		return $strtmp;
	}
	elsif($mode eq 3) {

		local($mode, $chkname, *strarray,*strarray02) = @_;

		for($i = 0;$i <= $#strarray; $i++) {

			if(&StringMatchToArray($strarray[$i],@pchecked) eq 1) {
				$checked = "checked";
			} else {
				$checked = "";
			}

			$strtmp .= "<input type=\"checkbox\" name=\"$chkname$i\" value=\"$strarray[$i]\" $checked>$strarray02[$i] \n";
		}

		return $strtmp;
	}
}





sub GetNewMasterID {

	local($q,$paid,$num,$sid);


	&ExecSQL("SELECT master FROM productstb ORDER BY master DESC");
	$num = &GetValueFromSTH(1,"master");

	if($num eq "") {
		$sid = 100000;
	} else {
		$sid = ++$num;
	}

	return $sid;



}



sub GetNewMemberID {

	local($q,$paid,$num,$sid);


	$num = &GetRows("SELECT * FROM membertb");

	if($num eq "") {
		$num = 0;
	}


	$sid = "m" . sprintf("%09d",++$num);

	return $sid;

}


sub GetNewBuyId {

	local($q,$paid,$num,$sid);


	$num = &GetRows("SELECT * FROM buytb");

	if($num eq "") {
		$num = 0;
	}


	$sid = "b" . sprintf("%07d",++$num);

	return $sid;


}



sub InitHashFromTable {
	local($mode,$tname,$pk,$pv) = @_;
	local($i,@s1,@s2,%hash);



	if($mode eq 1) {
		&ExecSQL("SELECT $pk from $tname");

		@s1= &MakeArrayBySpecCat($pk);

		&ExecSQL("SELECT $pv from $tname");
		@s2 = &MakeArrayBySpecCat($pv);

		for($i = 0;$i <= $#s1; $i++) {
			$hash{$s1[$i]} = $s2[$i];
		}



		return %hash;

	}


}




sub ConvDateToNum {
	local($mode,$date) = @_;


	if($mode eq 1) {
		($y,$m,$d) = split(/\//,$date);

		return $y * 365 + $m * 30 + $d;
	}

}




sub SetSpecMaster {

	local($pid) = @_;
	local(@qfld);
	
	&ExecSQL("DESC productstb");
	@qfld = &MakeArrayBySpecCat("Field");
	$q = "SELECT * from productstb WHERE id = \'$pid\'";

	&ExecSQL($q);
	&GetValueFromSTH(2,"",*qfld);

}


sub GetCustomerOrderHistory {

	($mid) = @_;

	&P006;

	&ExecSQL("DESC orderinfotb");
	@qfld = &MakeArrayBySpecCat("Field");

	$q = "SELECT * from orderinfotb WHERE memberid = \'$mid\'";

	&ExecSQL($q);

	#セットされたフィールドを配列に格納する
	#@qfld = @StrFieldArray;
	&SetFieldToArray(@qfld);



	#テンプレート初期化
	$tpl_1H	= &JE(&ReadFileData("html/customerhistorytr1.html",3));
	$tpl_c1tr	= &JE(&ReadFileData("html/customerhistorytr3.html",3));

	#$tpl_TR1	= &JE(&ReadFileData("html/searchresult1tr.html",3));




	%payway = &InitHashFromTable(1,"paywaytb","paywayid","payway");

#&Err001($#orderid);

	#小テーブル作成ループ
	for($i = 0; $i <= $#orderid; $i++) {

		#変数準備 ---
		foreach(@qfld) {
			${$_} = ${$_}[$i];
		}

		$disppayway = $payway{$payway};



		#購入商品一覧作成 ------ ここから
		@gid = split(/,/,$orderproducts);

		$Cart1Tr = "";
		for($j = 0; $j <= $#gid; $j++) {

			&ExecSQL("SELECT * from productstb where master = '$gid[$j]'");

			$ref = $sth->fetchrow_hashref();
			$master 	= $ref->{"master"};
			$id 	= $ref->{"id"};
			$brand 		= $brand{$ref->{"brand"}};
			$category 	= $category{$ref->{"category"}};
			$product 	= $ref->{"product"};
			$level 		= $level{$ref->{"level"}};
			$tomatoprice 	= $ref->{"tomatoprice"};
			$rc = $sth->finish;



			$tomatoprice = &ConvPriceComma($tomatoprice);
			

			$Cart1Tr .= &ConvVal($tpl_c1tr);

		}

		$sumproducts = &ConvPriceComma($sumproducts);
		$sumtax = &ConvPriceComma($sumtax);
		$carriage = &ConvPriceComma($carriage);
		$dispsumorder = &ConvPriceComma($sumorder);





		$customerhistorytr2 = &ConvVal(&JE(&ReadFileData("html/customerhistorytr2.html",3)));

		#購入商品一覧作成 ------ ここまで



		#購入金額合計処理
		$sumcustomer += $sumorder;




		$customerhistorytr .= &ConvVal($tpl_1H);


	}


	$sumcustomer = &ConvPriceComma($sumcustomer);


	return $customerhistorytr;

}


sub SetSex {

	local($strtmp) = @_;

	if($strtmp eq "0") {
		$strtmp = "女";
	} else {
		$strtmp = "男";
	}

	return $strtmp;
}

sub SetMailMag {

	local($strtmp) = @_;

	if($strtmp eq "0") {
		$strtmp = "希望しない";
	} else {
		$strtmp = "希望する";
	}

	return $strtmp;

}



sub SetContactWay {

	local($strtmp) = @_;

	if($strtmp eq "0") {
		$strtmp = "自宅";
	} else {
		$strtmp = "携帯電話";
	}

	return $strtmp;

}



sub SetDelivery {

	local($strtmp) = @_;

	if($strtmp eq "0") {
		$strtmp = "指定なし";
	} else {
		$strtmp = "指定あり";
	}

	return $strtmp;

}


sub CheckMust {

	local($i,$flag,@must);

	@must = split(/:/,$must);

	#&Err001("@must");

	$flag = 0;
#print &PH;
	for($i = 0; $i <= $#must; $i++) {

		if($form{$must[$i]} eq "") {
#print $must[$i] . "!!!!<BR>";
			$kmsg2 .= $INI{"MSG2-" . $intl . "_$must[$i]"};
			$flag = 1;
		}
	}

	return $flag;

}



sub Setstep04deliverytr {

		if($form{'sendto'} eq "1") {
			$step04deliverytr = &ConvVal(&JE(&ReadFileData("html/step04deliverytr.html",3)));
		} else {
			$step04deliverytr = $INI{"GROBAL-same2up"};
		}

}





#### #    # ####
#    ##   # #   #
#### # #  # #   #
#    #  # # #   #
#### #   ## ####
1;
