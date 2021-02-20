//
//  FBLivePrepareView.h
//  LiveShow
//
//  Created by chenfanshun on 02/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  准备开播视图
 */
@interface FBLivePrepareView : UIView

@property(nonatomic, copy)void (^doClose)();
@property(nonatomic, copy)void (^doOpenLive)(BOOL useLocation, BOOL useHighQuality, BOOL facebookShare, BOOL twitterShare, NSString *tagsString);
@property(nonatomic, copy)void (^doBindFacebook)();
@property(nonatomic, copy)void (^doBindTwitter)();
@property(nonatomic, copy)void (^doShowRule)();

-(NSString*)getLiveName;

-(void)enableOpenLive:(BOOL)isEnable;

-(void)notifyFacebookBookBindSuccess;

-(void)notifyTwitterBookBindSuccess;

@end
