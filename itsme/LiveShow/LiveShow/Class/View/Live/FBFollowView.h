//
//  FBFollowView.h
//  LiveShow
//
//  Created by chenfanshun on 10/11/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @author 陈番顺
 *  @since  2.0.0
 *  @brief  关注弹窗（入口暂时只有在观看回放超过1分钟）
 */
@interface FBFollowView : UIView

+(void)showInView:(UIView*)superView withUser:(FBUserInfoModel*)user followAction:(void (^)())block;

@end
