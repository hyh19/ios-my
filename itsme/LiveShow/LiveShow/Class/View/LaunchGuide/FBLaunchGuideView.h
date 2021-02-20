//
//  FBGuideView.h
//  LiveShow
//
//  Created by chenfanshun on 09/11/16.
//  Copyright © 2016年 FB. All rights reserved.
//


#import <UIKit/UIKit.h>


/**
 *  @author 陈番顺
 *  @since  2.0.0
 *  @brief  启屏向导
 */

@interface FBLaunchGuideView : UIView

-(void)showGuideViewWithImages:(NSArray*)images
                andButtonTitle:(NSString*)title;

@end
