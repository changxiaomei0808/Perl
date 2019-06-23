#!/usr/bin/env perl
use strict;
#########################################################################
# Author: Ma, Xiao
# Created Time: 2019年06月23日 星期日 10时56分55秒
#########################################################################
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);

my (%hash,$id,$input,$help,$num,$genome,$genome_length);
my $Usage='
    perl $0 -i input -g genome

    -i|--input  gene fasta file
    -g|--genome genome fasta file
';

GetOptions(
    "help|h!"=>\$help,
    "input|i=s"=>\$input,
    "genome|g=s"=>\$genome,
);

if($help or !$input){
    print $Usage;
    exit;
}

open IN,$input or die "cannot find the fasta file!\n$!\n";

while(<IN>){
    chomp;
    if(/^>(\w+)/){
        $id=$_;
        $hash{$id}="";
    }else{
        $hash{$id}.=$_;
    }
}
close IN;

$num=&qianfen($num=keys %hash);
print "Gene number\t$num\n";

open IN,$genome or die "cannot open the genome fasta file!\n$!\n";

while(<IN>){
    chomp;
    next if(/^>(\w+)/);
    $genome_length += length $_;
}
print "Genome length\t$genome_length\n";

my ($gene_total_len,$gene_average_len,$gc,$gene_gc,$gene_content);
foreach my $key(keys %hash){
    $gene_total_len += length($hash{$key});
    $gene_gc=$hash{$key}=~tr/GCgc/GCgc/;
    $gc+=$gene_gc;
}

$gene_average_len=sprintf "%.2f",$gene_total_len/($num=keys %hash);
$gene_average_len=&qianfen($gene_average_len);
$gc=sprintf "%.2f",$gc/$gene_total_len*100;
$gene_content=sprintf "%.2f",$gene_total_len/$genome_length*100;
$gene_total_len=&qianfen($gene_total_len);
print "Gene arverage length is $gene_average_len\n";
print "GC content in gene region(%) is $gc\n";
print "Gene length is $gene_total_len\n";
print "Gene content in genome(%) is $gene_content\n";


sub qianfen{
  my $number = shift @_;
  for ( $number ) { /\./ ? s/(?<=\d)(?=(\d{3})+(?:\.))/,/g : s/(?<=\d)(?=(\d{3})+(?!\d))/,/g; }
  return $number; 
}
