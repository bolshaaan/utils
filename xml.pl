#!/usr/bin/perl


use strict;
use warnings;
use DBI;
use utf8;

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



my @ins_cat_desc = ();
my @ins_cat = ();
my $i = 0;
sub _rc {
	my $parent = shift;
	my $h = shift;

	foreach my $k (keys %$h) {
		++$i;
		print sprintf("%s\n", $k);
		print sprintf("id= %s, parent = %s\n", $i, $parent);

		push(@ins_cat_desc, "(" .   join(',',  $i, $dbh->quote( encode_utf8( $k ) ))   .")" );
		push(@ins_cat, "(" .   join(',', $i, $parent) . ")" );
		_rc($i, $h->{ $k });
	}

	return;
}



_rc(0, $cats);



use Data::Dumper;
print Dumper \@ins_cat_desc;
print Dumper \@ins_cat;


$dbh->do("truncate table oc_category");

$dbh->do("
	insert into
		oc_category(
			category_id,
			parent_id
		)
	values
		" .  join(',' , @ins_cat )  . "
");



$dbh->do("truncate table oc_category_description");

$dbh->do("
	insert into
		oc_category_description(
			category_id,
			name
		)
	values
		" .  join(',' , @ins_cat_desc )  . "
");



sub _connect {

	my $dbh = DBI->connect(  "DBI:mysql:database=store;host=localhost", 'root', '', { RaiseError => 1, mysql_enable_utf8 => 1 } );

	return $dbh;

}
