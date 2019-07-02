#!/usr/bin/env perl

use strict;
#########################################################################
# Author: Ma, Xiao
# Created Time: 2019年06月29日 星期六 21时35分56秒
#########################################################################
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use Bio::Seq;
use Bio::SeqIO;
use Bio::Tools::Run::StandAloneBlastPlus;
use Bio::PrimarySeq;
use Bio::DB::GenBank;

my $usage="perl $0 accession/gb_file intergenic.fa\n";

unless(@ARGV==2){
    print "please see the usage!\n";
    die $usage;
}

my (@array,%gene_start,%gene_end,@gene_coord,@base,$output);

print "$ARGV[0]\n";

if($ARGV[0]=~/gb$/){
    my $gb_file=shift;
    my $output=shift;

    my $seqio_obj=Bio::SeqIO->new(-file=>"$gb_file",-format=>'genbank');
    my $seq_obj=$seqio_obj->next_seq;
    my $complete_seq=$seq_obj->seq;
    my @base=$complete_seq=~/([ATGC])/g;
    my @gene_coord = extract_gene_region($seq_obj);

    open OUT,">$output" or die "cannot open the file!\n";

    for my $i(0..$#gene_coord){
        if($i%3==1){
            next if($gene_coord[$i+1]>$gene_coord[$i+3]);
            print OUT ">The intergeneic region between $gene_coord[$i-1] and $gene_coord[$i+2]: $gene_coord[$i+1]->$gene_coord[$i+3]\n";
            my $intergeneic_region=join "",@base[$gene_coord[$i+1]..$gene_coord[$i+3]];
            print OUT "$intergeneic_region\n";
        }
    }
}else{
    my $acc=shift;
    my $output=shift;

    my $gb=Bio::DB::GenBank->new();
    my $obj=$gb->get_Seq_by_acc($acc);
    my $complete_seq=$obj->seq;
    my @base=$complete_seq=~/([ATGC])/g;
    my @gene_coord = extract_gene_region($obj);

    open OUT,">$output" or die "cannot open the file!\n";

    for my $i(0..$#gene_coord){
        if($i%3==1){
            next if($gene_coord[$i+1]>$gene_coord[$i+3]);
            print OUT ">The intergeneic region between $gene_coord[$i-1] and $gene_coord[$i+2]: $gene_coord[$i+1]->$gene_coord[$i+3]\n";
            my $intergeneic_region=join "",@base[$gene_coord[$i+1]..$gene_coord[$i+3]];
            print OUT "$intergeneic_region\n";
        }
    }
}

sub extract_gene_region{
    my $obj=shift;

    my @cds_obj=grep {$_->primary_tag eq 'gene'} $obj->get_SeqFeatures;

    my ($start,$end,$value);
    for my $cds(@cds_obj){
        if($cds->has_tag('gene')){
            for $value($cds->get_tag_values('gene')){
                next if($value eq 'rps12');
                $start=$cds->location->start;
                $end=$cds->location->end;
                if($gene_start{$value} && $gene_end{$value}){
                    my $value_IRB=$value;
                    $gene_start{$value_IRB}=$start;
                    $gene_end{$value_IRB}=$end;
                }else{
                    $gene_start{$value}=$start;
                    $gene_end{$value}=$end;
                }
                push @array,$value;
                push @array,$start;
                push @array,$end;
            }
        }
    }
    return @array;
}


