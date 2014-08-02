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

my $cats = {};
foreach my  $t (values %$ref) {


	my $r1 = ref $t->{rubric1} eq 'HASH' ? "" : $t->{rubric1};
	my $r2 = ref $t->{rubric2} eq 'HASH' ? "" : $t->{rubric2};
	my $r3 = ref $t->{rubric3} eq 'HASH' ? "" : $t->{rubric3};

#	next if ref $r1;
#	next if ref $r2;
#	next if ref $r3;

	$cats->{ $r1 }->{ $r2 }->{  $r3 } = undef;
#	print  $t->{rubric1} . " |  " . $t->{rubric2} . " |  " .  $t->{ rubric3 } . "\n";
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
_u_category_description($dbh, \@ins_cat_desc);
_u_category($dbh, \@ins_cat);
_u_category_to_store($dbh, \@ins_cat_to_store);
_u_category_path($dbh, \@ins_cat_path);

exit(0); 

func _u_category_path($dbh, $ins_cat_path) {

	$dbh->do("truncate table oc_category_path");

	$dbh->do("
		insert into
			oc_category_path(
				category_id,
				path_id,
				level
			)
		values
			" .  join(',' , @$ins_cat_path)  . "
	");
}

func _u_category_to_store($dbh, $ins_cat_to_store) {

	$dbh->do("truncate table oc_category_to_store");

	$dbh->do("
		insert into
			oc_category_to_store(
				category_id,
				store_id
			)
		values
			" .  join(',' , @$ins_cat_to_store)  . "
	");
}

func _u_category($dbh, $ins_cat) {

	$dbh->do("truncate table oc_category");

	$dbh->do("
		insert into
			oc_category(
				category_id,
				parent_id,
				status
			)
		values
			" .  join(',' , @$ins_cat )  . "
	");
}


func _u_category_description($dbh, $ins_cat_desc) {

	$dbh->do("truncate table oc_category_description");

	$dbh->do("
		insert into
			oc_category_description(
				category_id,
				name,
				language_id
			)
		values
			" .  join(',' , @$ins_cat_desc )  . "
	");
}

func _connect {

	my $dbh = DBI->connect(  "DBI:mysql:database=store;host=localhost", 'root', '', { RaiseError => 1, mysql_enable_utf8 => 1 } );

	return $dbh;

}
