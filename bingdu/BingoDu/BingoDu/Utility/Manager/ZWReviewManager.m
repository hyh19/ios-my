#import "ZWReviewManager.h"
#import "UIAlertView+Blocks.h"
#import "NSDate+Utilities.h"

@implementation ZWReviewManager

+ (void)showReviewAlert {
    
    // 是否不再提醒
    BOOL review = [[NSUserDefaults standardUserDefaults] boolForKey:kNoReviewAlertAgain];
    
    if (!review) {
        
        // 阅读新闻超过20篇，提醒用户给好评
        if ([ZWUtility readNewsNum] >= kNumberReviewThreshold) {
            
            // 最近一次提醒给好评时间
            NSDate *latest = [[NSUserDefaults standardUserDefaults] objectForKey:kLatestReviewTime];
            NSDate *now = [NSDate date];
            
            // 从没有提醒过则提醒用户或者七天后再一次提醒
            if (!latest ||
                [now daysAfterDate:latest]>=7) {
                
                [UIAlertView showWithTitle:nil
                                   message:@"并读推荐的生活资讯对您有帮助吗？ 假如您喜欢并读，不妨给我们一个好评鼓励一下吧！"
                         cancelButtonTitle:@"不再提醒"
                         otherButtonTitles:@[@"立即好评", @"下次再说"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      
                                      // 保存本次提醒时间
                                      [[NSUserDefaults standardUserDefaults] setObject:now forKey:kLatestReviewTime];
                                      
                                      // 跳转到App Store评论界面
                                      if (1 == buttonIndex) {
                                          [ZWUtility openAppStore];
                                      }
                                      
                                      // 不再提醒
                                      if (alertView.cancelButtonIndex == buttonIndex) {
                                          [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNoReviewAlertAgain];
                                      }
                                  }];
            }
        }
    }
}

@end
