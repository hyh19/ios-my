#import "ZWActivityModel.h"

@implementation ZWActivityModel

- (instancetype)initWithActivityID:(long)activityID
                             title:(NSString *)title
                          subtitle:(NSString *)subtitle
                               url:(NSString *)url {
    if (self = [super init]) {
        self.activityID  = activityID;
        self.title       = title;
        self.subtitle    = subtitle;
        self.url         = url;
    }
    return self;
}

@end
