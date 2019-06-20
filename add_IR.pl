#!/usr/bin/env perl
use strict;
#########################################################################
# Author: Ma, Xiao
# Created Time: 2019年06月20日 星期四 14时09分49秒
#########################################################################
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);

my $Usage='
        perl $0 -i sequence_file -g annotation_file -o output

        -h|--help       Introduction
        -i|--input      sequence file(fasta)
        -g|--genebank   annotation file(gb)
        -o|--output     annotation file after adding IR
';

my ($help,$sequence_file,$annotation_file,$output,$count);

GetOptions(
        "help|h!"=>\$help,
        "input|i=s"=>\$sequence_file,
        "genebank|g=s"=>\$annotation_file,
        "output|o=s"=>\$output,
);

if(!($sequence_file && $annotation_file)){
        print $Usage;
        exit;
}

open IN,$sequence_file or die "cannot open the sequence file\n$!\n";

while(<IN>){
    if(/^>/){
        $count++;
    }else{
        next;
    }
}

if($count!=1){
    print "please enter a complete chloroplast genome without gaps\n";
}else{
    system("makeblastdb -in $sequence_file -dbtype nucl -out nr");
}

if(-e "nr.nsq" and -e "nr.nin" and -e "nr.nhr"){
    system("blastn -query $sequence_file -db nr -out blast_result.txt -evalue 10 -outfmt 6");
}else{
    print "fail to make database,please try again!\n";
}

close IN;

open OUT, 'blast_result.txt';
open GB,$annotation_file;
open RESULT,'>',$output;

my (@lines,$IRB_1,$IRB_2,$IRA_1,$IRA_2);

while(<OUT>){
    @lines=split /\t/,$_;
    if($lines[2]>99 and $lines[6]<$lines[7] and $lines[8]>$lines[9] and $lines[3]>10000 and $lines[6]<$lines[8]){
        $IRB_1=$lines[6];
        $IRB_2=$lines[7];
        $IRA_1=$lines[9];
        $IRA_2=$lines[8];
    }
}

while(<GB>){
    s/^(FEATURES.*)/$1\nrepeat_region        $IRB_1\.\.$IRB_2\n                     \/note=\"Inverted Repeat region B; IRB\"\n                     \/rpt_type=inverted\nrepeat_region        $IRA_1\.\.$IRA_2\n                     \/note=\"Inverted Repeat region A; IRA\"\n                     \/rpt_type=inverted/ if /^FEATURES/;
    print RESULT $_;
}
close GB;
