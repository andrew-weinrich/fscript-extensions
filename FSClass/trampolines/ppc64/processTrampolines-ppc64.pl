#!/usr/bin/perl


use strict;
use File::Basename;
use File::Glob ':glob';


my $outputFileName = "trampoline-ppc64.c";


#my $blrOpcode = hex "4e800020";




open my $cFile, '>', "$outputFileName";

foreach (bsd_glob("*.s")) {
    use bytes;
    open my $assemblyFile, '<', $_;
#    printf "$_\n";
    my $trampolineName = basename($_, '.s');
    $trampolineName =~ s/-64//g;
    
    #print "$trampolineName\n";
    
#    my @operations = map { chomp; $_ } <$assemblyFile>;
#    @operations = map { /^\s+(.+)/; $1 } grep !/^\s*$|^\S|^\s+;/, @operations;
    # count up the number of operations (non-blank/comment lines)
    my @operations = map { /^\s+(.+)/; $1 } grep(!/^\s*$|^\S|^\s+;/, map { chomp; $_ } <$assemblyFile>);
    
    
    # compute the size of the main function - PowerPC has exactly 4 bytes per operation
    my $mainLength = 4 * scalar(@operations);
    
    # write a simple command file for gdb
    my $gdbCommandFileName = 'commands';
    my $gdbOutFileName = 'main.bin';
    open my $gdbCommandFile, '>', $gdbCommandFileName;
    print $gdbCommandFile "dump binary memory $gdbOutFileName main main+$mainLength\nquit";
    close $gdbCommandFile;
    
    # compile assembly
    system 'gcc', '-arch', 'ppc64', '-o', $trampolineName, $_;
    
    
    # use gdb to dump out the relevant portion of the compiled file
    system 'gdb', '-x', $gdbCommandFileName, $trampolineName;
    
    
    my @opcodes = ();
    my $opcode = '';
    
    # keep reading until we get to the blr at the end of the method
    open my $executableFile, '<', $gdbOutFileName;
    while (1) {
        my $bytesRead = read($executableFile,$opcode,4);
        last if not $bytesRead;
        
        my $opcodeRepresentation = join '', map { sprintf "\\x%02x", $_ } unpack 'CCCC', $opcode;
        
        my $location = tell $executableFile;
        #print "Location: $location;  Opcode: '$opcode' $opcodeRepresentation\n";
        
        # skip no-ops
        push @opcodes, $opcodeRepresentation
        #    if $opcode != 0;
    };
    
    my $trampolineData = '';
    for (my $i = 0; $i < @opcodes; $i++) {
        $trampolineData .= qq|"$opcodes[$i]"  // $operations[$i]\n|;
    }
    
    
    # save C version of thunk data
    print $cFile <<"C";
unsigned int ${trampolineName}_len = $mainLength;
char* $trampolineName =
$trampolineData;

C
    
    # delete GDB command file
    unlink $gdbCommandFileName;
}

# print the optional initialization code - not needed for PPC
print $cFile "\n#define INIT_TRAMPOLINES 0\n";


close $cFile;

