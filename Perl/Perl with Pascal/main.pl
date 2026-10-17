#!/usr/bin/env perl

# Interop sample: Perl driving a compiled Free Pascal helper.
#
# Perl writes the numbers to a temporary text file, compiles `average.pas` with
# the Free Pascal Compiler in a scratch directory, runs the resulting program
# and prints the average it produces.
#
# See README.md for prerequisites and run instructions.

use strict;
use warnings;

use Cwd           qw(abs_path getcwd);
use File::Basename qw(dirname);
use File::Copy    qw(copy);
use File::Temp    qw(tempdir tempfile);
use Scalar::Util  qw(looks_like_number);

my @numbers = @ARGV ? @ARGV : (10, 20, 30, 40, 50);

die "error: no numbers supplied\n" unless @numbers;

for my $number (@numbers) {
    die "error: '$number' is not a number\n" unless looks_like_number($number);
}

# 1. Hand the data over through a temporary text file.
my ($data_fh, $data_file) = tempfile('numbers-XXXXXX', SUFFIX => '.txt', UNLINK => 1);
print {$data_fh} join(' ', @numbers), "\n";
close $data_fh;

# 2. Compile the Pascal helper in its own scratch directory so no build
#    artefacts are left behind.
my $here    = dirname(abs_path(__FILE__));
my $workdir = tempdir('pascal-XXXXXX', CLEANUP => 1);

copy("$here/average.pas", "$workdir/average.pas")
    or die "error: cannot copy average.pas: $!\n";

my $original_dir = getcwd();
chdir $workdir or die "error: cannot enter $workdir: $!\n";
my $compiler_output = `fpc average.pas 2>&1`;
my $compiler_status = $?;
chdir $original_dir or die "error: cannot return to $original_dir: $!\n";

if ($compiler_status != 0) {
    die "error: failed to compile average.pas:\n$compiler_output\n";
}

my $executable = "$workdir/" . ($^O eq 'MSWin32' ? 'average.exe' : 'average');

# 3. Run the helper and capture the average it writes to stdout.
my $average = `"$executable" "$data_file" 2>&1`;
if ($? != 0) {
    chomp $average;
    die "error: Pascal helper failed: $average\n";
}

chomp $average;

print 'The average of ' . scalar(@numbers) . " value(s) is: $average\n";

