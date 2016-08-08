#!/usr/bin/perl


use strict;
use File::Basename;
use File::Glob ':glob';


my $outputFileName = "trampoline-x86-64.c";


#my $blrOpcode = hex "4e800020";

my $asmFileName = "trampoline-x86-64.asm";
my $intermediateFileName = "trampoline-x86-64.out";

# Compiling the x86-64 trampolines requires nasm 2.0 or later, which is not installed by Apple.
my $nasm = "$ENV{HOME}/Programming/Projects/F-Script/FSClass/nasm-2.01rc1/nasm";


system $nasm, '-l', $intermediateFileName, $asmFileName;



open my $codefile, '<', $intermediateFileName;
my @codeLines = <$codefile>;
close $codefile;

my %trampolines = (
     method0 => { tag => 'Zero-argument trampoline', code => '', len => 0 },
     method1 => { tag => 'One-argument trampoline', code => '', len => 0 },
     method2 => { tag => 'Two-argument trampoline', code => '', len => 0 },
     method3 => { tag => 'Three-argument trampoline', code => '', len => 0 },
     method4 => { tag => 'Four-argument trampoline', code => '', len => 0 },
     method5 => { tag => 'Five-argument trampoline', code => '', len => 0 },
);


foreach my $trampName (sort keys %trampolines) {
    my $code = '';
    my $length = 0;
    my $inMethod = 0;
    foreach my $line (@codeLines) {
        if ($line =~ /;;; $trampolines{$trampName}{tag}/) {
            print "Found trampoline $trampName\n";
            $inMethod = 1;
            next;
        }
        elsif ($line =~ /;;; end $trampolines{$trampName}{tag}/) {
            $inMethod = 0;
            print "Exiting trampoline $trampName\n";
            next;
        }
        
        if ($inMethod) {
            my ($lineNumber, $offset, $lineCode, $asm) = ($line =~ /^\s*(\d+) ([A-F0-9]+) ([A-F0-9]+)\s+(.+)/);
            next unless $offset;
            chomp $asm;
            $length += length($lineCode) / 2;
            $lineCode =~ s/([A-F0-9]{2})/\\x$1/g;
            $lineCode = qq|"$lineCode"|;
            $code .= sprintf qq|%-28s   // %s\n|, $lineCode, $asm;
        }
    }
    
#    print $code;
    
    # align code to 4-byte boundary for superstition's sake...
    if ($length % 4) {
        $code .= qq|"| . ("\\x00" x ($length % 4)) . qq|"|;
        $length += $length % 4;
    }
    
    $trampolines{$trampName}{code} = $code;
    $trampolines{$trampName}{len} = $length;
}


open my $cFile, '>', $outputFileName;

my $getterLength = $trampolines{getter}{len};
my $getterCode = $trampolines{getter}{code};



foreach my $key (sort keys %trampolines) {
    next if $key eq 'getter';
    my $methodLength = $trampolines{$key}{len};
    my $methodCode = $trampolines{$key}{code};
    $methodCode ||= '""';
    print $cFile <<"C"
unsigned int ${key}_len = $methodLength;
char* $key = 
$methodCode
;
C
}


print $cFile <<"C";
/*
unsigned int method2_len = 0;
char* method2 = "";

unsigned int method3_len = 0;
char* method3 = "";

unsigned int method4_len = 0;
char* method4 = "";

unsigned int method5_len = 0;
char* method5 = "";
*/
/*
#define INIT_TRAMPOLINES {\\
method2_len = method0_len;\\
method2 = method0;\\
method3_len = method0_len;\\
method3 = method0;\\
method4_len = method0_len;\\
method4 = method0;\\
method5_len = method0_len;\\
method5 = method0;\\
}
*/
#define INIT_TRAMPOLINES 0
C



close $cFile;

