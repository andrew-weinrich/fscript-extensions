//
//  StringSprintf.m
//  fscript
//
//  Created by Andrew Weinrich on 12/29/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import "StringSprintf.h"
#import <FScript/FScript.h>

@implementation NSString (StringSprintf)



/*
 * These macros add a single character / null-terminated string to a buffer,
 * resizing if necessary
 * The argument BUFFER is assumed to have a corresponding BUFFERLen variable that
 * stores its length, e.g. mainBuffer and mainBufferLen
 * bufferPos will always be pointing at the trailing null character, i.e. the position
 * where the next character will be added
 */

#define ADD_CHAR(CHAR,BUFFER) \
{\
    if (BUFFER ##Pos == BUFFER ## Length-1) {\
        BUFFER = realloc(BUFFER,BUFFER ## Length*2+1);\
        BUFFER ## Length *= 2;\
    }\
    BUFFER[BUFFER ## Pos++] = CHAR;\
    BUFFER[BUFFER ## Pos] = 0;\
}\

// increase a buffer by at least a certain amount
// postcondition: buffer will be able to hold at least LENGTH many
// additional characters
#define INCREASE_BUFFER(BUFFER,LENGTH) \
{\
    if ((BUFFER ## Length + LENGTH) > BUFFER ## Length-1) {\
        BUFFER ## Length = (BUFFER ## Length+LENGTH)*2;\
        BUFFER = realloc(BUFFER,BUFFER ## Length+1);\
    }\
}\


// add a character, don't check allocation
#define ADD_CHAR_NOCHECK(CHAR,BUFFER) BUFFER[BUFFER ## Pos++] = CHAR;BUFFER[BUFFER ## Pos] = 0;

// copy an entire string into a buffer
#define ADD_STRING(STRING,LENGTH,BUFFER) \
{\
    if (BUFFER ## Pos + LENGTH > BUFFER ## Length-1) {\
        BUFFER ## Length = (BUFFER ## Length+LENGTH)*2;\
        BUFFER = realloc(BUFFER,BUFFER ## Length+1);\
    }\
    memcpy(BUFFER+BUFFER ## Pos,STRING,LENGTH+1);\
    BUFFER ## Pos+= LENGTH;\
}\

// pads a buffer with a certain number of additional characters
#define PAD_BUFFER(BUFFER,PAD_CHAR,COUNT) \
{\
    if ((BUFFER ## Length + COUNT) > BUFFER ## Length-1) {\
        BUFFER ## Length = (BUFFER ## Length+COUNT)*2;\
        BUFFER = realloc(BUFFER,BUFFER ## Length+1);\
    }\
    for (int i = 0; i < COUNT; i++)\
        BUFFER[BUFFER ## Pos++] = PAD_CHAR;\
    BUFFER[BUFFER ## Pos] = 0;\
}\



// initial buffer capacities
#define INITIAL_STRING_CAPACITY 80
#define INT_BUFFER_LENGTH 25

// digits for printing integers / floats
char lowercaseDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
char uppercaseDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };


- (NSString*) sprintf:(NSArray*)values {
    const char* format = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    // the main buffer into which we will write the formatted string
    // grows automatically with the ADD_STRING and ADD_CHAR macros
    int mainBufferLength = INITIAL_STRING_CAPACITY;
    char* mainBuffer = (char*)malloc((mainBufferLength+1) * sizeof(char));
    int mainBufferPos = 0;
    
    // index of the value we are currently using
    int valuesIndex = 0;
    
    for (; *format != 0; ++format) {
		if (*format == '%') {
			BOOL overrideWidth = NO;
			int requestedWidth = 0;
			
			BOOL overridePrecision = NO;
			int requestedPrecision = 0;
            int defaultIntPrecision = 1;
            int defaultFloatPrecision = 6;
			
            int precision = 0;
			int width = 0;
            
            BOOL convertExp = NO;
            BOOL convertFloat = NO;
            BOOL printExp = NO;
            BOOL printFloat = NO;
            char expCharacter = 'e';
            BOOL chooseShorterFloat = NO;
            
            BOOL insertString = NO;
            BOOL insertChar = NO;
            NSString* valueString;
            
            // int conversion flags
            BOOL convertInt = NO;
            BOOL intConversionBase = 10;
            char* digits = lowercaseDigits;
            BOOL printPointer = NO;
            
            // number-formatting flags
            BOOL printPlusSign = NO;
            BOOL printPlusSpace = NO;
            BOOL printPrefix = NO;
            char* numberPrefix;
            int numberPrefixLen = 0;
            
            // padding flags
            BOOL padLeft = YES;
            BOOL padRight = NO;
            BOOL padWithZeroes = NO;
            char padChar = ' ';
            
            // buffers for number->string conversions
            // these are stored external to the conversion subroutines
            // so that the g/G converter can compare their lengths
            char formatBuffer[20];
            int formatBufferLen = 0;
            char floatBuffer[50];
            int floatBufferLen = 0;
            char expBuffer[50];
            int expBufferLen = 0;
            
			++format;
			if (*format == '\0') break;
			if (*format == '%') {
                ADD_CHAR(*format, mainBuffer);
                continue;
            }
            
            // follow the C standard for flag order
            if (*format == '-') {
                ++format;
                padRight = YES;
                padLeft = NO;
            }
            if (*format == '+') {
                ++format;
                printPlusSign = YES;
            }
            if (*format == ' ') {
                ++format;
                printPlusSpace = YES;
            }
            if (*format == '#') {
                ++format;
                printPrefix = YES;
            }
            
            
            // get format width
            if (*format == '*') {
                // width is specified by an integer in the values list
				overrideWidth = YES;
                requestedWidth = [[values objectAtIndex:(valuesIndex++)] intValue];
                format++;
            }
			while (*format == '0') {
				++format;
                padWithZeroes = YES;
                padChar = '0';
			}
			for ( ; *format >= '0' && *format <= '9'; ++format) {
				overrideWidth = YES;
				requestedWidth *= 10;
				requestedWidth += *format - '0';
			}
            
            
            // get precision
			if (*format == '.') {
				++format;
                overridePrecision = YES;
                for ( ; *format >= '0' && *format <= '9'; ++format) {
                    requestedPrecision *= 10;
                    requestedPrecision += *format - '0';
                }
            }
            
            
            // get reference to the current value object
            if (!([values count] > valuesIndex)) {
                [[NSException exceptionWithName:NSInvalidArgumentException
                                         reason:@"Not enough values supplied to printf/sprintf"
                                       userInfo:nil] raise];
            }
            id currentValue = [values objectAtIndex:(valuesIndex++)];
            
            
            switch (*format) {
                // string/object conversions
                case 'c':
                    insertChar = YES;
                    break;
                case 's':
                    insertString = YES;
                    valueString = currentValue;
                    break;
                case '@':
                    insertString = YES;
                    valueString = currentValue ? [currentValue description] : @""; // we might get nil from the array
                    break;
                
                // floating-point / scientific notation conversions - actual conversion
                // work is done below
                case 'e':
                    convertExp = YES;
                    expCharacter = 'e';
                    printExp = YES;
                    break;
                case 'E':
                    convertExp = YES;
                    expCharacter = 'E';
                    printExp = YES;
                    break;
                case 'f':
                    convertFloat = YES;
                    printFloat = YES;
                    break;
                /*
                case 'g':
                    convertFloat = YES;
                    convertExp = YES;
                    expCharacter = 'e';
                    chooseShorterFloat = YES;
                    break;
                case 'G':
                    convertFloat = YES;
                    convertExp = YES;
                    expCharacter = 'E';
                    chooseShorterFloat = YES;
                    break;
                */
                
                // Integer conversions in different bases
                case 'd':
                case 'i':
                    convertInt = YES;
                    intConversionBase = 10;
                    break;
                case 'o':
                    convertInt = YES;
                    intConversionBase = 8;
                    printPlusSign = NO;
                    printPlusSpace = NO;
                    numberPrefix = "0";
                    numberPrefixLen = 1;
                    break;
                case 'p':
                    printPointer = YES;
                case 'x':
                    convertInt = YES;
                    intConversionBase = 16;
                    printPlusSign = NO;
                    printPlusSpace = NO;
                    numberPrefix = "0x";
                    numberPrefixLen = 2;
                    break;
                case 'P':
                    printPointer = YES;
                case 'X':
                    convertInt = YES;
                    intConversionBase = 16;
                    printPlusSign = NO;
                    printPlusSpace = NO;
                    digits = uppercaseDigits;
                    numberPrefix = "0X";
                    numberPrefixLen = 2;
                    break;
                
                // invalid format
                default:
                    continue;
            }
            
            
            
            // insert a single Unicode character
            if (insertChar) {
                const char *s = [[currentValue unicharToString] cStringUsingEncoding:NSUTF8StringEncoding];
                int sLength = strlen(s);
                ADD_STRING(s,sLength,mainBuffer);
            }
            
            
            // insert a (potentially padded) string
            if (insertString) {
                int stringLength = [valueString length];
                int maxChars;   // maximum number of string chars to print
                int totalWidth; // total width of string
                
                if (!overrideWidth && overridePrecision) {
                    totalWidth = maxChars = requestedPrecision;
                }
                else if (overrideWidth && overridePrecision) {
                    totalWidth = requestedWidth;
                    maxChars = requestedPrecision;
                }
                else if (overrideWidth && !overridePrecision) {
                    totalWidth = maxChars = requestedWidth;
                }
                else { // no override requested
                    totalWidth = maxChars = stringLength;
                }
                
                // cut down the maximum number of characters to at most string length
                if (maxChars > stringLength) 
                    maxChars = stringLength;
                
                int lengthDifference = totalWidth - maxChars;
				
                // pad left if needed
                if (lengthDifference && padLeft) {
					PAD_BUFFER(mainBuffer,padChar,lengthDifference);
                }
                // truncate the string if necessary
                const char *s = [(maxChars != stringLength ? [valueString substringWithRange:NSMakeRange(0,maxChars)] :
                                  valueString)
                         cStringUsingEncoding:NSUTF8StringEncoding];
                int sLength = strlen(s);
                ADD_STRING(s,sLength,mainBuffer);
                
                // pad right if needed
                if (lengthDifference && padRight)
                    PAD_BUFFER(mainBuffer,padChar,lengthDifference);
                
                continue;   // go back to the beginning of the main loop
            }
            
            
            
            
            
            /*
             * This section converts signed/unsigned integers in different bases, then continues the loop
             */
            if (convertInt) {
                int neededPadding = 0;
                NSInteger intValue = printPointer ? (NSInteger)currentValue : [currentValue intValue];
                
				
                // don't print an octal/hex prefix if this number is 0
                if (intValue==0) {
                    printPrefix = NO;
                    numberPrefixLen = 0;
                    numberPrefix = "";
                }
                
                char intBuffer[INT_BUFFER_LENGTH+1];
                intBuffer[INT_BUFFER_LENGTH] = '\0';
                char* s = intBuffer + INT_BUFFER_LENGTH;
                BOOL negative = intValue < 0;
                
				precision = overridePrecision ? requestedPrecision : defaultIntPrecision;
				
                int signPrefixLen = (negative || printPlusSign || printPlusSpace) ? 1 : 0;
                int basePrefixLen = (printPrefix ? numberPrefixLen : 0);
                
                // maximum number of characters required to print this number fully
                int requiredIntChars = ceil(log10((double)intValue)/log10((double)intConversionBase));
                
                int minNumbers = precision > requiredIntChars ? precision : requiredIntChars;
                
                
                // width required to print this number
                int requiredWidth = basePrefixLen + signPrefixLen + minNumbers;
                
                // if we need to pad with zeroes, expand the minimum precision
                if (precision > requiredWidth && padWithZeroes && padLeft) {
                    minNumbers = requiredWidth - (basePrefixLen + signPrefixLen);
                }

				//width = width ? width : requiredWidth;
				if (overrideWidth) {
					width = requestedWidth > requiredWidth ? requestedWidth : requiredWidth;
					padLeft = YES;
				}
				else {
					width = requiredWidth;
				}
				
                
                // count of numbers and total characters printed
                int numbersPrinted = 0;
                int charsPrinted = 0;
                
                // unsigned value of the number
                unsigned long unsignedValue = printPointer ? (unsigned long)currentValue : labs(intValue);
                
                
                // special case for zero
                if (intValue == 0) {
                    *--s = '0';
                    numbersPrinted = 1;
                }
                
                
                // 'print' the numbers into the temp buffer in reverse order
                while (unsignedValue) {
                    *--s = digits[unsignedValue % intConversionBase];
                    unsignedValue /= intConversionBase;
                    numbersPrinted++;
                }
                
                // add extra zeroes as needed
                while (numbersPrinted < minNumbers) {
                    *--s = '0';
                    ++numbersPrinted;
                }
                
                charsPrinted = numbersPrinted;
                
                // add a prefix if desired
                if (printPrefix) {
                    s -= numberPrefixLen;
                    char* tempPtr = s;
                    for (int i=0; i<numberPrefixLen; i++)
                        *(tempPtr++) = numberPrefix[i];
                    charsPrinted += numberPrefixLen;
                }
                
                
                // add minus sign or space if needed
                if (negative) {
                    *--s = '-';
                    charsPrinted++;
                }
                else if (printPlusSign) {
                    *--s = '+';
                    charsPrinted++;
                }
                else if (printPlusSpace) {
                    *--s = ' ';
                    charsPrinted++;
                }
                
                // add left padding if needed
                if (padLeft && (neededPadding = width - charsPrinted))
                    PAD_BUFFER(mainBuffer,' ',neededPadding);
                
                // print the number string
                ADD_STRING(s,INT_BUFFER_LENGTH-(s-intBuffer),mainBuffer);
                
                // add right padding if needed
                if (padRight && (neededPadding = width - charsPrinted))
                    PAD_BUFFER(mainBuffer,' ',neededPadding);
                
                // continue on with the main loop
                continue;
            }
            
            
            // convert number to floating point/exp 
            // create a temporary format buffer, then let the system sprintf do the hard work
            double doubleValue;
            if (convertFloat || convertExp) {
				width = overrideWidth ? requestedWidth : width;
                doubleValue = [currentValue doubleValue];
                formatBuffer[formatBufferLen++] = '%';
                
                // add flags if necessary
                if (padRight)       formatBuffer[formatBufferLen++] = '-';
                if (printPlusSign)  formatBuffer[formatBufferLen++] = '+';
                if (printPlusSpace) formatBuffer[formatBufferLen++] = ' ';
                if (printPrefix)    formatBuffer[formatBufferLen++] = '#';
                if (padWithZeroes)  formatBuffer[formatBufferLen++] = '0';
                
                precision = overridePrecision ? requestedPrecision : defaultFloatPrecision;
                if (overrideWidth)
                    formatBufferLen += sprintf(formatBuffer+formatBufferLen,"%d.%df", width, precision) - 1;
                else
                    formatBufferLen += sprintf(formatBuffer+formatBufferLen,".%df", precision) - 1;
            }
            if (convertFloat) {
                floatBufferLen = sprintf(floatBuffer, formatBuffer, doubleValue);
            }
            if (convertExp) {
                formatBuffer[formatBufferLen] = expCharacter; // set the proper e/E character at the end
                expBufferLen = sprintf(expBuffer, formatBuffer, doubleValue);
            }
            
            
            // if we had the g/G options, check to see which of plain float or
            // scientific notation is shorter
            if (chooseShorterFloat) {
                printFloat = floatBufferLen < expBufferLen;
                printExp = expBufferLen < floatBufferLen;
            }
            
            // print floating decimal/scientific notation as appropriate
            if (printFloat) {
                ADD_STRING(floatBuffer,floatBufferLen,mainBuffer);
            }
            else if (printExp) {
                ADD_STRING(expBuffer,expBufferLen,mainBuffer);
            }
		}
		else {
			ADD_CHAR(*format, mainBuffer);
		}
	}
    
    // make sure there aren't leftover values in the array
    if (valuesIndex != [values count]) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"Too many values supplied to printf/sprintf"
                               userInfo:nil] raise];
    }
    
    
    NSString* result = [NSString stringWithCString:mainBuffer encoding:NSUTF8StringEncoding];
    free(mainBuffer);
    return result;
}

@end
