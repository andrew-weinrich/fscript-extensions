//
//  FileTest.m
//  fscript
//
//  Created by Andrew Weinrich on 1/12/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import "FileTest.h"
#import "Functions.h"
#include <unistd.h>
#include <sys/unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
//#include <sys/acl.h>

int access(const char* path, int mode);
//int getuid();
//int getgid();


@implementation NSFileManager(FileTest)


- (FSBoolean*) test_d:(NSString*)file {
    BOOL isDirectory = NO;
    BOOL exists = [self fileExistsAtPath:file isDirectory:&isDirectory];
    
    return [FSBoolean booleanWithBool:(exists && isDirectory)];
}

- (FSBoolean*) test_f:(NSString*)file {
    BOOL isDirectory = NO;
    BOOL exists = [self fileExistsAtPath:file isDirectory:&isDirectory];
    
    return [FSBoolean booleanWithBool:(exists && !isDirectory)];
}

- (FSBoolean*) test_e:(NSString*)file {
    return [FSBoolean booleanWithBool:(access([file cStringUsingEncoding:NSUTF8StringEncoding], F_OK)==0)];
}


- (NSDate*) test_m:(NSString*)file {
    return getFileModTime(file);
}

- (NSNumber*) test_s:(NSString*)file {
    return getFileSize(file);
}

- (FSBoolean*) test_z:(NSString*)file {
    unsigned long long size = [getFileSize(file) unsignedLongLongValue];
    return [FSBoolean booleanWithBool:(size>0)];
}


/*
 *  Ownership/readability/execution tests
 *
 *  TODO: Update accessibility methods to also check ACLs
 */
- (FSBoolean*) test_o:(NSString*)file {
    struct stat fStat;
    int success = stat([file cStringUsingEncoding:NSUTF8StringEncoding], &fStat);
    
    return [FSBoolean booleanWithBool:(!success && getuid()==fStat.st_uid)];
}


- (FSBoolean*) test_g:(NSString*)file {
    struct stat fStat;
    int success = stat([file cStringUsingEncoding:NSUTF8StringEncoding], &fStat);
    
    return [FSBoolean booleanWithBool:(!success && getgid()==fStat.st_gid)];
}


- (FSBoolean*) test_r:(NSString*)file {
    return [FSBoolean booleanWithBool:(access([file cStringUsingEncoding:NSUTF8StringEncoding], R_OK)==0)];
}


- (FSBoolean*) test_w:(NSString*)file {
    return [FSBoolean booleanWithBool:(access([file cStringUsingEncoding:NSUTF8StringEncoding], W_OK)==0)];
}


- (FSBoolean*) test_x:(NSString*)file {
    return [FSBoolean booleanWithBool:(access([file cStringUsingEncoding:NSUTF8StringEncoding], X_OK)==0)];
}





@end
