#!/usr/bin/perl


use strict;
use warnings;
use DBI;
use utf8;

use autodie qw(:default);

use Method::Signatures;
use XML::Simple;

use Encode qw(decode_utf8 encode_utf8);

my $file = shift @ARGV;

my $dbh = _connect();
my $ref = XMLin($file)->{item};

#use Data::Dumper;
#print Dumper $ref;
#exit;

my @ins_product = ();
my @ins_product_to_category = ();
my @ins_product_to_store = ();
my @ins_product_description = ();
my @ins_product_image = ();
my $cats = {};
foreach my  $name (keys %$ref) {

	my $t = $ref->{$name};

	my $r1 = ref $t->{rubric1} eq 'HASH' ? "" : $t->{rubric1};
	my $r2 = ref $t->{rubric2} eq 'HASH' ? "" : $t->{rubric2};
	my $r3 = ref $t->{rubric3} eq 'HASH' ? "" : $t->{rubric3};

#	next if ref $r1;
#	next if ref $r2;
#	next if ref $r3;

	$cats->{ $r1 }->{ $r2 }->{  $r3 } = undef;
#	print  $t->{rubric1} . " |  " . $t->{rubric2} . " |  " .  $t->{ rubric3 } . "\n";

	push(@ins_product_image, "(" . 
		join(',',
			$t->{id},
			$dbh->quote( 'data/store/' . $t->{photo} ),
		) .
	")");


	push(@ins_product_to_store, "(" . 
		join(',',
			$t->{id},
			0
		) .
	")");

	push(@ins_product_to_category, "(" . 
		join(',',
			$t->{id},
			$t->{section},
		) .
	")");


	push(@ins_product_description, "(" . 
		join(',',
			$t->{id},
			1, #language_id
#			$dbh->quote( $name =~ s/^.*?\///r ),
			$dbh->quote( $name ),
			$dbh->quote( $t->{description} ),
		) .
	")");


	push(@ins_product, "(" . 
		join(',',
			$t->{id},
#			$dbh->quote( $t->{image} ),
			$dbh->quote( 'data/store/' . $t->{photo} ),
			$dbh->quote( $t->{cost}  ),
			1,
			$t->{qty},
		)
	. ")");
}


my $parents = [];
my @ins_cat_desc = ();
my @ins_cat = ();
my @ins_cat_to_store = ();
my @ins_cat_path = ();

my $i = 0;
sub _rc {
	my $parent = shift;
	my $h = shift;

	foreach my $k (keys %$h) {
		next unless $k;
		++$i;

		push(@$parents, $i);

		print sprintf("%s\n", $k);
		print sprintf("id= %s, parent = %s\n", $i, $parent);

		push(@ins_cat_desc, "(" .   join(',',  $i, $dbh->quote( encode_utf8( $k ) ), 1)   .")" );
		push(@ins_cat, "(" .   join(',', $i, $parent, 1) . ")" );
		push(@ins_cat_to_store, "(" .   join(',', $i, 0) . ")" );
	
		my $level =0;
		foreach my $parent (@$parents) {
			push(@ins_cat_path, "(" . join(',', $i, $parent, $level++) . ")");
		}

		_rc($i, $h->{ $k });
		pop @$parents;
	}

	return;
}

_rc(0, $cats);

#use Data::Dumper;
#print Dumper \@ins_cat_desc;
#print Dumper \@ins_cat;
#print Dumper \@ins_cat_path;
#print Dumper \@ins_cat_to_store;
#
#exit 0;

_u_product($dbh, \@ins_product);
_u_product_description($dbh, \@ins_product_description);
_u_product_to_category($dbh, \@ins_product_to_category);
_u_product_image($dbh, \@ins_product_image);
_u_product_to_store($dbh, \@ins_product_to_store);

exit(0); 

func _u_product_to_store($dbh, $ins_product_to_store) {

	$dbh->do("truncate table oc_product_to_store");

	$dbh->do("
		insert into
			oc_product_to_store(
				product_id,
				store_id
			)
		values
			" .  join(',' , @$ins_product_to_store )  . "
	");
}
func _u_product_to_category($dbh, $ins_product_to_category) {

	$dbh->do("truncate table oc_product_to_category");

	$dbh->do("
		insert into
			oc_product_to_category(
				product_id,
				category_id
			)
		values
			" .  join(',' , @$ins_product_to_category )  . "
	");
}

func _u_product($dbh, $ins_product) {

	$dbh->do("truncate table oc_product");

	$dbh->do("
		insert into
			oc_product(
				product_id,
				image,
				price,
				status,
				quantity
			)
		values
			" .  join(',' , @$ins_product )  . "
	");
}

func _u_product_description($dbh, $ins_product_description) {

	$dbh->do("truncate table oc_product_description");

	$dbh->do("
		insert into
			oc_product_description(
				product_id,
				language_id,
				name,
				description
			)
		values
			" .  join(',' , @$ins_product_description )  . "
	");
}


func _u_product_image($dbh, $ins_product_image) {

	$dbh->do("truncate table oc_product_image");

	$dbh->do("
		insert into
			oc_product_image(
				product_id,
				image
			)
		values
			" .  join(',' , @$ins_product_image)  . "
	");
}

func _connect {

	my $dbh = DBI->connect(  "DBI:mysql:database=store;host=localhost", 'root', '', { RaiseError => 1, mysql_enable_utf8 => 1 } );

	return $dbh;

}
