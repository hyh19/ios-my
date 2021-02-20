//
//  XXUserModel.m
//  LiveShow
//
//  Created by lgh on 16/2/24.
//  Copyright © 2016年 XX. All rights reserved.
//

#import "FBUserInfoModel.h"
#import "FBLoginInfoModel.h"
#import "FBProfileNetWorkManager.h"

@interface FBUserInfoModel ()

/** 登录用户id，以后会废弃，别用 */
@property (nonatomic, strong) NSNumber *ID;
/** 其他用户uid，以后会废弃，别用 */
@property (nonatomic, strong) NSNumber *uid;

@property (nonatomic, strong) UIImageView *avatarImageView;

@end

@implementation FBUserInfoModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{
             @"ID" : @"id",
             @"Description" : @"description",
             };
}

- (NSString *)userID {
    if (self.ID) {
        return [self.ID stringValue];
    }
    if (self.uid) {
        return [self.uid stringValue];
    }
    
    return _userID;
}


- (NSString *)nick {
    if ([_nick isValid]) {
        return _nick;
    }
    return kDefaultNickname;
}

- (UIImage *)genderImage {
    if ([self.gender integerValue] == 0) {
        return [UIImage imageNamed:@"pub_icon_female"];
    }
    return [UIImage imageNamed:@"pub_icon_male"];
}

- (UIImage *)avatarImage {
    if (self.avatarImageView.image) {
        return self.avatarImageView.image;
    }
    return kDefaultImageAvatar;
}

- (void)setPortrait:(NSString *)portrait {
    _portrait = portrait;
    [self.avatarImageView fb_setImageWithName:self.portrait size:CGSizeMake(100, 100) placeholderImage:kDefaultImageAvatar completed:nil];
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
    }
    return _avatarImageView;
}

- (BOOL)isLoginUser {
    NSString *loginUserID = [[FBLoginInfoModel sharedInstance] userID];
    if ([self.userID isValid] && [loginUserID isValid] && self.userID.isEqualTo(loginUserID)) {
        return YES;
    }
    return NO;
}

- (void)checkFollowingStatus:(void (^)(BOOL result))block {
    [[FBProfileNetWorkManager sharedInstance] getRelationWithUserID:self.userID success:^(id result) {
        NSString *relation = result[@"relation"];
        if ([relation isKindOfClass:[NSString class]] && [relation isValid]) {
            // 已关注
            if ([relation isEqualToString:@"following"] ||
                [relation isEqualToString:@"friend"]) {
                if (block) {
                    block(YES);
                }
            } else {
                if (block) {
                    block(NO);
                }
            }
        }
    } failure:^(NSString *errorString) {
        if (block) {
            block(NO);
        }
    } finally:^{
        //
    }];
}

- (BOOL)isVerifiedBroadcastor {
    return [self.verified boolValue];
}

- (CGFloat)DescriptionHeight {
    if (_Description.length > 0) {
        return  [_Description boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20, 90) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:25]} context:nil].size.height;
    } else {
        return 0;
    }
    
}

@end
