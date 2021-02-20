//
//  FBServerSettingsModel.h
//  LiveShow
//
//  Created by chenfanshun on 16/11/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @author 陈番顺
 *  @since 2.0.0
 *  @brief 服务器相关配置信息
 */


/**
 *  观看回放弹窗所需时间
 */
@interface FBRecordInterruptingModel : NSObject

@property(nonatomic, strong) NSNumber *interruptingTime;
@property(nonatomic, strong) NSString *ID;

@end

/**
 *  附近多少公里需要统计
 */
@interface FBDistanceOfAnchorsModel : NSObject

@property(nonatomic, strong) NSNumber *distanceValue;
@property(nonatomic, strong) NSString *ID;

@end

/**
 *  快速发言
 */
@interface FBPresetDialogModel : NSObject

@property(nonatomic, strong) NSString *country;
@property(nonatomic, strong) NSString *identityCategory;
@property(nonatomic, strong) NSString *dialog;
@property(nonatomic, strong) NSString *ID;

@end


@interface FBServerSettingManager : NSObject

@property(nonatomic, strong)FBRecordInterruptingModel *recrodInterrupting;

@property(nonatomic, strong)FBDistanceOfAnchorsModel *distanceOfAnchors;

@property(nonatomic, strong)NSMutableArray *arrayPresetDialog;


/**
 * 附近多少km才算附近
 */
- (NSInteger)nearbyDistance;

/**
 * 回放弹窗时间(单位s)
 */
- (NSInteger)replayInterrupting;

@end
