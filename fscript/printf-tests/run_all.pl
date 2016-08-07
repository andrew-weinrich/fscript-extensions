#!/usr/bin/perl

use strict;

use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

my $fscriptProgram = "../build/Release/fscript";

my @tests = qw(int hex octal float exp string);


foreach my $test (@tests) {
    print BOLD BLUE "Running test $test...\n";
    system $fscriptProgram, "printf_$test.fs";
}