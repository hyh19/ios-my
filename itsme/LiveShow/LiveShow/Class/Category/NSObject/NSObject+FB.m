#import "NSObject+FB.h"

@implementation NSObject (FB)

- (void)displayNotificationWithMessage:(NSString *)message
                           forDuration:(NSTimeInterval)duration {
    [self displayNotificationWithMessage:message forDuration:duration backgroundColor:COLOR_NOTIFICATION_DEFAULT];
}

- (void)displayNotificationWithMessage:(NSString *)message
                           forDuration:(NSTimeInterval)duration
                       backgroundColor:(UIColor *)color {
    CWStatusBarNotification *notification = [[CWStatusBarNotification alloc] init];
    notification.notificationLabelBackgroundColor = color;
    notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    notification.notificationStyle = CWNotificationStyleStatusBarNotification;
    notification.notificationLabelFont = FONT_SIZE_14;
    notification.notificationLabelTextColor = [UIColor whiteColor];
    [notification displayNotificationWithMessage:message forDuration:duration];
}

@end
