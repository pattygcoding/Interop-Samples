#!/usr/bin/perl
use strict;
use warnings;

# Number to calculate factorial for
my $number = 5;

# Command to run the Prolog script
my $prolog_command = "swipl -q -f factorial.pro -g main -- $number";

# Execute the Prolog script and capture the output
my $result = `$prolog_command`;

# Check if the result is defined and print it
if (defined $result) {
    chomp($result);
    print "The factorial of $number is: $result\n";
} else {
    print "Failed to calculate factorial.\n";
}
