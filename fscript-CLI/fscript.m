#import <Foundation/Foundation.h>
//#import <FScript/FScript.h>
//#import "Block.h"
#import <stdio.h> 
#import "Functions.h"
#import "FSFile.h"
#import "FSFileStdin.h"

#import "FSToolHelp.h" 

#import "FSSystemUtility.h"

#import "interpreter.h"

#import <FScript/FScript.h>
#import <ExceptionHandling/NSExceptionHandler.h>




int main (int argc, const char * argv[]) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    int returnValue = 0;
    
    @try {
        FSInterpreter *interpreter = getGlobalInterpreter();
        
        
        // initialize library locations
        BOOL dummy;
        id sys = [interpreter objectForIdentifier:@"sys" found:&dummy];
        [sys initLibraries];
        
        
        // hacked-together version check
        if (argc==2 && strcmp(argv[1],"-v")==0) {
            [[sys out] println:[[sys help] version]];
            returnValue = 0;
        }
        
        // check syntax
        else if (argc==3 && strcmp(argv[1],"-c")==0) {
            NSString* filePath = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
            
            NSError* error;
            NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
            
            if (fileContents) {
                @try {
                    NSString* blockFormatString = [NSString stringWithFormat:@"[ %@ ]", fileContents];
                    [sys blockFromString:blockFormatString];
                    
                    [[sys out] printf:@"File %s syntax is OK\n" withValues:[NSArray arrayWithObject:filePath]];
                    returnValue = 0;
                }
                @catch (NSException* e) {
                    // catch and print any errors - unfortunately, does not have the line position...
                    [[sys out] printf:@"File %s has syntax errors: %@\n"
                        withValues:[NSArray arrayWithObjects:filePath, [e reason], nil]];
                    returnValue = 1;
                }
            }
            else {
                [[sys out] printf:@"Could not open file %s: %s\n"
                    withValues:[NSArray arrayWithObjects:filePath, [error localizedFailureReason], nil]];
                returnValue = 1;
            }
        }
        
        else if (argc==1) {
            returnValue = run_readline_interpreter(interpreter);
        }
        
        
        // run a script
        else {
            // make command-line arguments available
            NSMutableArray* args = [[NSMutableArray alloc] initWithCapacity:argc];
            for (int i = 2; i < argc; i++)
                [args addObject:[NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding]];
            scriptArgs = args;
            
            // make script name available
            scriptName = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
            
            @try {
                FSInterpreterResult* execResult = loadFile([NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding],NO,YES);
                
                if ([execResult isOK]) {  // test status of the result 
                    [execResult result];  // run the compiled code
                }
                else {
                    [[sys out] println:@"Error processing file"];
                }
            }
            @catch (NSException* error) {
                // catch and print any errors
                fprintf(stderr,"%s\n", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
                returnValue = -1;
            }
            [args release];
        }
    }
    @catch (NSException* e) {
        NSLog(@"Uncaught exception: %@", e);
        NSString *stackTrace = [[e userInfo] objectForKey:NSStackTraceKey];
        NSString *str = [NSString stringWithFormat:@"/usr/bin/atos -p %d %@ | tail -n +3 | head -n +%lu | c++filt | cat -n",
                         [[NSProcessInfo processInfo] processIdentifier],
                         stackTrace,
                         ([[stackTrace componentsSeparatedByString:@"  "] count] - 4)];
        FILE *file = popen( [str UTF8String], "r" );
        
        if( file )
        {
            char buffer[512];
            size_t length;
            
            fprintf( stderr, "Stack trace:\n" );
            
            while( (length = fread( buffer, 1, sizeof( buffer ), file )) )
            {
                fwrite( buffer, 1, length, stderr );
            }
            
            pclose( file );
        }
        returnValue = -1;
    }
    
    
    
    [pool release];
    
    return returnValue;
}
