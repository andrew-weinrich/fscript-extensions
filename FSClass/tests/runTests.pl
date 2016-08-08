#!/usr/bin/perl


use strict;
use File::Basename;
use Term::ANSIColor;

my @tests = qw(
    bad-names
    
    trampolines
    
    inheritance1
    inheritance2
    inheritance3
    
    property-names
    properties-slow
    properties-fast
    properties-inheritance
    
    proxies
    
    kvc
    method-implementor
    method-replacement
    getClass
    description
    class-simple
    
    super
    
    selector
    
    general
);

my $fscriptProgram = "..//Projects/F-Script/fscript-CLI/fscript/fscript/build/Debug/fscript";
#my $fscriptProgram = "/usr/bin/fscript";



if (@ARGV) {
    @tests = @ARGV;
}

foreach my $test (@tests) {
    my $errorFileName = "$test.err";
    my $outputFileName = "$test.out";
    my $diffFileName = "$test.diff";
    
    # clear out files from old runs
    unlink $errorFileName if -f $errorFileName;
    unlink $outputFileName if -f $outputFileName;
    unlink $diffFileName if -f $diffFileName;
    
    system qq|"$fscriptProgram" $test.test >$outputFileName 2>$errorFileName|;
    
    if ($?) {
        print colored("Error: ","bold red"), "test '$test' exited with error; try looking at $outputFileName and $errorFileName for possible information\n";
        next;
    }
    
    `diff $outputFileName $test.output > $test.diff`;
    
    
    if (-s $diffFileName) {
        print colored("Error: ", "bold red"), "test '$test' failed, see $diffFileName for details\n";
    }
    else {
        print colored("Passed: ", "bold green"), "test '$test'\n";
        unlink $diffFileName;
        unlink $outputFileName;
    }
    
    if (-s $errorFileName) {
        print colored("Warning: ","bold"), "running test '$test' prints to stderr, see $errorFileName for details\n";
    }
    else {
        unlink $errorFileName;
    }
}