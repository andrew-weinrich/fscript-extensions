//
//  StringNumberConversion.h
//  fscript
//
//  Created by Andrew Weinrich on 12/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (StringNumberConversion)



/*
 *
 *  Numeric autoconversion operators
 *
 */
- (NSNumber*) operator_plus:(id)operand;
- (NSNumber*) operator_hyphen:(id)operand;
- (NSNumber*) operator_asterisk:(id)operand;
- (NSNumber*) operator_slash:(id)operand;
- (NSNumber*) operator_mod:(id)operand;





@end
