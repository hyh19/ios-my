#import "FBTipAndGuideManager.h"

@interface FBTipAndGuideManager ()

/** 应用生命周期内，记录各种提示的次数 */
@property (nonatomic, strong) NSMutableDictionary *memo;

@end

@implementation FBTipAndGuideManager

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    
    static FBTipAndGuideManager *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[FBTipAndGuideManager alloc] init];
        
    });
    
    return sharedInstance;
}

- (NSMutableDictionary *)memo {
    if (!_memo) {
        _memo = [NSMutableDictionary dictionary];
    }
    return _memo;
}

- (void)addCountInLiftCycleWithType:(FBTipAndGuideType)type {
    NSString *memoKey = [self keyForLiftCycleWityType:type];
    if ([memoKey isValid]) {
        NSNumber *num = [self.memo objectForKey:memoKey];
        if (num) {
            num = @(num.integerValue+1);
        } else {
            num = @(1);
        }
        [self.memo setObject:num forKey:memoKey];
    }
}

- (NSUInteger)countInLiftCycleWithType:(FBTipAndGuideType)type {
    NSString *memoKey = [self keyForLiftCycleWityType:type];
    if ([memoKey isValid]) {
        NSNumber *num = [self.memo objectForKey:memoKey];
        if (num) {
            return num.integerValue;
        } else {
            return 0;
        }
    }
    // 不存在的事件，返回一个很大的数，表示不提示
    return NSUIntegerMax;
}

+ (void)addCountInUserDefaultsWithType:(FBTipAndGuideType)type {
    NSString *keyForUserDefaults = [FBTipAndGuideManager keyForUserDefaultsWityType:type];
    if ([keyForUserDefaults isValid]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *num = [defaults valueForKey:keyForUserDefaults];
        if (num) {
            num = @(num.integerValue+1);
        } else {
            num = @(1);
        }
        [defaults setValue:num forKey:keyForUserDefaults];
        [defaults synchronize];
    }
}

+ (NSUInteger)countInUserDefaultsWithType:(FBTipAndGuideType)type {
    NSString *keyForUserDefaults = [FBTipAndGuideManager keyForUserDefaultsWityType:type];
    if ([keyForUserDefaults isValid]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *num = [defaults valueForKey:keyForUserDefaults];
        if (num) {
            return num.integerValue;
        } else {
            return 0;
        }
    }
    // 不存在的事件，返回一个很大的数，表示不提示
    return NSUIntegerMax;
}

#pragma mark - Help -
+ (NSString *)stringValueForType:(FBTipAndGuideType)type {
    switch (type) {
        case kTipFollowBroadcaster:
            return @"kTipFollowBroadcaster";
            break;
        case kTipSetAvatar:
            return @"kTipSetAvatar";
            break;
        case kTipShareLive:
            return @"kTipShareLive";
            break;
        case kTipSetCamera:
            return @"kTipSetCamera";
            break;
        case kTipThankUsers:
            return @"kTipThankUsers";
            break;
        case kTipSendDanmu:
            return @"kTipSendDanmu";
            break;
        case kTipTalkToBroadcaster:
            return @"kTipTalkToBroadcaster";
            break;
        case kTipSendGift:
            return @"kTipSendGift";
            break;
        case kTipRemindFollowMe:
            return @"kTipRemindFollowMe";
            break;
        case kTipBroadcast:
            return @"kTipBroadcast";
            break;
        case kGuideSwipeLive:
            return @"kGuideSwipeLive";
            break;
        case kGuideSendGift:
            return @"kGuideSendGift";
            break;
        case kGuideClickDiamond:
            return @"kGuideClickDiamond";
            break;
        case kGuideChangeAvatar:
            return @"kGuideChangeAvatar";
            break;
        default:
            break;
    }
    return nil;
}

+ (NSString *)keyForUserDefaultsWityType:(FBTipAndGuideType)type {
    NSString *typeString = [FBTipAndGuideManager stringValueForType:type];
    if ([typeString isValid]) {
        return [NSString stringWithFormat:@"%@_userId_%@", typeString, [[FBLoginInfoModel sharedInstance] userID]];
    }
    return nil;
}

- (NSString *)keyForLiftCycleWityType:(FBTipAndGuideType)type {
    NSString *typeString = [FBTipAndGuideManager stringValueForType:type];
    if ([typeString isValid]) {
        return typeString;
    }
    return nil;
}

@end
