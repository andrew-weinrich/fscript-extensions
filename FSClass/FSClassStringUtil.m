//
//  FSClassStringUtil.m
//  FSClass
//
//  Created by Andrew Weinrich on 11/25/06.
//

#import "FSClassStringUtil.h"


@implementation NSString (FSClassStringUtil)

- (NSString*) lowercaseFirst {
    int length = [self length];
    unichar* buffer = malloc(sizeof(unichar)*length);
    
    [self getCharacters:buffer];
    buffer[0] = (unichar)tolower(buffer[0]);
    NSString* uppercasedString = [NSString stringWithCharacters:buffer length:length];
    free(buffer);
    return uppercasedString;
}

- (NSString*) uppercaseFirst {
    int length = [self length];
    unichar* buffer = malloc(sizeof(unichar)*length);
    
    [self getCharacters:buffer];
    buffer[0] = (unichar)toupper(buffer[0]);
    NSString* uppercasedString = [NSString stringWithCharacters:buffer length:length];
    free(buffer);
    return uppercasedString;
}


// returns a C-string copy of the string in ASCII encoding. Caller is responsible for freeing
- (char*) copyOfAsciiContents {
    unsigned int stringLength = [self lengthOfBytesUsingEncoding:NSASCIIStringEncoding] + 1;
    char* cString = malloc(sizeof(char) * stringLength);
    [self getCString:cString maxLength:stringLength encoding:NSASCIIStringEncoding];
    return cString;
}

@end
