use strict;
use warnings;
use Bio::SeqIO;
use Bio::DB::GenBank;
use Getopt::Std;
use vars qw( $opt_f );
getopts('f:');

if( $opt_f ){
	open IN, $opt_f or die $!;
	my $out = $opt_f;
	if( $out =~ /\./ ){
		$out =~ s/\.(\w+)/_out.csv/;
	}else{
		$out .= "\.csv"
	}
	print $out, "\n";
	open OUT, ">$out" or die $!;
	print OUT "Accession,Species,Genus,Family,Order,Phylum,Journal,Title,length,GC,updated_date\n";
	while( <IN> ){
		s/\r?\n//;
		s/\.\d+//;
		my %hash = acc2info( $_ );
		my $journal = $hash{'journal'};
		my $title = $hash{'title'};
        $journal=~s/,/./g;
        $title=~s/,/./g;
		print OUT "$_,$hash{'species'},$hash{'genus'},$hash{'family'},$hash{'order'},$hash{'phylum'},$journal,$title,$hash{'length'},$hash{'GC'},$hash{'date'}\n";
	}
}elsif( scalar @ARGV ){
	foreach my $arg ( @ARGV ){
		$arg =~ s/\.\d+//;
		my %hash = acc2info( $arg );
		print "$arg\n";
		print "\tSpecies: $hash{ 'species' }\n\tGenus: $hash{ 'genus' }\n\tFamily: $hash{'family'}\n\tOrder: $hash{'order'}\n\tPhylum: $hash{'phylum'}\n\tJournal: $hash{ 'journal' }\n\tTitle: $hash{ 'title' }\n\tLength: $hash{'length'}\n\tGC: $hash{'GC'}\n\tUpdated date: $hash{'date'}\n";
	}
}else{
	print "input an accession number of NCBI:\n";
	while( <> ){
		s/\r?\n//;
		s/\.\d+//;
		last unless $_;
		my %hash = acc2info( $_ );
		print "\tSpecies: $hash{ 'species' }\n\tClassification: $hash{ 'taxa' }\n\tJournal: $hash{ 'journal' }\n\tTitle: $hash{ 'title' }\n\tLength: $hash{'length'}\n\tGC: $hash{'GC'}\n\tUpdated date: $hash{'date'}\n";
	}
}


sub acc2info{
	my $acc = shift;
	my %info;
	my $gb = Bio::DB::GenBank->new();
	my $obj = $gb->get_Seq_by_acc( $acc );
	
	# title
	$info{'length'}=$obj->length;
	my $seq=$obj->seq;
	my $gc=$seq=~tr/GCgc/GCgc/;
	$info{'GC'}=sprintf "%.2f",$gc/$obj->length*100;

	my $anno_collection = $obj->annotation;
	my @annotations = $anno_collection->get_Annotations('reference');
	foreach my $value ( @annotations ){
		if ($value->tagname eq "reference") {
			my $title = $value->title();
			my $journal = $value->location();
			$info{ 'title' } = $title;
			$info{ 'journal' } = $journal;
			last;
		}
	}
	
	# species
	my $species = $obj->species->node_name;
	$info{ 'species' } = $species;
	my $genus = $species =~ s/^(\w+).*/$1/r;
	$info{ 'genus' } = $genus;

	my @classification = reverse $obj->species->classification;
	my @order=grep /ales$/,@classification;
    my $order_num=@order;
    if($order_num==1){
        $info{'order'}=$order[0];
    }else{
         print "This species belongs to different orders,please check it!\n";
    }
    my @family=grep /aceae$/,@classification;
    my $family_num=@family;
    if($family_num==1){
        $info{'family'}=$family[0];
    }else{
        print "This species belongs to different families,please check it!\n";
    }

    my %phylum=(
        "Chordata"=>1,
        "Mollusca"=>1,
        "Spermatophyta"=>1,
        "Angiospermae"=>1,
        "Gymnospermae"=>1,
        "Bryophyta"=>1,
        "Marchantiophyta"=>1,
        "Pteridophyta"=>1,
        "lycopodialeo"=>1,
        "Chlorophyta"=>1,
        "Eumycophyta"=>1,
        "Protozoa"=>1,
    );

    foreach (@classification){
        if(exists $phylum{$_}){
            $info{'phylum'}=$_;
        }
    }

	#updated date
	my @date = $obj->get_dates;
	$info{'date'} = $date[0];

	return %info;
}
