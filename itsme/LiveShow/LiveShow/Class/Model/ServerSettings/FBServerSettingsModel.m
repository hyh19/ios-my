//
//  FBServerSettingsModel.m
//  LiveShow
//
//  Created by chenfanshun on 16/11/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBServerSettingsModel.h"

@implementation FBRecordInterruptingModel

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"interruptingTime"            : @"interruptingTime",
             @"ID"  : @"ID"
             };
}

@end


@implementation FBDistanceOfAnchorsModel : NSObject

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"distanceValue"            : @"value",
             @"ID"  : @"ID"
             };
}

@end

@implementation FBPresetDialogModel

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"country"            : @"country",
             @"identityCategory"   : @"identityCategory",
             @"dialog"             : @"dialog",
             @"ID"  : @"ID",
             };
}

@end


@implementation FBServerSettingManager

-(NSMutableArray*)arrayPresetDialog
{
    if(nil == _arrayPresetDialog) {
        _arrayPresetDialog = [[NSMutableArray alloc] init];
    }
    return _arrayPresetDialog;
}

/**
 * 附近多少km才算附近
 */
- (NSInteger)nearbyDistance
{
    NSInteger distance = [self.distanceOfAnchors.distanceValue integerValue];
    if(0 == distance) { //服务器拉不到则默认为150km
        distance = 150;
    }
    return distance;
}

/**
 * 回放弹窗时间(单位s)
 */
- (NSInteger)replayInterrupting
{
    NSInteger tick = [self.recrodInterrupting.interruptingTime integerValue];
    if(0 == tick) { //服务器拉不到则默认为60s
        tick = 60;
    }
    return tick;
}

@end
