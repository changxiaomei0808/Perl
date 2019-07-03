#!/usr/bin/env perl
use strict;
#########################################################################
# Author: Ma, Xiao
# Created Time: 2019年07月03日 星期三 12时07分19秒
#########################################################################
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use Bio::Seq;
use Bio::SeqIO;
use Bio::Tools::Run::StandAloneBlastPlus;
use Bio::PrimarySeq;

my (%SeqFeatures_hash,@seqfeatures,@subfeatures,%hash,$cds,$num,$key_tag);

my $usage="perl $0 gb_file/accession\n";

unless(@ARGV==1){
    print "please see the usage!\n";
    die $usage;
}

my $input=shift;

if($input=~/gb$/){
    my $gb_file=$input;
    my $seq_object=Bio::SeqIO->new(-file=>$gb_file,-format=>'genbank')->next_seq;
    my %SeqFeatures_hash = SeqFeaturesToHash($seq_object);

    for my $key(keys %SeqFeatures_hash){
    print "gene: ", $SeqFeatures_hash{$key}{'gene'}, "\n";
    print "   product: ", $SeqFeatures_hash{$key}{'product'}, "\n";
    }
}else{
    my $acc=$input;
    my $gb=Bio::DB::GenBank->new();
    my $obj=$gb->get_Seq_by_acc($acc);
    my %SeqFeatures_hash = SeqFeaturesToHash($obj);

    for my $key(keys %SeqFeatures_hash){
    print "gene: ", $SeqFeatures_hash{$key}{'gene'}, "\n";
    print "   product: ", $SeqFeatures_hash{$key}{'product'}, "\n";
    }
}

sub SeqFeaturesToHash{
    my $seq_obj=shift;
    for my $feat($seq_obj->get_SeqFeatures){
        if($feat->primary_tag eq 'CDS'){
            $cds=$feat->primary_tag;
            $key_tag=$num.$cds;
            $num++;

            for my $tag($feat->get_all_tags){
                for my $val($feat->get_tag_values($tag)){
                    $hash{$key_tag}{$tag}=$val;
                }
            }
        }else{
            next;
        }
    }
    return %hash;
}


#for my $key(keys %SeqFeatures_hash){
#    print $key,"\n";
#    for my $k(keys $SeqFeatures_hash{$key}){
#        print "  $k: $SeqFeatures_hash{$key}{$k}\n";
#    }
#}




