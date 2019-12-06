#!/usr/bin/env perl -w

my $usage="
perl $0 unjoined.fastq R1.fastq R2.fastq

unjoined.fastq : *.unjoined.fastq produced by join_overlap_reads of clc_assembly_cell software

R1.fastq : R1 output file

R2.fastq : R2 output file

Split unjoined data into paired-end data 		

Created by Xiao Ma; 05/12/2019
		
";

my $datestring = localtime();

if(@ARGV!=3){
	print $usage;
	print "$datestring\n";	
	exit;
};

my $file = shift or die;
my $r1 = shift or die;
my $r2 = shift or die;
my %data;

open IN,$file or die "cannot open the file,please try again.\n";
open OUT1,">$r1" or die;
open OUT2,">$r2" or die;

while(my $line=<IN>){	
	if($line =~ m/^@(\S+)\s/){
		if(exists($data{$1})){
			print OUT2 $line;
			$line=<IN>;
			print OUT2 $line;
			$line=<IN>;
			print OUT2 $line;		
			$line=<IN>;
			print OUT2 $line;
		}else{
			push(@{$data{$1}},$line);
			print OUT1 $line;
			$line=<IN>;
			print OUT1 $line;
			$line=<IN>;
			print OUT1 $line;
			$line=<IN>;
			print OUT1 $line;
		}
	}

}
close IN;


		


