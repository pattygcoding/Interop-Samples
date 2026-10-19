#!/usr/bin/env perl

# Interop sample: prints the arithmetic mean of the numbers given on the
# command line.
#
# Invoked by Main.hx; see README.md for build and run instructions.

use strict;
use warnings;

use Scalar::Util qw(looks_like_number);

my @numbers = @ARGV;

if (!@numbers) {
    print STDERR "error: no numbers supplied\n";
    exit 1;
}

for my $number (@numbers) {
    if (!looks_like_number($number)) {
        print STDERR "error: '$number' is not a number\n";
        exit 1;
    }
}

my $sum = 0;
$sum += $_ for @numbers;

printf "%.2f\n", $sum / scalar(@numbers);
