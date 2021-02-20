//
//  FBContactsModel.m
//  LiveShow
//
//  Created by lgh on 16/3/2.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBContactsModel.h"

@implementation FBContactsModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"user" : @"FBUserInfoModel"
             };
}

@end
