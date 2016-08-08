//
//  FileTest.h
//  fscript
//
//  Created by Andrew Weinrich on 1/12/07.
//

#import <Foundation/Foundation.h>
#import <FScript/FSBoolean.h>

/*! 
@category NSFileManager(FileTest)
@discussion The FileTest category adds short methods that mimic the Unix shell file test operators like <code>-x</code> and <code>-d</code>. These methods are implemented with the default file manager, which is available as <span class="literal">filem</span>.

The access tests (<span class="method">test_r:</span>, <span class="method">test_w:</span>, and <span class="method">test_x:</span>) use only standard Unix user and group ids. Access control lists are not considered.
*/
@interface NSFileManager(FileTest)


/*
 *  Existence checks
 */
/*!
@method test_e:
Returns true if the file path exists.
*/
- (FSBoolean*) test_e:(NSString*)path;

/*!
@method test_d:
Returns true if the path exists and is a directory.
*/
- (FSBoolean*) test_d:(NSString*)path;

/*!
@method test_f:
Returns true if the path exists and is a file.
*/
- (FSBoolean*) test_f:(NSString*)path;



/*
 *  Size/data checks
 */
/*!
@method test_m:
Returns the modification date of the file, if it exists.
*/
- (NSDate*) test_m:(NSString*)path;

/*!
@method test_s:
Returns the size in bytes of the file, if its exists.
*/
- (NSNumber*) test_s:(NSString*)path;

/*!
@method test_z:
Returns true if the file exists and has non-zero size.
*/
- (FSBoolean*) test_z:(NSString*)path;



/*
 *  Ownership checks
 */
/*!
@method test_o:
Returns true if the file exists and owned by the current user.
*/
- (FSBoolean*) test_o:(NSString*)path;

/*!
@method test_g:
Returns true if the file exists and owned by the current group.
*/
- (FSBoolean*) test_g:(NSString*)path;



    
/*
 *  Access checks
 */
/*!
@method test_r:
Returns true if the file exists and is readable by the current user.
*/
- (FSBoolean*) test_r:(NSString*)path;

/*!
@method test_w:
Returns true if the file exists and is writeable by the current user.
*/
- (FSBoolean*) test_w:(NSString*)path;

/*!
@method test_x:
Returns true if the file exists and is executable by the current user.
*/
- (FSBoolean*) test_x:(NSString*)path;



@end
