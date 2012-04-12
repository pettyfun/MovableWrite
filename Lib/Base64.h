//
//  Base64.h
//  http://www.cocoadev.com/index.pl?BaseSixtyFour
//  cyrus.najmabadi@gmail.com
//
//

#import <Foundation/Foundation.h>

#define ArrayLength(x) (sizeof(x)/sizeof(*(x)))


@interface Base64 : NSObject {

}
+ (NSString*) encode:(NSData*) rawBytes;
+ (NSData*) decode:(NSString*) string;

@end
