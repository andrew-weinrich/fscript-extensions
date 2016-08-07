//
//  help.h
//  fscript
//
//  Created by Andrew Weinrich on 8/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FSToolHelp : NSObject {

}



- (NSString*) description;

- (NSString*) import;

- (NSString*) version;

- (NSString*) quit;

- (NSString*) frameworks;

@end
