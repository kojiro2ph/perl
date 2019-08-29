#!/usr/bin/perl
#
# perl2html.pl
# perl script ���饭����ɤʤɤ򥫥顼ɽ������ HTML �ե������Ĥ��롣
# perl2html �Ȥ����ץ����Ϥ��Ǥˤ��뤬�����ܸ���б����Ƥ��ʤ�����
# ���ܸ�Υ����ȹԤ�ʸ����������Τǡ������˺�ä���
# ������ɤΥ��顼�����ǥ��󥰤� XZ �Υǥե���ȥ��顼�˽�򤷤���

# ������ɤΥꥹ��
# �ϥ��饤�Ȥ�����������ɤ򤳤����ɲäǤ���
@keyword = qw (and chomp close die else elsif eq exit foreach if last local
 my open or print qw return split s sub system unlink use while);

# ���顼�����ɤ����
$color_comment    = "#FFFF00";
$color_keyword    = "#66FFFF";
$color_quote      = "#FFCC00";
$color_subroutine = "#FFCC00";

# �ե�����̾�����Ϥ��줿���ɤ���
$input = $ARGV[0];
if ($input eq ""){
    print "Input PERL script name.\n";
    exit(0);
    }
# �ե�����Υ����ץ�
open INP, "$input";
open OUT, ">$input.html";

&html_head();
foreach $line (<INP>){
    chomp $line;
    # �������Ѵ�
    $line =~ s/&/&amp;/g;
    $line =~ s/"/&quot;/g;
    $line =~ s/</&lt;/g;
    $line =~ s/>/&gt;/g;
    # �����ȹ�
    if ($line =~ /^[\s]*#/){
        $line = "<font color=$color_comment><b>$line</b></font>";
        }
    # ����
    $line =~ s|(&quot;[ -~]*&quot;)|<font color=$color_quote>$1</font>|g;
    # ���֥롼����
    $line =~ s|(&amp;[\w]+)|<font color=$color_subroutine><b>$1</b></font>|g;
    $line =~ s|^(sub [\w]+)|<font color=$color_subroutine><b>$1</b></font>|;
    # �������
    foreach $keyword (@keyword){
        $line =~ s|\b$keyword\b|<font color=$color_keyword><b>$keyword</b></font>|g;
        }
    # ���֤򥹥ڡ������Ѵ�
    $line =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
    print OUT "$line\n";
    }
&html_tail();
# ��λ��å�����
print "$input.html was created.\n";
exit (0);

sub html_head(){
local $buffer =<< "_END_";
<!DOCTYPE HTML PUBLIC "-|W3C|DTD HTML 4.0 Transitional|EN">
<HTML>
<HEAD>
   <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=EUC-JP">
   <TITLE>Penguin Club-Perl
</TITLE>
<LINK REL=StyleSheet HREF="style.css" TYPE="text/css">
</HEAD>
<BODY bgcolor="#000000" text="#FFFFFF">
<pre>
_END_
print OUT $buffer;
}

sub html_tail(){
local $buffer =<< "_END_";
</pre>
</UL></UL>
<BODY>
</HTML>
_END_
print OUT $buffer;
}
