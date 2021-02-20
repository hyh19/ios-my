//
//  FBLiveLoadingView.h
//  LiveShow
//
//  Created by chenfanshun on 04/05/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBLiveLoadingView : UIView

-(id)initWithFrame:(CGRect)frame andPortrait:(NSString*)portrait currentImg:(UIImage*)currentImg;

-(void)hideBackground:(BOOL)isHide;

-(void)setTips:(NSString*)tips;

-(void)startAnimate;

-(void)stopAnimate;

@end
