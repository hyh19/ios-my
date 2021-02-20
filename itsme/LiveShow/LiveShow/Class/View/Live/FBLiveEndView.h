//
//  FBLiveEndView.h
//  LiveShow
//
//  Created by lgh on 16/3/22.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"

typedef enum : NSUInteger {
    /** 直播结束观众界面 */
    FBLiveEndViewTypeOthers,
    /** 直播结束主播界面 */
    FBLiveEndViewTypeMine  ,

} FBLiveEndViewType;

@interface FBLiveEndView : UIView

@property(nonatomic, assign) FBLiveRoomFromType fromType;

- (instancetype)initWithFrame:(CGRect)frame liveid:(NSString*)live_id type:(FBLiveEndViewType)type showNotSave:(BOOL)bShowSave  isNetworkError:(BOOL)bNetWorkError;

- (void)update:(FBUserInfoModel*)model bkgImage:(UIImage*)bkgImage;

- (void)updateTimeString:(NSString*)timeString;

- (void)updateALertTips:(NSString*)tips;

@end
