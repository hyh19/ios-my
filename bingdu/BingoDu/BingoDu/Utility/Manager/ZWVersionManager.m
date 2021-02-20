#import "ZWVersionManager.h"
#import "ZWUpdateChannel.h"
#import "ZWHTTPRequestFactory.h"
#import "ZWGetRequestFactory.h"
#import "ZWPublicNetworkManager.h"
#import "UIAlertView+Blocks.h"

@implementation ZWVersionManager

+ (void)checkVersionWithType:(ZWVersionCheckType)type
                 finishBlock:(void (^)(BOOL hasNewVersion, id versionData))finish {
    
    ZWVersionManager *manager = [[ZWVersionManager alloc] init];
    
    [[ZWPublicNetworkManager sharedInstance] checkVersionWithSuccessBlock:^(id result) {
        
        NSString *latestVersion = [result objectForKey:@"versionCode"];
        // 保存最新版本到本地配置文件
        [[NSUserDefaults standardUserDefaults] setObject:latestVersion forKey:kLatestVersion];
        
        NSString *title = [NSString stringWithFormat:@"发现新版本(V%@)", latestVersion];
        NSString *message = [result objectForKey:@"description"];
        ZWVersionReminderType reminderType = (ZWVersionReminderType)[[result objectForKey:@"isForceUpdate"] integerValue];
        
        if (type != kVersionCheckTypeIgnore) {
            
            if ([ZWVersionManager hasNewVersion]) {
                
                if (kVersionCheckTypeMannual == type) {
                    [manager showAlertWithTitle:title message:message reminderType:reminderType];
                } else {
                    if (kVersionReminderTypeNoAlertAndNonForced != reminderType) {
                        [manager showAlertWithTitle:title message:message reminderType:reminderType];
                    }
                }
            } else {
                if (type == kVersionCheckTypeMannual) {
                    occasionalHint(@"已是最新版本");
                }
            }
        }
        
        finish([ZWVersionManager hasNewVersion], result);
        
    } failureBlock:^(NSString *errorString) {
        finish(NO, nil);
    }];
}

+ (BOOL)hasNewVersion {
    // 最新版本
    NSString *latestVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kLatestVersion];
    if ([latestVersion isValid]) {
        NSString *currentVersion = [ZWUtility versionCode];
        return [currentVersion compare:latestVersion options:NSNumericSearch] == NSOrderedAscending;
    }
    return NO;
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
              reminderType:(ZWVersionReminderType)type {
    
    [UIAlertView showWithTitle:title
                       message:message
             cancelButtonTitle:@"暂不"
             otherButtonTitles:@[@"立即更新"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (alertView.cancelButtonIndex == buttonIndex) {
                              // 如果是强制更新，用户点击不更新则直接退出程序
                              if (kVersionReminderTypeAlertAndForced == type) {
                                  exit(0);
                              }
                          } else {
                              [ZWUtility openAppStore];
                          }
                      }];
}

@end
