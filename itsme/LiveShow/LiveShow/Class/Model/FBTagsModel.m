//
//  FBTagsModel.m
//  LiveShow
//
//  Created by tak on 16/8/13.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBTagsModel.h"
#import "FBRecordModel.h"
#import "FBLiveInfoModel.h"
#import "UIScreen+Devices.h"

@implementation FBTagsModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"record":[FBRecordModel class],
             @"lives" :[FBLiveInfoModel class]
             };
}


- (CGFloat)cellHeight {
    if (_num.intValue == 0) {
        return 0;
    }
    CGFloat height = ([[UIScreen mainScreen] isFourPhone] || [[UIScreen mainScreen] isiPhoneFourSOrBelow])? 150 : 170;
    return _num.intValue >= 3 ? height : 50;
}
@end
