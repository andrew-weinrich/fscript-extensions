//
//  FSFileStdin.m
//  FSInterpreter
//
//  Created by Andrew Weinrich on 12/6/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import "FSFileStdin.h"


// singleton instance
FSFileStdin* FSstdin;


@implementation FSFileStdin



// factory method that returns a singleton instance
+ (id) getStdin {
    if (!FSstdin)
        FSstdin = [[FSFileStdin alloc] init];
    
    return FSstdin;
}


- (id) init {
    [self initWithFileHandle:[NSFileHandle fileHandleWithStandardInput] atLocation:@""];
    buffer = @"";
    
    return self;
}


// Adapted from Apple's documentation, "Piping Data Between Tasks", 2006-04-04
- (NSString*)readlnWithSeparator:(NSString*)separator {
    NSData *inData = nil;
    NSString* returnString = nil;
    
    /*
        We have four cases to consider:
            - We've read exactly up to the end of the separator
                (i.e. the separator is "\n" and "\n" is the last available character)
                In this case, set buffer to the empty string and return everything
                    up to the beginning of the separator
            - There's nothing left at all: the file is closed
                if there's anything left in the buffer, return it, otherwise return
                nil
            - We've read all the available data, but haven't seen the separator
                Add the data to the buffer, and repeat
            - We've read past the separator
                Put the excess data into the buffer, and return the portion that
                came before the separator
     */
    while (!returnString && (inData = [fileHandle availableData]) && [inData length]) {
        NSString* temp = [[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding];
        NSString* dataString = [buffer length] ? [buffer stringByAppendingString:temp] : temp;
        
        NSRange separatorRange = [dataString rangeOfString:separator];
        int endOfSeparator = separatorRange.location+separatorRange.length;
        int stringLength = [dataString length];
        
        if (endOfSeparator==stringLength) {
            buffer = @"";
            returnString = [dataString substringToIndex:separatorRange.location];;
        }
        else if (endOfSeparator<=stringLength) {
            buffer = [dataString substringFromIndex:endOfSeparator];
            returnString = [dataString substringToIndex:separatorRange.location];
        }
        else if (separatorRange.location==NSNotFound){
            buffer = [buffer stringByAppendingString:dataString];
            returnString = nil;
        }
    }
    
    // if there's nothing to read and nothing in the buffer, return nil
    int bufferLength = [buffer length];
    if (!returnString && bufferLength)
        return buffer;
    else if (![returnString length] && !bufferLength)
        return nil;
    else
        return returnString;
}



@end
