#!/usr/bin/env perl

# Interop sample: Perl driving a SWI-Prolog program.
#
# Perl validates the input, runs `factorial.pro` with SWI-Prolog and captures
# the factorial that Prolog writes to stdout.
#
# See README.md for prerequisites and run instructions.

use strict;
use warnings;

use Cwd            qw(abs_path);
use File::Basename qw(dirname);

my $number = @ARGV ? $ARGV[0] : 5;

die "error: '$number' is not a non-negative integer\n"
    unless $number =~ /\A\d+\z/;

my $program = dirname(abs_path(__FILE__)) . '/factorial.pro';

my $result = `swipl -q -f "$program" -g main -- $number`;
if ($? != 0) {
    die "error: Prolog failed to compute the factorial (exit $?)\n";
}

chomp $result;

print "The factorial of $number is: $result\n";

