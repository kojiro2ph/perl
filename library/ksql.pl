#=====================================================================
# [Function		] Init_SQL
# [Contents     ] �ӣѣ̴Ķ�����������
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] �ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
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
# [Contents     ] �ӣѣ̤���³����
#				  ��������Oracle,PGSQL,MySql,Sybase,MSSQL�ۤʤ��礬
#				    ����ΤǼ���Ǻ�뤳�Ȥ򤪤����ᤷ�ޤ���
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)driver:�ɥ饤��ʸ����
#				  (string)database:�ǡ����١���̾
#				  (string)hostname:�ۥ���̾
#				  (string)port:�ݡ����ֹ�
#				  (string)user:�桼����̾
#				  (string)password:�ѥ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ConnectSQL {
	local($driver,$database,$hostname,$port,$user,$password) = @_;
	local($dsn);

 	$dsn = "DBI:$driver:database=$database;host=$hostname;port=$port"; #�ģӣ��ѿ������
	$dbh = DBI->connect($dsn, $user, $password);	#��³�¹�
	print "$dbh->errstr" if(not $dbh);
	$drh = DBI->install_driver("mysql");	#�ɥ饤�Х��󥹥ȡ���
	print "$dbh->errstr" if(not $dbh);


}

#=====================================================================
# [Function		] DisconnectSQL
# [Contents     ] �ӣѣ̤����Ǥ���
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] �ʤ�
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub DisconnectSQL {

	$dbh->disconnect();	# ���Ǽ¹�
	$SQL_CONNECTED = 0;

}

#=====================================================================
# [Function		] MakeTableFromSTH
# [Contents     ] sth��TABLE���ˤ���
#---------------------------------------------------------------------
# [Return       ] (string)strline:HTMLʸ����
# [Input        ] (string)tname:�ơ��֥�̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeTableFromSTH {
	local($tname) = @_;
	local($i,$strline,$numRows,$numFields,@field);

	#�ե������̾��إåɤ�����
	&ExecSQL("DESC $tname"); #�ӣѣ�ʸ�¹�
	@fldname = &MakeArrayBySpecCat("Field");

	for($i = 0; $i <= $#fldname; $i++) {

		if($fldname[$i] eq "") {
			$fldname[$i] = "\&nbsp;";
		}
		$strline .= "<td><b>$fldname[$i]</b></td>\n";
	}

	$strline = "<tr bgcolor=\"pink\">\n$strline</tr>\n";

	&ExecSQL("SELECT * from $tname"); #�ӣѣ�ʸ�¹�
	$numRows 	= $sth->rows;			#�Կ�
	$numFields 	= $sth->{'NUM_OF_FIELDS'};	#���ܿ�

	#���ܤ��Ф���Х���ɤ򤹤�
	for($i = 1; $i <= $numFields; $i++) {
		$sth->bind_col($i, \$field[$i], undef);
	}


	#�ᥤ��ơ��֥���������
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


	#�ơ��֥�����
	$strline = join("","
		<table style=\"font-size:10pt\" border=\"1\">
		$strline
		</table>
		");

	return $strline;
}

#=====================================================================
# [Function		] ExecSQL
# [Contents     ] �ӣѣ̼¹�
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)cmd:SQL���ޥ��ʸ����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub ExecSQL {
	local($cmd) = @_;	

	$sth = $dbh->prepare($cmd);
	$sth->execute();

}

#=====================================================================
# [Function		] MakeArrayBySpecCat
# [Contents     ] ����ե�����ɤ�����������
#---------------------------------------------------------------------
# [Return       ] (string array)strarray:����ե�����ɤ�����
# [Input        ] (string)name:�ե������̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
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
# [Contents     ] �ե�����to�ơ��֥�
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)fname:�ե�����̾
#				  (string)tname:�ơ��֥�̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeTableFromCSVFile {
	local($fname,$tname) = @_;
	local($i,$fdata,$fldstat,$query,$fld,@fdataarray,@fldstatarray);

	$fld = "";

	#�ե������ɤ߹��ߡʥ��ֶ��ڤ��
	$fdata = &JE(&ReadFileData("$fname",3));
	@fdataarray = split(/\n/,$fdata);

	#����ܤ������
	shift(@fdataarray);
	$fldstat = shift(@fdataarray);

	#���ܽ���
	$fldstat =~ s/\t/,/g;
	@fldstatarray = split(/,/,$fldstat);



	#�ơ��֥����  --------------��������
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


	#�Ԥ��ȤΣɣΣӣţңԥ롼�� --------------��������
	for($i = 0; $i <= $#fdataarray; $i++) {
		$query = "";

		if($fdataarray[$i] eq "") {
			next;
		}

		$fdataarray[$i] = &JE($fdataarray[$i]); #�����ɲáʽ��ס�

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
# [Contents     ] ����ơ��֥뤫����ꥭ���λ�����ܤ��������
#---------------------------------------------------------------------
# [Return       ] (string)strline:CSV�ǡ���ʸ����
# [Input        ] (string)fname:�ե�����̾
#				  (string)tname:�ơ��֥�̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub MakeCSVFileFromTable {
	local($fname,$tname) = @_;
	local($i,$numRows,$numFields,$fldtype,$fldbyte,$fldlabel,$strline,@field,@fldname,@fldtype,@tmparray);

	#�ե������̾��إåɤ�����
	&ExecSQL("DESC $tname"); #�ӣѣ�ʸ�¹�
	@fldname = &MakeArrayBySpecCat("Field");

	&ExecSQL("DESC $tname");
	@fldtype = &MakeArrayBySpecCat("Type");

	for($i = 0; $i <= $#fldname; $i++) {

		if($fldname[$i] eq "") {
			$fldname[$i] = "\&nbsp;";
		}

		$fldtype = &GetFieldType(1,$tname,$fldname[$i]);

		# VARCHAR �ξ��
		if(($fldtype =~ /varchar/)) {
			$fldtype =~ /varchar\((.*)\)/;
			$fldbyte = $1;
			$fldlabel = "$fldname[$i]_vc:$fldbyte";
		}
		#CAHR �ξ��
		if(($fldtype =~ /char/)) {
			$fldtype =~ /char\((.*)\)/;
			$fldbyte = $1;
			$fldlabel = "$fldname[$i]_vc:$fldbyte";
		}
		# TEXT�ξ��
		elsif($fldtype =~ /text/) {
			$fldlabel = "$fldname[$i]_txt";
		}

		push(@tmparray,$fldlabel);
	}

	$strline .= (join("\t",@tmparray) . "\n") x 2;


	@tmparray = ();

	&ExecSQL("SELECT * from $tname"); #�ӣѣ�ʸ�¹�
	$numRows 	= $sth->rows;			#�Կ�
	$numFields 	= $sth->{'NUM_OF_FIELDS'};	#���ܿ�

	#���ܤ��Ф���Х���ɤ򤹤�
	for($i = 1; $i <= $numFields; $i++) {
		$sth->bind_col($i, \$field[$i], undef);
	}


	#�ᥤ��ơ��֥���������
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


	#�ե�����񤭹���
	&RecordFileData($fname,4,&JS($strline));

	return $strline;


}

#=====================================================================
# [Function		] GetSpecFieldBySpecKeyFromSpecTable
# [Contents     ] ����ơ��֥뤫����ꥭ���λ�����ܤ��������
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:���������ǡ���ʸ����
# [Input        ] (string)mode:���ץ����
#							1:ɸ��
#				  (string)tname:�ơ��֥�̾
#				  (string)key_fldname:�ե������̾
#				  (string)key_fldvalue:�ե�����ɤ���
#				  (string)fldname:��������ե������̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub GetSpecFieldBySpecKeyFromSpecTable {
	local($mode,$tname,$key_fldname,$key_fldvalue,$fldname) = @_;

	if($mode eq 1) {
		&ExecSQL("SELECT $fldname FROM $tname WHERE $key_fldname = '$key_fldvalue'");

		#�ѿ���Ǽ
		$ref = $sth->fetchrow_hashref();
		$strtmp = $ref->{$fldname};
		$rc = $sth->finish;


		return $strtmp;
	}


}

#=====================================================================
# [Function		] GetFieldType
# [Contents     ] ������ܤΥե�����ɥ����פ��������
#---------------------------------------------------------------------
# [Return       ] (string)fldtype:�ե�����ɤΥ�����
# [Input        ] (integer)mode:���ץ����
#						1:ɸ��
#				  (string)tname:�ơ��֥�̾
#				  (string)fldname:�ե������̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
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
# [Contents     ] ����ե�����ɥ����פ���Х��ȿ����������
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:�Х��ȿ�
# [Input        ] (string)fldtype:�ե�����ɤΥ�����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
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
# [Contents     ] Ϣ������� SET ʸ����ˤ���ʥե��륿���Ĥ���
#---------------------------------------------------------------------
# [Return       ] SET k=v....��ʸ����
# [Input        ] (integer)mode:���ץ����
#				  (string array)remove:SET���ʤ��ե�����ɤ�����
#				  (hash)hash:SET����Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
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
# [Contents     ] �Կ����������
#---------------------------------------------------------------------
# [Return       ] (integer)strtmp:�Կ�
# [Input        ] (string)q:SQL���ޥ��
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
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
# [Contents     ] ���ܤ��Ȥ����󲽤���
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string array)strarray:���ܤ�����
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
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
# [Contents     ] �Х��ȿ���Ķ���Ƥʤ�����ǧ (form�򻲾�)
#---------------------------------------------------------------------
# [Return       ] (boolean)1=Ķ���Ƥ�,0=Ķ���Ƥʤ�
# [Input        ] (string)tname:�ơ��֥�̾
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub IsOverString {
	local($tname) = @_;

	#�ե������̾��إåɤ�����
	&ExecSQL("DESC $tname"); #�ӣѣ�ʸ�¹�
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
# [Contents     ] sth ���������ܤ��ͤ����
#---------------------------------------------------------------------
# [Return       ] (string)strtmp:mode��1�λ����ͤ��֤�
# [Input        ] (integer)mode:���ץ����
#						1:��Ĥ��ͤ����
#						2:�����Х��ѿ��˥��åȤ���
#						3:Ϣ������˥��åȤ���
#				  (string)q:����̾
#				  (string array)strarray:���ܤ�����
#				  (hash)hash:Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
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
# [Contents     ] form �ѿ������ơ��֥����Ͽ
#---------------------------------------------------------------------
# [Return       ] �ʤ�
# [Input        ] (string)tname:�ơ��֥�̾
#				  (hash)hash:Ϣ������
#---------------------------------------------------------------------
# [Create       ] 2002. 7.15  by K.Hamada (TechnoVan) - Perl��
# [Update       ] 
#=====================================================================
sub InsertFromHash {
	local($tname,*hash) = @_;
	local($q,$TMP,$StrSET,@qfld);

	#INSERTʸ����
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


	#��Ͽ�¹� --------------- ��������
	&ExecSQL($q);
}

#### #    # ####
#    ##   # #   #
#### # #  # #   #
#    #  # # #   #
#### #   ## ####
1;