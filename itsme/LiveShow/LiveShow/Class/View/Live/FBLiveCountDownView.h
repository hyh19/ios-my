//
//  FBLiveCountDownView.h
//  LiveShow
//
//  Created by tak on 16/7/19.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBLiveCountDownView : UIView

@property(nonatomic, copy) void (^finishBeginCountDown)();

@end
