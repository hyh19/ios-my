//
//  FBShareMenuVIew.h
//  LiveShow
//
//  Created by tak on 16/9/1.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBShareMenuView : UIView

@property (nonatomic, copy) void (^doShareLiveAction)(NSString *platform, FBShareLiveAction action, FBShareMenuView *menu);

- (void)dissmiss;

@end


@interface FBShareItem : UIButton


@end