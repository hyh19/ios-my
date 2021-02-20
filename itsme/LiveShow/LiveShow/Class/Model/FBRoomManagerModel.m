//
//  FBRoomManagerModel.m
//  LiveShow
//
//  Created by chenfanshun on 22/06/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBRoomManagerModel.h"

@implementation FBRoomManagerModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"live_id" : @"lid",
             @"event"   : @"event",
             @"uid"     : @"uid"};
}

@end
