#!/usr/bin/env perl
#
# Interop sample: prints the arithmetic mean of the numbers given on the command
# line.
#
# Invoked by main.js; see README.md for build and run instructions.

use strict;
use warnings;

if (@ARGV == 0) {
    print STDERR "error: no numbers supplied\n";
    exit 1;
}

my $total = 0;

for my $token (@ARGV) {
    # Check the shape first: Perl would happily read "12abc" as the number 12.
    if ($token !~ /\A-?(?:\d+(?:\.\d*)?|\.\d+)\z/) {
        print STDERR "error: '$token' is not a number\n";
        exit 1;
    }

    $total += $token;
}

printf "%.2f\n", $total / scalar @ARGV;
