#import <Foundation/Foundation.h>

@interface NSObject (OTSharedInstance)

+ (id)sharedInstance;

+ (void)freeSharedInstance;

@end