//
//  FSClassStringUtil.h
//  FSClass
//
//  Created by Andrew Weinrich on 11/25/06.
//

#import <Cocoa/Cocoa.h>

/*
 *  This category adds two methods that are useful for converting property
 *  names to setProperty: type method names, and vice versa. They act like
 *  the lcfirst and ucfirst operators in Perl.
 */

@interface NSString (FSClassStringUtil)

- (NSString*) uppercaseFirst;
- (NSString*) lowercaseFirst;


- (char*) copyOfAsciiContents;


@end
