#!/usr/bin/env perl
use strict;
#########################################################################
# Author: Ma, Xiao
# Created Time: 2019年06月25日 星期二 14时41分29秒
#########################################################################
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use Bio::Seq;
use Bio::SeqIO;
use Bio::PrimarySeq;

my (@gene,@total_gene,%hash,$total_len);
my $gb_file=shift;
my $species_name=shift;
my @cds_features=grep {$_->primary_tag eq 'gene'} Bio::SeqIO->new(-file=>"$gb_file",-format=>'genbank')->next_seq->get_SeqFeatures;

foreach my $feat_object(@cds_features){
    push @total_gene,$feat_object->get_tag_values('gene');
    next if($feat_object->has_tag('pseudo'));
    push @gene,$feat_object->get_tag_values('gene');
    for my $value($feat_object->get_tag_values('gene')){
        $hash{$value}=$feat_object->spliced_seq->length;
    }
}

foreach my $key(keys %hash){
    $total_len+=$hash{$key};
}

my $total_gene=@total_gene;
my $gene_number=@gene;
my $gene_aver=sprintf "%.2f",$total_len/$gene_number;


print "species_name\ttotal_gene\tgene_number\tgene_aver\n$species_name\t$total_gene\t$gene_number\t$gene_aver\n";



#my %hash=map {$_->get_tag_values('gene'),$_->get_tag_values('product')} @cds_features;
#foreach my $key(keys %hash){
#    print "$key-->$hash{$key}\n";

#}



