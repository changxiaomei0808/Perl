#!/usr/bin/env perl
use strict;
use warnings;
#########################################################################
# Author: Ma, Xiao
# Created Time: 2019年06月05日 星期二 16时03分51秒
#########################################################################
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
my ($input,$output,$line,%count_hash);
GetOptions(
    "input|i=s" => \$input,
    "output|o=s" => \$output,
);
die "perl $0 --input input(输入文件) --output output(输出文件的名字)\n" unless ($input and $output);
open CSV,$input||die("can not open the file!");
<CSV>;
while(<CSV>){
    chomp;
    $_=~s/ CDS//g;
    my @lines=split(/,/,$_);
    my $gene=$lines[1];
    $count_hash{$gene}++;
}
my @uniq_gene_array=keys %count_hash;
print "@uniq_gene_array\n";
open OUT,">>$output";
foreach (@uniq_gene_array){
    print OUT "\t$_\t";
}
my $multi_hash={}; #创建多维哈希
seek CSV,0,0;
<CSV>;
while(<CSV>){#遍历文件
    chomp($_); #去除换行符
    $_=~s/ CDS//g;
    my @lines=split(/,/,$_);#用，分割
    $multi_hash->{$lines[0]}->{$lines[1]}=length($lines[2]); #给多维哈希赋值
}
###############################以下是遍历多维哈希###########################
foreach my $species(keys %{$multi_hash}){
    print OUT "\n$species\t";
    foreach my $value(@uniq_gene_array){
        if(exists $multi_hash->{$species}->{$value}){
            print OUT "$multi_hash->{$species}->{$value}\t";
        }else{
            print OUT "O\t";
        }
    }
}

