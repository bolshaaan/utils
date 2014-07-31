#!/usr/bin/perl


use strict;
use warnings;

use utf8;

use XML::Simple;


my $file = shift @ARGV;

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

use Data::Dumper;
$Data::Dumper::AutoEncode::ENCODING = 'utf8';
print Dumper $cats;


