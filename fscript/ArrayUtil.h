//
//  StringUtil.h
//  FSInterpreter
//
//  Created by Andrew Weinrich on 11/25/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import <Foundation/NSArray.h>
#import <FScript/Block_fscript.h>

/*! 
@category NSArray(ArrayUtil)
*/
@interface NSArray(ArrayUtil)

/*!
@method join:
A much shorter name for <span class="method">componentsJoinedByString:</span>.
*/
- (NSString*) join:(NSString*)str;

@end
