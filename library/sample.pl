sub strcmp { (shift) cmp (shift) }
sub intcmp { (shift) <=> (shift) }
sub numcmp { $a <=> $b }




########################################
# �ӣѣ���³
########################################

sub pConnectSQL {

	#�ӣѣ���³
	if($SQL_CONNECTED ne 1) {
		&ConnectSQL("mysql",$mysql_dbn,$mysql_host,"3306",$mysql_user,$mysql_pass);
		$SQL_CONNECTED = 1;
	} else {
		#&Err001("���Ǥ���³����Ƥ��ޤ���");
	}

}

########################################
# �ӣѣ̽����
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
#�����Ƚ����
########################################

sub Init_Cart {

	local($tmp01);


	&GetCookie;
	$MyCartFile = "$INI{'GROBAL-CartFilePath'}$COOKIE{'CART-id'}";
	&CheckFileDateAndDelete("hour",$MyCartFile,"1");


	### �����ȣɣĵڤӥ����ȥե�����¸�߳�ǧ
	if(($COOKIE{'CART-id'} eq "") || (!(-e $MyCartFile))) {

		#�����Ȥ򿷵��˺�������
		$tmp01 = &GetDateString;
		$tmp01 =~ s/://g;
		$COOKIE{'CART-id'} = "c" . $tmp01;

#print &PH;
#print $COOKIE{'CART-id'} . "nomore";

		print &PutCookie("CART","id:$COOKIE{'CART-id'}",$INI{'GROBAL-CookieExpire'});
#exit(0);
		$MyCartFile = "$INI{'GROBAL-CartFilePath'}$COOKIE{'CART-id'}";
	}


	### ���ʿ�������� �ڤ� ����---
	#�����ȥե������ɤ߹���
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

	#�񤭹��߼¹�
	&RecordFileData($MyCartFile,1,"",@StrCartDataArray);
}

########################################
# �����Ⱦ�����������
########################################

sub GetCartTable {
	local($mode,$cid) = @_;
	local($i,$j,$strhtml,$Match_Flag,$StrCartData,@tmparray,@StrCartDataArray,@CurArray,$GidArray,@XArray,@OArray);


	#�����Ⱦ�������
	&Init_Cart if($MyCartFile eq "");

	#�����ȣɣĤ����ꤵ��Ƥ���������ꤹ��
	$MyCartFile = "$INI{'GROBAL-CartFilePath'}$cid" if($cid ne "");

	#�����ȥե������ɤ߹���
	$StrCartData = &ReadFileData($MyCartFile,3);
	@StrCartDataArray = split(/\n/,$StrCartData);

	#�����ȥե����뤫������̤����󲽤���
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
	# ��ʸ��ǧ�⡼��
	#-------------------------------
	if($mode eq "1") {



		#�ѿ������--------

		&P006;

		$tpl_c1t = &JE(&ReadFileData("html/step02_c1tr.html",3));
		$tpl_oricogoodsinfo = &JE(&ReadFileData("html/oricogoodsinfo.html",3));

		$gSubTotalTotal 	= 0; #����
		$gGoodsPriceTotal 	= 0; #���� x �� �ι��
		$gTotalTax		= 0; #������
		$gTotalShipment		= 0; #����
		$gTotalCharge		= 0; #�����
		$gTotal			= 0; #���

		#���������Ź�޿������
		#@SidArray = &GetSidArrayFromGidArray(@GidArray);
		#@gSidArray = @SidArray;

#print &PH;

		#�ơ��֥�����ڤӾ��ʤ��Ȥη׻������롼�� ********************** ��������
		for($i = 0; $i <= $#GidArray; $i++) {

			#print "aaa<br>";

			#���ξ��ʤ�Ź�ޣɣĤ��������
			#$sid = &GetSid($GidArray[$i]);


			#�������� [1,2,3] ��Ĥ���
			#$CurGoodsPrice 		= "GoodsPrice$OArray[$i]";
			#$CurGoodsCapacity 	= "GoodsCapacity$OArray[$i]";

			#���ʥǡ����١������龦��̾�����ʣ����������
			&ExecSQL("SELECT * from productstb where master = '$GidArray[$i]'");

			#�ѿ���Ǽ
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


			#renovate at ITS 2002/4/16 ORICO�Ѥ�HIDDEN��������� --- ��������
			$NUM = sprintf("%02d",$i + 1);
			$oricotmp = &ConvVal($tpl_oricogoodsinfo);
			$oricotmp =~ s/_NUM/_$NUM/g;
			$oricogoodsinfo .= &JS($oricotmp);
			#renovate at ITS 2002/4/16 ORICO�Ѥ�HIDDEN��������� --- �����ޤ�


			#Ź�޾��׹�׷׻�
			#$shopsubtotal{$sid} += $SubTotal;


			#���׹�׷׻�
			$gSubTotalTotal 	= $gSubTotalTotal + $tomatoprice;

			#�����ǹ�׷׻�
			$gTotalTax = $gTotalTax + $tax;
			#$gTotalTax = $gTotalTax + $GoodsPricexTax * $XArray[$i];

			#���ͥ���޽���
			$tomatoprice = &ConvPriceComma($tomatoprice);
			$tax = &ConvPriceComma($tax);
			$taxprice = &ConvPriceComma($taxprice);

			$displevel = $level{$level};
			&P005;


			#����̾ - ñ�� - ���� - ������ - ����
			$Cart1Tr .= &ConvVal($tpl_c1t);

#print $strhtml;
			#�����ѥ����Ⱦ���ʸ����
			push(@gStrCartInfoArray,"$GidArray[$i]");
		}
		#�ơ��֥�����ڤӾ��ʤ��Ȥη׻������롼�� ********************** �����ޤ�


		#��������� --------------------------------
		&SetChargeByPayment($payway);

		#�������� ----------------------------------

		#%shipment = &InitHashFromTable(1,"areatb","id","postage");

		#if($shipment{$sendtoaddress1} eq "1") {
			$gTotalShipment = 1000;
		#} else {
		#	$gTotalShipment = 500;
		#}


		#�⤷��campaign_rule�ʾ�ξ���������̵���ˤ���
		if($gSubTotalTotal >= $INI{"GROBAL-campaign_rule"}) {
			$gTotalShipment = 0;
			$carriage = $form{"carriage"} = 0;
		} else {
			$carriage = $form{"carriage"} = $INI{"GROBAL-carriage_fee"};
		}



		#�ݥ���Ƚ��� ------------------------------

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




		#��׽��� ----------------------------------
		#$gGoodsPriceTotal = $gSubTotalTotal;
		#$gTotal = $gSubTotalTotal + $gTotalTax + $gTotalShipment + $gTotalCharge - $pointusepoint;
		$gTotal = $gSubTotalTotal + $gTotalTax + $carriage;


		#&Err002("$form{'UserID'}");
















		#�����Х��ѿ���%form�˳�Ǽ ---------------
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



		#���ͥ���޽��� ----------------------------
		$gTotal 		= &ConvPriceComma($gTotal);
		$gGoodsPriceTotal 	= &ConvPriceComma($gGoodsPriceTotal);
		$gSubTotalTotal 	= &ConvPriceComma($gSubTotalTotal);
		$gTotalTax 		= &ConvPriceComma($gTotalTax);
		$gTotalShipment 	= &ConvPriceComma($gTotalShipment);
		$gTotalCharge 		= &ConvPriceComma($gTotalCharge);
		$TMP_gSubTotalTotal 	= &ConvPriceComma($TMP_gSubTotalTotal);

		#�����Ⱦ�����Ĥ�ʸ����ˤޤȤ�� --------
		$form{"gStrCartInfo"} = $gStrCartInfo = join(",",@gStrCartInfoArray);
		$form{'orderproducts'} = $form{"gStrCartInfo"};

		$strhtml = $Cart1Tr;



		return $strhtml;
	}
	#-------------------------------
	# �᡼��⡼��
	#-------------------------------
	elsif($mode eq "2") {

		&P006;
		$tpl_c1t = &JE(&ReadFileData("html/ordercfmmail_cartinfo.txt",3));



		#�ӣѣ���³
		&pConnectSQL;


		#�ơ��֥����
		for($i = 0; $i <= $#GidArray; $i++) {

			#$CurGoodsPrice = "GoodsPrice$OArray[$i]";
			#$CurGoodsCapacity = "GoodsCapacity$OArray[$i]";

			#���ʥǡ����١������龦��̾�����ʣ����������
			&ExecSQL("SELECT * from productstb where master = '$GidArray[$i]'");

			#�ѿ���Ǽ
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


			#����̾ - ñ�� - ���� - ������ - ����
			$strhtml .= &ConvVal($tpl_c1t);


			#�����ѥ����Ⱦ���ʸ����
			push(@gStrCartInfoArray,"$GidArray[$i]:$XArray[$i]");

			push(@gGidArray,$GidArray[$i]);
		}


		#�ӣѣ�����
		&DisconnectSQL;

		return $strhtml;


	}
	#-------------------------------
	# �����ȥ⡼��
	#-------------------------------
	elsif($mode eq "3") {

		#�ѿ������
		$tpl_c1t = &JE(&ReadFileData("html/c1tr.html",3));
		$Gmax = $#GidArray;
		$SubTotalTotal 	= 0;
		$gTotalTax	= 0;
		$gTotalShipment = 0;
		$carriage	= 0;
		$SubTotal	= 0;


		#�ӣѣ���³
		&pConnectSQL;


		&P006;




		#���������Ź�޿������
		#@SidArray = &GetSidArrayFromGidArray(@GidArray);

		#�ơ��֥����
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




			#�����ǹ�׷׻�
			$GoodsPricexTax = &Round($tomatoprice * $taxfee,0);
			$gTotalTax = $gTotalTax + $GoodsPricexTax;

			#���ͥ���޽���
			$tomatoprice = &ConvPriceComma($tomatoprice);
			#$SubTotal = &ConvPriceComma($SubTotal);

			$x = $XArray[$i];
			$o = $OArray[$i];
			$master = $GidArray[$i];
			$displevel = $level{$level};

			&P005;


			$CartTr .= &ConvVal($tmp01);
		}


		#�⤷��campaign_rule�ʾ�ξ���������̵���ˤ���
		if($SubTotal >= $INI{"GROBAL-campaign_rule"} or $SubTotal eq 0) {
			$carriage = 0;
		} else {
			$carriage = $form{"carriage"} = $INI{"GROBAL-carriage_fee"};
		}


		$campaignrule = &ConvPriceComma($campaignrule);


		#��׽���
		$SubTotalTotal = $SubTotalTotal + $gTotalTax + $carriage;


		#���ͥ���޽���
		$SubTotal = &ConvPriceComma($SubTotal);
		$SubTotalTotal = &ConvPriceComma($SubTotalTotal);
		$gTotalTax = &ConvPriceComma($gTotalTax);
		$gTotalShipment = &ConvPriceComma($gTotalShipment);
		$carriage = &ConvPriceComma($carriage);


		$strhtml = &ConvVal(&JE(&ReadFileData("html/c1t.html",3)));

		#�ӣѣ�����
		&DisconnectSQL;

		return $strhtml;

	}

	#-------------------------------
	# ��ʸ����⡼��
	#-------------------------------
	elsif($mode eq "3B") {

		#�ѿ������
		$tpl_c1t = &JE(&ReadFileData("html/step02_c1tr.html",3));
		$Gmax = $#GidArray;
		$SubTotalTotal 	= 0;
		$gTotalTax	= 0;
		$gTotalShipment = 0;
		$carriage	= 0;

		#�ӣѣ���³
		&pConnectSQL;


		&P006;




		#���������Ź�޿������
		#@SidArray = &GetSidArrayFromGidArray(@GidArray);

		#�ơ��֥����
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




			#�����ǹ�׷׻�
			$GoodsPricexTax = &Round($tomatoprice * $taxfee,0);
			$gTotalTax = $gTotalTax + $GoodsPricexTax;

			#���ͥ���޽���
			$tomatoprice = &ConvPriceComma($tomatoprice);
			#$SubTotal = &ConvPriceComma($SubTotal);

			$x = $XArray[$i];
			$o = $OArray[$i];
			$master = $GidArray[$i];


			$displevel = $level{$level};

			&P005;


			$CartTr .= &ConvVal($tmp01);
		}


		#�⤷��campaign_rule�ʾ�ξ���������̵���ˤ���
		if($SubTotal >= $INI{"GROBAL-campaign_rule"}) {
			$carriage = 0;
		} else {
			$carriage = $form{"carriage"} = $INI{"GROBAL-carriage_fee"};
		}



		#��׽���
		$SubTotalTotal = $SubTotalTotal + $gTotalTax + $carriage;


		#���ͥ���޽���
		$SubTotal = &ConvPriceComma($SubTotal);
		$SubTotalTotal = &ConvPriceComma($SubTotalTotal);
		$gTotalTax = &ConvPriceComma($gTotalTax);
		$carriage = &ConvPriceComma($carriage);


		$strhtml = $CartTr;

		#�ӣѣ�����
		&DisconnectSQL;

		return $strhtml;

	}

	#-------------------------------
	# �ƣ��إ⡼��
	#-------------------------------
	elsif($mode eq "4") {

		#���������Ź�޿������
		@SidArray = &GetSidArrayFromGidArray(@GidArray);

		#�ơ��֥����
		for($i = 0; $i <= $#GidArray; $i++) {

			#����Ź�ޤǤʤ���м���
			#if($GidArray[$i] !~ /^$form{'sid'}/) {
			#	next;
			#}

			$CurGoodsPrice = "GoodsPrice$OArray[$i]";
			$CurGoodsCapacity = "GoodsCapacity$OArray[$i]";


			#���ʥǡ����١������龦��̾�����ʣ����������
			&ExecSQL("SELECT * from $INI{'GROBAL-GDBName'} where GoodsID = '$GidArray[$i]'");

			#�ѿ���Ǽ
			$ref = $sth->fetchrow_hashref();
			$GoodsName 	= $ref->{"GoodsName"};
			$GoodsCapacity 	= $ref->{$CurGoodsCapacity};
			$GoodsPrice 	= $ref->{$CurGoodsPrice};
			$SubTotal 	= $GoodsPrice * $XArray[$i];
			$gSubTotalTotal 	= $gSubTotalTotal + $SubTotal;
			$rc = $sth->finish;

			#�����ǹ�׷׻�
			$GoodsPricexTax = &Round($GoodsPrice * $taxfee,0);
			$gTotalTax = $gTotalTax + $GoodsPricexTax * $XArray[$i];

			#���ͥ���޽���
			$GoodsPrice = &ConvPriceComma($GoodsPrice);
			$SubTotal = &ConvPriceComma($SubTotal);


			#����ʤ�иĿ��Ⱦ��פ�ɽ�����ʤ�
			if($form{'step'} eq "o1s") {
				$XArray[$i] = "\&nbsp;";
				$SubTotal = "\&nbsp;";
			}


			#����̾ - ñ�� - ���� - ������ - ����
			$strhtml .= join("","
				<tr>
				<td $ac> \&nbsp; </td>
				<td $ac>$GoodsName ($GoodsCapacity)</td>
				<td $ac>$GoodsPrice��</td>
				<td $ac> $XArray[$i] </td>
				<td $ac> $SubTotal </td>
				</tr>
				");

			#�����ѥ����Ⱦ���ʸ����
			push(@gStrCartInfoArray,"$GidArray[$i]:$XArray[$i]:$OArray[$i]");
		}


		#���������
		&SetChargeByPayment($form{'Payment'});



		#��������
		$gTotalShipment = &GetShipmentByGidxSidArray(*GidArray,*SidArray);



		#��׽���
		$gGoodsPriceTotal = $gSubTotalTotal;
		$gSubTotalTotal = $gSubTotalTotal + $gTotalTax + $gTotalShipment + $gTotalCharge;


		#�����Х��ѿ���%form�˳�Ǽ
		$form{"gGoodsPriceTotal"} = $gGoodsPriceTotal;
		$gTotal = $form{"gTotal"} = $gSubTotalTotal;
		$form{"gTotalTax"} = $gTotalTax;
		$form{"gTotalShipment"} = $gTotalShipment;
		$form{"gTotalCharge"} = $gTotalCharge;
		$form{"gOrdercfmMsg"} = $gOrdercfmMsg;


		#���ͥ���޽���
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
# �������٥�Ƚ����
########################################

sub Init_Search {

	#�ʣӽ����
	$JS = &ConvVal(&JE(&ReadFileData("html/SEARCH_JS.txt",3)));

	#�����ܥå���ɽ���� $q �����
	if(($form{'act'} eq "area") || ($form{'act'} eq "cat")) {
		$q = "";
	} else {
		$q2 = $form{'q'};
	}

	#ɽ���ѥ����꡼�����
	$form{'disp_q'} = $form{'q'};


	#����ɽ���������
	if($form{'l'} eq "" and $form{'pl'} eq "") {
		$form{'l'} = 6;
	} elsif($form{'pl'} ne "") {
		$form{'l'} = $form{'pl'};
	} else {
		$form{'l'} = $form{'l'};
	}

	#�������ϰ��ֽ����
	if($form{'st'} eq "") {
		$form{'st'} = 0;
		#ɽ���ѳ��ϰ��ֽ����
		$form{'disp_st'} = 1;
	} else {
		$form{'disp_st'} = $form{'st'};
	}

	#���θ������ϰ���
	$form{'n_st'} 	= $form{'st'} + $form{'l'}; 

	#���θ������ϰ���
	$form{'p_st'} = $form{'st'} - $form{'l'};

	#������λ���ֽ����
	$form{'en'} = $form{'st'} + $form{'l'};

	#�ϣңģţ£�ʸ����
	$q_orderby = "ORDER BY RAND()";


	#�̣ɣͣɣ�ʸ����
	$q_limit = "LIMIT $form{'st'},$form{'l'}";

	#������ɤ�գң̥��󥳡��ɤ���
	$form{'q_encoded'} = &URLEncode($form{'q'});

	if($form{'m'} eq "") {
		$form{'m'} = "default";
	}


	#�����⡼��Selection �������
	while(($k,$v) = each %form) {
		if($k eq "m") {
			${"Fm$v"} = "selected";
		}
	}

}


########################################
# form Ϣ������˸������׿�����������
########################################

sub SetFmc {
	local($q) = @_;

	if($form{'mc'} eq "") {
		#�������׿�����
		$form{'mc'} = &GetRows($q);
	}

}

#====================================================================================[�ץ���]======
#����������������������������������������������������������������������������������������������������
#====================================================================================================

########################################
# �ץ����ֹ� 002����honma�ѹ�����
########################################

sub P002 {

	local($i,$strhtml,$tmp01,$tmp02,$tmp03,$tpl_TABLE1);

	#------------------------------------------------------------
	#�������������ʬ�ʤޤȤ᤿�����ù������
	#
	# ɬ���ѿ�
	# @GoodsID
	# @GoodsName
	# @GoodsPrice
	# @GoodsCatch
	#
	#------------------------------------------------------------

	# ������ ---------------��������

	@makerprice = grep { $_ = &ConvPriceComma($_) } @makerprice;
	@tomatoprice = grep { $_ = &ConvPriceComma($_) } @tomatoprice;

	# ������ ---------------�����ޤ�


	################################
	#��ɸ��⡼��
	################################

	if($form{'m'} eq "default") {


		#�ƥ�ץ졼�Ƚ����
		$tpl_TABLE1	= &JE(&ReadFileData("html/searchresult1t.html",3));
		$tpl_TR1	= &JE(&ReadFileData("html/searchresult1tr.html",3));

		$cnt = 0;
		$tmp01 = $tpl_TR1;





		#���ơ��֥�����롼��
		for($i = 0; $i <= $#master; $i++) {

			#�ѿ����� ---
			foreach(@qfld) {
				${$_} = ${$_}[$i];
			}

			#renovate at ITS 2002/01/21 K.Hamada �������̤�ɽ������ʤ��Τ�comment�Τ�EUC�Ѵ����� ��Ǻ�������ۤ�������
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
	#�إƥ����ȥ⡼�ɡ�
	################################

	elsif($form{'m'} eq "text") {

		for($i = 0; $i <= $#GoodsID; $i++) {
			$tmp01 = &Parapara($INI{'GROBAL-Paraparacolor'});
			$naiyou .= join("","
				<tr bgcolor=\"$tmp01\">
				 <td width=\"30%\"><img src=\"../images/shikaku.gif\">  <a href=\"$ThisFile?act=s1g\&gid=$GoodsID[$i]\">$GoodsName[$i]</a>  </td>
				 <td width=\"60%\"><img src=\"../images/sankaku.gif\">  $GoodsCatch[$i] </td>
				 <td width=\"10%\" $ar>$GoodsPrice[$i]��</td>
				</tr>
				");
		}

		$naiyou = join("","
			<table class=\"sit\" border=\"0\" width=\"95%\" $ac $cp{'6'} $cs{'2'}>
			<tr bgcolor=\"#FFA586\">
			<td $ac> ����̾</td>
			<td $ac> ����å����ԡ� </td>
			<td $ac> ����</td>
			</tr>
			$naiyou
			</table>
			");




		$K = &ConvVal(&JE(&ReadFileData("html/kat.html",3)));

	}

	################################
	#�ز����⡼�ɡ�
	################################

	elsif($form{'m'} eq "pic") {

		$tpl_TR1	= &JE(&ReadFileData("html/searchresult1tr_pic.html",3));




		for($i = 0; $i <= $#master; $i++) {

			#�ѿ����� ---
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
# �ץ����ֹ� 003  honma�ѹ�����
########################################

sub P003 {
	local($i);


	@makerprice = grep { $_ = &ConvPriceComma($_) } @makerprice;
	@tomatoprice = grep { $_ = &ConvPriceComma($_) } @tomatoprice;



	#�ѿ����� ---
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

		#renovate at ITS 2002/01/22 K.Hamada ���������θ�������ե�ˤ���
		#$return = "$ThisFile?act=\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}";
		$return = "$ThisFile?act=\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}\&brand=$form{'brand'}\&category=$form{'category'}\&level=$form{'level'}\&status=$form{'status'}\&pricemin=$form{'pricemin'}\&pricemax=$form{'pricemax'}";
		$pmedama = "";
	}


	#renovate at ITS 2002/01/22 K.Hamada ����̿��򲡤��Ƥ����������褦�ˤ���
	#$showphoto1 = "$ThisFile?act=s1g\&mid=$form{'mid'}\&photonum=1";
	#$showphoto2 = "$ThisFile?act=s1g\&mid=$form{'mid'}\&photonum=2";
	$showphoto1 = "$ThisFile?act=s1g\&dum=$pmedama\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}\&mid=$form{'mid'}\&brand=$form{'brand'}\&category=$form{'category'}\&level=$form{'level'}\&status=$form{'status'}\&pricemin=$form{'pricemin'}\&pricemax=$form{'pricemax'}\&photonum=1";
	$showphoto2 = "$ThisFile?act=s1g\&dum=$pmedama\&st=$form{'st'}\&l=$form{'l'}\&mc=$form{'mc'}\&m=$form{'m'}\&mid=$form{'mid'}\&brand=$form{'brand'}\&category=$form{'category'}\&level=$form{'level'}\&status=$form{'status'}\&pricemin=$form{'pricemin'}\&pricemax=$form{'pricemax'}\&photonum=2";




	#renovate at ITS 2002/01/22 K.Hamada �������ξ��ʤ��ʤ����ϥܥ����ɽ�����ʤ�
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


	#�����Ȥγ�ǧ��� ---
	#�����Ȥ�����ʸ������� ---
	if($MyCartGx eq 0) {
	#	$viewcart = "#";
		$viewcart = "cart.cgi?act=viewcart";
		#$cartcomment = "�����㤤ʪ�����ˤϲ������äƤ��ޤ���";
	} else {
		if((-e "$MyCartFile\.tmp")) {
			&RecordFileData($MyCartFile,3,"");
		} else {
			$cartcomment = "�㤤ʪ�����ˤϸ��� $MyCartGx�� �ξ��ʤ����äƤ��ޤ�����׶�ۤ�" . &ConvPriceComma($MyCartGp) . "�ߤǤ���";
			$cartcommenttable = &ConvVal(&JE(&ReadFileData("html/cartcommenttable.html",3)));
		}

		$viewcart = "cart.cgi?act=viewcart";
	}


	#����ξ�������٤β����ˤ���
	if($soldout eq 1) {
		$BuyButton = "<img src=\"/images/system/baiyaku.gif\" width=\"153\" height=\"28\">";
	#�ޤ��ξ����㤨��褦�ˤ���
	} else {
		$BuyButton = "<a href=\"cart.cgi?act=add&mid=$mid\" onMouseOut=\"MM_swapImgRestore()\" onMouseOver=\"MM_swapImage('get1','','/images/system/get2.gif',1)\"><img name=\"get1\" border=\"0\" src=\"/images/system/get.gif\" width=\"153\" height=\"28\" alt=\"���ξ��ʤ��������\"></a>";
	}



	$P003 = &ConvVal(&JE(&ReadFileData("html/productdetail.html",3)));

	# ####���ͤ�Ƚ��
	if($gP003_RETURN) { 
		return $P003;
	} else {
		print $P003;
	}

}

sub P005 {

	#status ���� ----
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
# ��������ʸ�ɣĤ��������
########################################

sub GetNewOrderNumber {
	local($cur_time,$cur_y,$oy,$om,$od,$on,$oid);

	$cur_time = &GetCurTime; #����ꥫ���֤������ܻ��֤�����

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
# ������ͽ��ɣĤ��������
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
# ������ͽ��ɣĤ��������
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
# �����Ȥ���Ȥ�׻�����
########################################

sub RecalcMyCart {
	local($i,$StrCartData);

	#�����Ⱦ�������
	&Init_Cart if($MyCartFile eq "");

	for($i = 0; $i <= $form{'g_max'} - 1; $i++) {

		if($form{"g$i"} !~ /^\d/) {
			#&Err001("���������Ϥ��Ʋ�����");
		} else {
			$StrCartData .= join($INI{'GROBAL-StrODJ'},$form{"g$i"},$form{"x$i"},$form{"o$i"});
			$StrCartData .= "\n";
		}
	}

	&RecordFileData($MyCartFile,3,$StrCartData);
}



########################################
# ���顼��å��������ϴؿ�
########################################

sub Err001 {

	local($msg) = @_;

	$K = &MakeTempLabel($msg);
	&PB;
	exit(0);

}

########################################
# �������٥�� �����
########################################

sub Init_Admin {


	#����¸ --------------------------
	#renovate at ITS 2002/01/16 K.Hamada �ȥޥȤξ����ϻĤ��ʤ�
	#&MakeAccessLog(1,$INI{'GROBAL-StrODJ'},"=",$INI{'GROBAL-AdminLogFile'},*form);



	#ǧ�ڽ��� --------------------------

		&GetCookie;

		$MyAdminFile = "$INI{'GROBAL-AdminFilePath'}$COOKIE{'ADMIN-id'}";
		#&CheckFileDateAndDelete("hour",$MyAdminFile,"1.2"); #����ʬ���Υե�����ʤ�������

		$StrAdmin = &ReadFileData($MyAdminFile,3);
		($MyAdminID,$MyAdminPS) = split(/$INI{"GROBAL-StrODJ"}/,$StrAdmin);

		#�ӣѣ���³ ��������������
		&pConnectSQL;

		$q = "SELECT * FROM admintb WHERE AdminID = \'$MyAdminID\' AND AdminPS = \'$MyAdminPS\'";

		if(&GetRows($q) eq "0") {
			$Match_Flag = 0;
		} else {
			$Match_Flag = 1;
		}

		#�ӣѣ����� ��������������
		&DisconnectSQL;


		if($Match_Flag) {
			if(($form{"act"} eq "") || ($form{"act"} eq "login")) {
				$form{"act"} = "menu";
			}
		} else {
			if(($form{"act"} eq "") || ($form{"act"} eq "login")) {
			} else {
				&Err001("�⤦���٥����󤷤Ƥ�������<p> <a href=\"$ThisFile\">���������</a>");
			}
		}



	#����ɽ�����ѿ� --------------------------


	#����ɽ���������
	if($form{'l'} eq "") {
		$form{'l'} = 20;
	} else {
		$form{'l'} = $form{'l'};
	}

	#�������ϰ��ֽ����
	if($form{'st'} eq "") {
		$form{'st'} = 0;
		#ɽ���ѳ��ϰ��ֽ����
		$form{'disp_st'} = 1;
	} else {
		$form{'disp_st'} = $form{'st'};
	}

	#���θ������ϰ���
	$form{'n_st'} 	= $form{'st'} + $form{'l'}; 

	#���θ������ϰ���
	$form{'p_st'} = $form{'st'} - $form{'l'};

	#������λ���ֽ����
	$form{'en'} = $form{'st'} + $form{'l'};

	#�̣ɣͣɣ�ʸ����
	$q_limit = "LIMIT $form{'st'},$form{'l'}";

	#�����Х��ѿ� --------------------------

	$Title = "�ȥޥ� - ��������";

}

########################################
# ��ʸ���٥�Ƚ����
########################################

sub Init_Order {

	local(@strarray,%hash);


	#���Τޤ��֤� (����)!!!
	return 1;


	&GetCookie;
	$MyRegiFile = "$INI{'GROBAL-RegiFilePath'}$COOKIE{'REGI-id'}";
	&CheckFileDateAndDelete("hour",$MyRegiFile,"0.5");

	### �����ȣɣĵڤӥ����ȥե�����¸�߳�ǧ
	if(($COOKIE{'REGI-id'} eq "") || (!(-e $MyRegiFile))) {
		#�����Ȥ򿷵��˺�������
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
		#���ʤ�Хե��������¸���ʤ��ʥǥХ���
		if($v ne "") {
			push(@strarray,"$k <> $v");
		}
	}
	$cdata = join($INI{'GROBAL-StrODJ'},@strarray);

	#�񤭹��߼¹�
	&RecordFileData($MyRegiFile,3,$cdata);

	chmod 0707, $MyRegiFile;


	&MakeHashFromString(2,&ReadFileData($MyRegiFile,3),$INI{'GROBAL-StrODJ'}," <> ","REGI");

}

########################################
# ���С����٥�Ƚ����
########################################

sub Init_Member {

	#ǧ�ڽ��� --------------------------

	&GetCookie;
	
	$MyMemberFile = "$INI{'GROBAL-MemberFilePath'}$COOKIE{'MEMBER-id'}";
	#&CheckFileDateAndDelete("hour",$MyMemberFile,"0.2"); #����ʬ���Υե�����ʤ�������

	$StrMember = &ReadFileData($MyMemberFile,3);
	($MyUserID,$MyUserPS) = split(/$INI{"GROBAL-StrODJ"}/,$StrMember);

	$MyAddressBookFile = $INI{'GROBAL-AddressBookFilePath'} . $INI{'GROBAL-AddressBook_Intl'} . $MyUserID;
}

########################################
# �����Ȥ˾��ʤ��ɲä���
########################################

sub PutGoodsToMyCart {



	#�ɲ�ʸ�������
	$INI{'GROBAL-StrODJ'} =~ s/"//g;
	$InLine = join($INI{'GROBAL-StrODJ'},$form{'mid'},$form{'x'},$form{'o'});
	$InLine = $InLine . "\n";


	#�񤭹��߼¹�
	if(!(-e $MyCartFile)) {
		&RecordFileData($MyCartFile,3,"");	
	}
	&RecordFileData($MyCartFile,4,$InLine);

}

########################################
# �����Ȥ���Ȥ��ݽ�����
########################################

sub CleanMyCart {

	local($i,$fpath,$StrCartData,$Match_Flag,@CurArray,@StrCartDataArray);

	$INI{'GROBAL-StrODJ'} =~ s/"//g;
	#�桼���������ȥե�����ѥ�����
	$fpath = $INI{'GROBAL-CartFilePath'} . $COOKIE{'CART-id'};

	$StrCartData = &ReadFileData($fpath,3);
	$StrCartData =~ s/(\n+)/\n/g;
	$StrCartData =~ s/^(\n+)//g;
	@StrCartDataArray = split(/\n/,$StrCartData);


	#ʸ��������
	$StrCartData = join("\n",@StrCartDataArray);
	$StrCartData .= "\n";

	#�����ȥե�������
	&RecordFileData($fpath,3,$StrCartData);

}

########################################
# �ܥǥ�������
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
# �ܥǥ������ϣ�
########################################

sub PB2 {
	local($msg) = @_;

	print &PH;
	print $msg;

	exit(0);
}

########################################
# ��ʧ��ˡ����������������ͣӣǤ��������
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
#  Checkbox ����
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

	#���åȤ��줿�ե�����ɤ�����˳�Ǽ����
	#@qfld = @StrFieldArray;
	&SetFieldToArray(@qfld);



	#�ƥ�ץ졼�Ƚ����
	$tpl_1H	= &JE(&ReadFileData("html/customerhistorytr1.html",3));
	$tpl_c1tr	= &JE(&ReadFileData("html/customerhistorytr3.html",3));

	#$tpl_TR1	= &JE(&ReadFileData("html/searchresult1tr.html",3));




	%payway = &InitHashFromTable(1,"paywaytb","paywayid","payway");

#&Err001($#orderid);

	#���ơ��֥�����롼��
	for($i = 0; $i <= $#orderid; $i++) {

		#�ѿ����� ---
		foreach(@qfld) {
			${$_} = ${$_}[$i];
		}

		$disppayway = $payway{$payway};



		#�������ʰ������� ------ ��������
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

		#�������ʰ������� ------ �����ޤ�



		#������۹�׽���
		$sumcustomer += $sumorder;




		$customerhistorytr .= &ConvVal($tpl_1H);


	}


	$sumcustomer = &ConvPriceComma($sumcustomer);


	return $customerhistorytr;

}


sub SetSex {

	local($strtmp) = @_;

	if($strtmp eq "0") {
		$strtmp = "��";
	} else {
		$strtmp = "��";
	}

	return $strtmp;
}

sub SetMailMag {

	local($strtmp) = @_;

	if($strtmp eq "0") {
		$strtmp = "��˾���ʤ�";
	} else {
		$strtmp = "��˾����";
	}

	return $strtmp;

}



sub SetContactWay {

	local($strtmp) = @_;

	if($strtmp eq "0") {
		$strtmp = "����";
	} else {
		$strtmp = "��������";
	}

	return $strtmp;

}



sub SetDelivery {

	local($strtmp) = @_;

	if($strtmp eq "0") {
		$strtmp = "����ʤ�";
	} else {
		$strtmp = "���ꤢ��";
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
