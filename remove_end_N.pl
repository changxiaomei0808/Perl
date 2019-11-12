#!/usr/bin/env perl


my $in=shift;
my $out=shift;

open IN,$in or die "cannot read this file,please try again!\n";
open OUT,">$out" or die;

while(<IN>){
	if($_=~/N$/){
		$_ =~ s/([A|T|C|G])N+$/$1/;
		print OUT $_;
	}else{
		print OUT $_;
	}
}
close IN;

