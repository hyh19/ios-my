//
//  FBBindListModel.m
//  LiveShow
//
//  Created by tak on 16/9/5.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBBindListModel.h"

@implementation FBBindListModel

- (BOOL)isBindTwitter {
    return [_platform isEqualToString:kPlatformTwitter];
}

- (BOOL)isBindFacebook {
    return [_platform isEqualToString:kPlatformFacebook];
}
@end
