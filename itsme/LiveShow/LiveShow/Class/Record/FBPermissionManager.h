//
//  FBPermissionManager.h
//  LiveShow
//
//  Created by chenfanshun on 03/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  检查麦克风，摄像头权限
 */
@interface FBPermissionManager : NSObject

+(instancetype)shareInstance;

- (void)checkMicPermissionsWithBlock:(void(^)(BOOL granted))block;
- (void)checkCameraPermissionWithBlock:(void(^)(BOOL granted))block;

@end
