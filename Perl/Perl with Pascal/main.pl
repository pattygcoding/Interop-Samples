#!/usr/bin/perl
use strict;
use warnings;

# Define a list of numbers
my @numbers = (10, 20, 30, 40, 50);

# Write the list of numbers to a temporary data file
open(my $data_fh, '>', 'numbers.txt') or die "Could not open file 'numbers.txt' $!";
print $data_fh join(" ", @numbers);
close $data_fh;

# Compile the Pascal program using the Free Pascal Compiler (fpc)
system("fpc average.pas");

# Run the Pascal program and capture the output
my $average = `./average`;

# Print the calculated average
print "The average is: $average";
