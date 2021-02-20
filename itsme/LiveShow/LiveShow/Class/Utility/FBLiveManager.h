//
//  FBLiveManager.h
//  LiveShow
//
//  Created by chenfanshun on 14/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBLiveManager : NSObject

/**
 *  当前直播间viewcontroller
 */
@property(nonatomic, weak)UIViewController *currentLiveController;

/**
 *  当前直播间id
 */
@property(nonatomic, copy)NSString *currentLiveID;

@end
