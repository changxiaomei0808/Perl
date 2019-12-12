#!/usr/bin/env perl -w

##=========================================================================
#### Author: Ma, Xiao
#### Created Time: 2019年11月12日 星期四 10时26分49秒
####=========================================================================

use strict;
use List::Util qw[min max];
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);

my $usage="
	perl $0 input output
	
	input:gff file that just includes the third, fourth,fifth line of containing gene and exon information; 

	output: the statistics of intron length; 
";
if(@ARGV!=2){
	print $usage;
	exit;
}else{

	my $input=shift or die;
	my $out=shift or die;
	my ($gene_name,$line,@line,@exon,%data,$intron_len,@intron_len,$index,$gene_count);
	$intron_len=0;
	$gene_count=0;
	my $count=1;
	@exon=();
	open IN,$input or die;
	open OUT,">$out" or die;
	print OUT "Gene_name\tintron_length\n";

	while(<IN>){
		chomp;
		if($_=~/^gene/){
			if(@exon==0){
				@line=split(/ /,$_);
				$gene_name=join("_",@line);
				$gene_count+=1;
				$data{$gene_name}=$gene_count;
				print "基因为： $gene_name\n";
			}elsif(@exon!=0){
				if(@exon==2){
					print OUT "There no introns in this gene\n";
					print "There no introns in this gene\n";
				}else{
					for($index=0; $index<$#{exon}-2; $index=$index+2){
						$intron_len=0;
						$intron_len=$exon[$index+2]-$exon[$index+1];
						print OUT "第$count个 intron length is $intron_len\n";
						print "第$count个 intron length is $intron_len\n";
						push(@intron_len,$intron_len);
						$count++;
					}
				}
				$count=1;
				@exon=();	
				@line=split(/ /,$_);
				$gene_name=join("_",@line);
				$data{$gene_name}=$gene_count;
				print OUT "基因为： $gene_name\n";
				print "基因为： $gene_name\n";
			}
		}elsif($_=~/^exon/){
			@line=split(/ /,$_);
		#	print "$line[1]\t$line[2]\n";
			push(@exon,$line[1]);
			push(@exon,$line[2]);
		}
	}
	my @abs_intron_len=map abs($_),@intron_len;
	my $maxintron = max(@abs_intron_len);
	print "@abs_intron_len\n";	
	print "max intron is $maxintron\n"
}
			
