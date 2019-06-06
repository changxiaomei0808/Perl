#!/usr/bin/env perl
use strict;
#########################################################################
# Author: Chang, Jiyang
# Created Time: 2019年06月06日 星期四 11时12分01秒
#########################################################################
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);

my $usage='
        perl $0 -i input -o output

        -h|--help   Introduction
        -i|--input  Information of plastid genome dowloaded from NCBI,including species name,length of plastid genomes and sequence ID
        -o}--output Optional,default suffix:out
';

my ($help,$input,$output);

GetOptions(
        "help|h!" => \$help,
        "input|i=s" => \$input,
        "output|o=s" =>\$output,
);

if($help || !$input){
    print $usage;
    exit;
}
die "cannot open the file\n" unless -e $input;

if(!$output){
    $output=$input=~s/\.\w+/_out.txt/r;
}


my ($first,$second,$third);
open TXT,$input || die "cannot open the file\n";
open OUT,">$output";
print OUT "species\tsequence_length\tseqence_id\n";
while(<TXT>){
    chomp;
    next if(/(\A\s*\Z)|!(complete genome)|!(organelle: plastid)/);
    $first=$_=~/^(\d+\.)
                \s(\S+\s\S+)
                (\sisolate\s\S+\s)?
                (\svar\.\s\w+\s)?
                (\svoucher\s\w+\s)?
                /x;
    print OUT "$1$2$3$4$5\t";
    $second=<TXT>=~/^(\d+,\d+)\sbp/;
    print OUT "$1\t";
    $third=<TXT>=~/^(\w+\.\d*)/;
    print OUT "$1\n";
}
close TXT;







