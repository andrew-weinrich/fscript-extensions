//
//  interpreter.m
//  fscript
//
//  Created by Andrew Weinrich on 2/1/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import "FSFile.h"

#import "interpreter.h"

#include <histedit.h>
#include <FScript/FScript.h>

#include <signal.h>


#include "FSSystemUtility.h"


NSString* interpreterVersion = @"2.2";



typedef void (*signalHandler)(int);


void catchInterrupt(int sig) {
    FSExecError(@"Caught interrupt; use 'sys exit' to quit\n");
    //printf("Caught interrupt; use 'sys exit' to quit\n");
}


const char* defaultPrompt = "F-Script> ";
const int defaultPromptLength = 10;


char* regularPrompt(EditLine* e) {
    return (char*)defaultPrompt;
}

// same as regularPrompt, but bold
char* regularPromptColor(EditLine* e) {
    return "\033[1;30m" "F-Script> " "\033[0m";
}


static char* currentNestings = NULL;
static int currentNestingsLength = 0;
static char* currentPrompt = NULL;

char* nestedPrompt(EditLine* e) {
    if (currentPrompt)
        free(currentPrompt);
    
    currentPrompt = malloc(defaultPromptLength+1);
    strncpy(currentPrompt,currentNestings,currentNestingsLength);
    
    // pad to the length of the default prompt
    int i;
    for (i = currentNestingsLength; i < defaultPromptLength - 3; i++) {
        currentPrompt[i] = ' ';
    }
    
    currentPrompt[i] = ' ';
    currentPrompt[i+1] = '>';
    currentPrompt[i+2] = ' ';
    currentPrompt[i+3] = '\0';
    
    return currentPrompt;
}



const char* colorPromptStart = "\033[1;30m";
const int colorPromptStartLength = 7;
const char* colorPromptEnd =  "\033[0m";
const int colorPromptEndLength = 4;
// same as nestedPrompt, but does ANSI color highlighting
char* nestedPromptColor(EditLine* e) {
    char* prompt = nestedPrompt(e);
    int promptLength = strlen(prompt);
    int colorPromptLength = promptLength + colorPromptStartLength + colorPromptEndLength;
    
    
    char* colorPrompt = (char*)malloc(colorPromptLength+1);
    strncpy(colorPrompt,colorPromptStart,colorPromptStartLength);
    strncpy(colorPrompt+colorPromptStartLength,prompt,promptLength);
    strncpy(colorPrompt+colorPromptStartLength+promptLength,colorPromptEnd,colorPromptEndLength);
    
    colorPrompt[colorPromptLength] = '\0';
    
    free(prompt);
    return colorPrompt;
}





// this should really be resizable...
#define MAX_NESTINGS_SIZE 80
char* findNestings(char* prevNestings, const char* line) {
    char* nestings = malloc(MAX_NESTINGS_SIZE * sizeof(char));
    
    // if there were any previous nestings, copy them over and free the old
    // nesting string
    char* nestChar;
    unsigned int nestLen;
    if (prevNestings) {
        nestLen = strlen(prevNestings);
        strncpy(nestings,prevNestings, nestLen);
        free(prevNestings);
        nestChar = nestings + nestLen - 1;
    }
    else {
        *nestings = '\0';
        nestChar = nestings - 1;
        nestLen = 0;
    }
    
    const char* lineChar = line;
    
    
    // check to see if we are inside a comment or string, which will
    // disable nesting of the other characters
    BOOL inString  = (nestChar+1!=nestings && *nestChar=='\'');
    BOOL inComment = (nestChar+1!=nestings && *nestChar=='"');
    
    
    while (*lineChar) {
        // remove matching comment markers - if we're in a comment, don't try to match
        // braces
        if (inComment && (*lineChar=='"')) {
            inComment = NO;
            nestChar--;
            nestLen--;
        }
        // same for strings
        else if (inString && (*lineChar=='\'' && (lineChar==line || *(lineChar-1)!='\\'))) {
            inString = NO;
            nestChar--;
            nestLen--;
        }
        else {
            // remove matching characters
            if (nestLen &&
                ((*lineChar==')' && *nestChar=='(') ||
                 (*lineChar=='}' && *nestChar=='{') ||
                 (*lineChar==']' && *nestChar=='[')))
            {
                nestLen--;
                nestChar--;
            }
            
            // find beginnings of parens, braces, blocks, strings, etc and add them
            // to the nexting pairs
            if (*lineChar=='(') {
                *++nestChar = '(';
                nestLen++;
            }
            else if (*lineChar=='{') {
                *++nestChar = '{';
                nestLen++;
            }
            else if (*lineChar=='[') {
                *++nestChar = '[';
                nestLen++;
            }
            else if (*lineChar=='"' && !inComment) {
                *++nestChar = '"';
                inComment = YES;
                nestLen++;
            }
            else if (*lineChar=='\'' && !inString) {
                *++nestChar = '\'';
                inString = YES;
                nestLen++;
            }
        }
        
        lineChar++;
    }
    
    
    
    if (!nestLen) {
        free(nestings);
        return NULL;
    }
    else {
        return nestings;
    }
}



int run_readline_interpreter(FSInterpreter* interpreter) {
    BOOL dummy;
    FSFile* standardOut = [((FSSystem*)[interpreter objectForIdentifier:@"sys" found:&dummy]) out];
    
    EditLine *el;
    
    
    // swap in our interrupt handler
    /*signalHandler handlerptr = signal(SIGINT, catchInterrupt);
    if (handlerptr == SIG_ERR) {
        [standardOut println:@"Can't assign interrupt signal handler"];
        return -1;
    }
    */
    
    // figure out whether we should use color
    NSString* terminal = [[[NSProcessInfo processInfo] environment] objectForKey:@"TERM"];
    BOOL useColor = ([terminal isEqualToString:@"xterm-color"] || [terminal isEqualToString:@"ansi"]);
    
    
    /* This holds the info for our history */
    History *myhistory;
    
    /* Temp variables */
    int count;
    const char *line;
    BOOL keepreading = YES;
    HistEvent ev;
    
    /* Initialize the EditLine state to use our prompt function and
        emacs style editing. */
    
    el = el_init("", stdin, stdout, stderr);
    el_set(el, EL_PROMPT, (useColor ? &regularPromptColor : &regularPrompt));
    el_set(el, EL_EDITOR, "emacs");
    
    /* Initialize the history */
    myhistory = history_init();
    if (myhistory == 0) {
        fprintf(stderr, "history could not be initialized\n");
        return 1;
    }
    
    /* Set the size of the history */
    history(myhistory, &ev, H_SETSIZE, 800);
    
    /* This sets up the call back functions for history functionality */
    el_set(el, EL_HIST, history, myhistory);
    
        
    
    NSString* currentCommand = [[NSString alloc] init];
    
    while (keepreading) {
        /* count is the number of characters read.
        line is a const char* of our command line with the tailing \n */
        line = el_gets(el, &count);
        
        // line will be null if the user closes stdin by typing Control-D
        if (line==NULL) {
            printf("\n");
            keepreading = NO;
        }
        else if (count > 0) {
            /* In order to use our history we have to explicitly add commands to the history */
            history(myhistory, &ev, H_ENTER, line);
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            
            NSString* lineString = [NSString stringWithCString:line encoding:NSASCIIStringEncoding];
            
            // add this line to the current command
            NSString* newCommand = [[NSString alloc] initWithFormat:@"%@%@",currentCommand,lineString];
            [currentCommand release];
            currentCommand = newCommand;
            
            char* nestings = findNestings(currentNestings,line);
            
            currentNestings = nestings;
            
            if (nestings) {
                // update the prompt
                currentNestingsLength = strlen(nestings);
                el_set(el, EL_PROMPT, (useColor ? &nestedPromptColor : &nestedPrompt));
            }
            else {
                el_set(el, EL_PROMPT, (useColor ? &regularPromptColor : &regularPrompt));
                currentNestingsLength = 0;
                
                
                // check for special commands
                if ([currentCommand length] > 0) {
                    FSInterpreterResult* execResult = [interpreter execute:currentCommand];
                    FSVoid* voidResult = [FSVoid fsVoid];
                    
                    if ([execResult isOK]) {
                        @try {
                            id resultValue = [execResult result];  // run the compiled code
                            
                            if (resultValue != voidResult)
                                [standardOut println:resultValue];
                        }
                        @catch (NSException* error) {
                            // catch and print any errors
                            [standardOut println:[error reason]];
                        }
                    }
                    else {
                        NSRange errorLocation = [execResult errorRange];
                        [standardOut printf:@"% *s\n" withValues:[NSArray arrayWithObjects:[NSNumber numberWithInt:(errorLocation.location+defaultPromptLength+1)], @"^", nil]];
                        [standardOut println:[execResult errorMessage]];
                    }
                }
                
                // release this command
                [currentCommand release];
                currentCommand = [[NSString alloc] init];
            }
            [pool release];
        }
    }
    
    
    /* Clean up our memory */
    history_end(myhistory);
    el_end(el);
    
    return 0;
}
