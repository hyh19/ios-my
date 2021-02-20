//
//  FBRoomManagerModel.h
//  LiveShow
//
//  Created by chenfanshun on 22/06/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBBaseModel.h"
#import "FBUserInfoModel.h"

/**
 *  频道管理状态
 */
#define kEventSetManager        @"setmanager"
#define kEventUnsetManager      @"unsetmanager"
#define kEventBanTalk           @"bantalk"
#define kEventUnbanTalk         @"unbantalk"
#define kEventbanUser           @"banuser"
#define kEventUnbanUser         @"unbanuser"

@interface FBRoomManagerModel : FBBaseModel

/**
 *  直播间id
 */
@property(nonatomic, strong)NSString *live_id;

/**
 *  事件名
 */
@property(nonatomic, strong)NSString *event;

/**
 *  用户uid
 */
@property(nonatomic, strong) NSNumber *uid;

/**
 *  用户信息
 */
@property(nonatomic, strong)FBUserInfoModel *user;


@end
