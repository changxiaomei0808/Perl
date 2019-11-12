#!/usr/bin/env perl -w

use strict;
##=========================================================================
### Author: Ma, Xiao
### Created Time: 2019年11月12日 星期四 10时26分49秒
###=========================================================================
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);

my $usage=' 
		perl $0 tandem_file_by_mcscanx output

		tandem_file_by_mcscanx: the .tandem file using MCScanX to do the syntenic analysis.
		output: tandemly duplicated arrays of two or more genes based on tandem_file_by_mcscanx.

';
if(@ARGV!=2){
	print $usage;
	exit;
}

my $file=shift or die;
my $output=shift or die;
my %hash;
my @array;
open IN,$file or die;
open OUT,">middle.txt" or die;

while(<IN>){
	chomp;
	my @line=split(/,/,$_);
	if(grep /^$line[0]$/,@array){
		push(@array,$line[1]);
	}else{
		print OUT join(",",@array),"\n";
		@array=();
		push(@array,@line);
	}
}
print OUT join(",",@array),"\n";

close IN;
close OUT;
open IN,'middle.txt' or die;
open FILE,">$output" or die;
while(<IN>){
	chomp;
	next if $_=~/^\s*$/;
	print FILE ("$_\n");
}
close IN;
close FILE;

`rm middle.txt`;
