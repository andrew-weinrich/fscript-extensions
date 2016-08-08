#!/usr/bin/perl

open NUMBERS, '<', 'lotsanumbers.txt';

while (<NUMBERS>) {
    chomp;
    my $lineTotal = 0;
    my $lineCount = 0;
    foreach $number (split '\t') {
        $lineTotal += $number;
        $lineCount++;
    }
    print ($lineTotal/$lineCount);
    print ', ';
}
print "\n";