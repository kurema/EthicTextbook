#/usr/bin/perl
use utf8;
use strict;

my %words=GetHtmlHash();

if(@ARGV == 1){
  open(my $F, "<", $ARGV[0]) or die;
  my $text = do { local $/; <$F> };
  print GetHtmlHeader();
  print TbHtml($text);
}

sub TbHtml{
  my ($text)=@_;
  my $result="";
  
  my $block="";
  my $block_closer="";
  my $para_opener="";
  my $para_closer="";
  my $line_start="";
  my $line_end="";
  
  my @lines=split(/\n/, $text);
  foreach my $line(@lines){
    if($line=~ /^\(\*\*(\w+)\*\*\)$/){
      #特殊パラグラフ指定は"(**type**)"で行う。
      my $class=$1;
      $block.=$line_end;
      my $template=$words{"para_special_open"};
      $template=~ s/\[CLASS\]/$class/g;
      $para_opener=$template;
      $para_closer=$words{"para_special_close"};
      $line_start=$para_opener;
      $line_end="";
    }elsif($line=~ /^\(\*(\w+)\*\)$/){
      #ブロック種類指定は"(*type*)"で行う。
      my $class=$1;
      $result.=$block.$line_end.$block_closer;
      $block=$words{"block_open"};
      $block=~ s/\[CLASS\]/$class/g;
      $para_opener=$words{"block_para_open"};
      $para_closer=$words{"block_para_close"};
      $block_closer=$words{"block_close"};
      $line_start=$para_opener;
      $line_end="";
    }elsif($line=~ /^(\#{1,6})/){
      #見出しはマークダウン相当
      my $level=length($1);
      $line=~ s/^\#{1,6}\s*//;
      $result.=$block.$line_end.$block_closer;
      $result.=$words{"h".$level."_open"}.$line.$words{"h".$level."_close"};
      $para_opener=$words{"content_open"};
      $para_opener=~ s/\[CLASS\]/level_$level/g;
      $para_closer=$words{"content_close"};
      $line_start=$para_opener;
      $block="";
      $block_closer="";
      $line_end="";
    }elsif($line=~ /^\s*$/){
      $block.=$line_end;
      $line_start=$para_opener;
      $line_end="";
    }else{
      $block.=$line_start.TextDecorate($line);
      if($line=~ /\s{2}$/){
        $line_start=$words{"break"};
      }else{
        $line_start=$words{"enter"};
      }
      
      $line_end=$para_closer;
    }
  }
  $result.=$block.$para_closer.$block_closer;
  return $result;
}

sub TextDecorate{
  my ($text)=@_;
  $text=~ s/\*\*([^\*]+)\*\*/$words{'decoration2_open'}$1$words{'decoration2_close'}/g;
  $text=~ s/\*([^\*]+)\*/$words{'decoration1_open'}$1$words{'decoration1_close'}/g;
  return $text;
}

sub GetHtmlHash{
  return (
    'enter' => "\n",
    'break' => "<br />\n",
    'block_open' => '<div class="[CLASS]">',
    'block_close' => "</div>\n",
    'block_para_open' => '<p>',
    'block_para_close' => "</p>\n",
    'para_special_open' => "<p class='[CLASS]'>",
    'para_special_close' => "</p>\n",
    'h1_open' => '<h1>',
    'h1_close' => "</h1>\n",
    'h2_open' => '<h2>',
    'h2_close' => "</h2>\n",
    'h3_open' => '<h3>',
    'h3_close' => "</h3>\n",
    'h4_open' => '<h4>',
    'h4_close' => "</h4>\n",
    'h5_open' => '<h5>',
    'h5_close' => "</h5>\n",
    'h6_open' => '<h6>',
    'h6_close' => "</h6>\n",
    'content_open' => "<p class='[CLASS]'>",
    'content_close' => "</p>\n",
    'decoration1_open' => '<span class="decoration1">',
    'decoration1_close' => "</span>",
    'decoration2_open' => '<span class="decoration2">',
    'decoration2_close' => '</span>'
  );
}

sub GetHtmlHeader{
# 汎用化の為にその内外部指定にするかも。
  return << "EOL";
<html>
  <head>
    <style>
div.question p.q:before, div.question p.a:before, div.question p.e:before{
  display: -webkit-flex;
  display: flex;
  -webkit-align-items: center;
  align-items: center;
  -webkit-justify-content: center;
  justify-content: center;
  height :2em;
  border-radius: 1em;
  text-align: center;
  font-weight: bold;
  color: white;
}
div.question p.q:before{
  content:"問題";
  background: #f08c32;
}
div.question p.e:before{
  content:"解説";
  background: gray;
}
div.question p.e, div.question p.e_noheader{
}
span.decoration1{
  font-weight: bold;
}
span.decoration2{
  color: orange;
}

body{
  counter-reset: chap-h1 chap-h2 chap-h3;
}

h1{
  counter-reset: chap-h2 chap-h3;
}
h1:before{
  counter-increment: chap-h1;
  content: "第" counter(chap-h1) "章";
  margin-right: 0.5em;
}
h2{
  counter-reset: chap-h3;
  display: block;
  background: #f08c32;
  height:1.8em;
}
h2:before{
  counter-increment: chap-h2;
  content: counter(chap-h1) "-" counter(chap-h2);
  margin-right: 0.5em;
}
h3{
}
h3:before{
  counter-increment: chap-h3;
  content: counter(chap-h1) "-" counter(chap-h2) "-" counter(chap-h3);
  margin-right: 0.5em;
}
h3:after{
  content:"";
  display: block;
  overflow: hidden;
  border-style: dashed;
  border-width: 1px;
  border-color: #f08c32;
}
h4{
  position: relative;
  margin-left:1.5em;
}
h4:before{
  width:1em;
  height:1em;
  border-radius: 0.1em;
  border-width:0.1em;
  border-color: #c85a00;
  background: #f08c32;
  border-style: solid;
  position: absolute;
  content: "";
  margin-left:-1.5em;
}

p.caption{
  font-size:0.8em;
  border-radius:0.4em;
  border-color:black;
  border-style:dotted;
  border-width:1px;
}
p.caption:before{
  content: "補遺";
  display: block;
  font-weight: bold;
}
p.desc{
  font-weight: bold;
}
    </style>
  </head>
  <body>
EOL
}
