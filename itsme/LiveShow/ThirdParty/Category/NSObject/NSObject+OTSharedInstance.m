#import "NSObject+OTSharedInstance.h"
#import <objc/runtime.h>

@implementation NSObject (OTSharedInstance)

+ (id)sharedInstance
{
    Class selfClass = [self class];
    id instance = objc_getAssociatedObject(selfClass, @"kOTSharedInstance");
    if (!instance)
    {
        instance = [[selfClass alloc] init];
        objc_setAssociatedObject(selfClass, @"kOTSharedInstance", instance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return instance;
}

+ (void)freeSharedInstance
{
    Class selfClass = [self class];
    objc_setAssociatedObject(selfClass, @"kOTSharedInstance", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
