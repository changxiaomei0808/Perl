#!/usr/bin/env perl
use strict;
#########################################################################
# Author: Ma, Xiao
# Created Time: 2019年07月03日 星期三 17时31分17秒
#########################################################################
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use Bio::Seq;
use Bio::SeqIO;
use Bio::Tools::Run::StandAloneBlastPlus;
use Bio::PrimarySeq;
use Bio::Graphics;
use Bio::SeqFeature::Generic;

my $usage="perl $0 gb_file/accesstion output\n";

if(@ARGV!=2){
    print $usage;
    exit;
}
my $input=shift or die "cannot open the file or get the file,please check it!\n$!\n";
my $output=shift or die;
open OUT,">result.txt" or die;
print OUT "Feature\tstart\tend\tstrand\tgene\n";

my $gb_file=$input;
my $seq_obj=Bio::SeqIO->new(-file=>$gb_file,-format=>'genbank')->next_seq;
my @features=grep {$_->primary_tag eq 'CDS'} $seq_obj->get_SeqFeatures;

for my $f(@features){
    print OUT $f->primary_tag,"\t";
    print OUT $f->start,"\t";
    print OUT $f->end,"\t";
    print OUT $f->strand,"\t";
    if($f->has_tag('gene')){
        print OUT join(",",$f->get_tag_values('gene'));
    }
    print OUT "\n";
}
close OUT;

my $maxlen=$seq_obj->length;

my $panel=Bio::Graphics::Panel->new(-length=>$maxlen,-width=>1000,-pad_left=>5,-pad_right=>5);

my $full_length=Bio::SeqFeature::Generic->new(-start=>0,-end=>$maxlen);

$panel->add_track($full_length,-glyph=>'arrow',-tick=>2,-fgcolor=>'black',-double=>1);

my $track=$panel->add_track(-glyph=>'transcript2',-label=>1,-bgcolor=>'red');
# my $track=$panel->add_track(-glyph=>'generic',-label=>1,-bgcolor=>'blue');

open IN,'result.txt';
while(my $in=<IN>){
    chomp($in);
    next if(/^Feature/);
    my($type,$start,$end,$strand,$name)=split(/\t+/,$in);
    next if($start>$end||$end>$maxlen);
    my $feature=Bio::SeqFeature::Generic->new(
                                                -display_name=>$name,
                                                -start=>$start,
                                                -end=>$end,
                                                -strand=>$strand
                                                );
    $track->add_feature($feature);
}
close IN;

open PNG,">$output";
binmode OUT;
print PNG $panel->png;
close OUT;


