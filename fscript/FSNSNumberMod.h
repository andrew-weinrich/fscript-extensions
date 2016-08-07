//
//  FSNSNumberMod.h
//  FSInterpreter
//
//  Created by Andrew Weinrich on 11/18/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! 
@category NSNumber(FSNSNumberMod)
@abstract Extension of FSNSNumber to support the modulo operator
@discussion This category adds a single method, <span class="method">operator_percent:</span>, that F-Script use the familiar C modulo operator, <span class="literal">%</span>.
*/
@interface NSNumber (FSNSNumberMod) 

/*!
@method operator_percent:
@discussion This method implements modulo division between two numbers using C's <code>%</code> operator. The two operands are converted to integers using the <span class="method">intValue</span> message before dividing. Example: <code>result := 12 % 5. out println:result</code> will print <span class="literal">3</span>.
*/
- (NSNumber*) operator_percent:(NSNumber*)operand;

//
//- (NSString*) operator_plus_plus:(NSString*)operand;


@end
