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
my $ref = XMLin($file)->{section};

my @ins_cat_desc = ();
my @ins_cat = ();
my @ins_cat_to_store = ();

my $cats = {};
foreach my $name (keys %$ref) {

	my $c = $ref->{$name};
	$cats->{ $c->{id} } = $c->{parent_id};

	push(@ins_cat_desc, "(" . 
		join(',',
			$c->{id},
			$dbh->quote($name),
			1,
		)
	. ")" );

	push(@ins_cat, "(" . 
		join(',',
			$c->{id},
			$c->{parent_id},
			1,
		)
	. ")" );

	push(@ins_cat_to_store, "(" . 
		join(',',
			$c->{id},
			0,
		)
	. ")" );
};

my @ins_cat_path = ();

for my $id (keys %$cats) {
	
	my $parent = $cats->{$id};

	my $cid = $id; 
	my @parents = ( $id );
	while ( $parent = $cats->{$cid} ) { $cid = $parent; push(@parents, $parent); };

	my $l = 0; 
	foreach my $p (reverse @parents) {
		push(@ins_cat_path, "(" .  join(',', $id, $p, $l++) . ")" );
	}
}

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
