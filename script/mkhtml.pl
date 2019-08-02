#/usr/bin/perl
use utf8;
use strict;

my %words=GetHtmlHash();

if(@ARGV == 1){
  open(my $F, "<", $ARGV[0]) or die;
  my $text = do { local $/; <$F> };
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
      $line_start=$words{"enter"};
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
