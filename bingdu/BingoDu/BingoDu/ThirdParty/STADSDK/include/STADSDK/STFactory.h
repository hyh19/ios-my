//
//  STFactory.h
//  SQAdevertisement
//
//  Created by sunsea on 15/7/23.
//  Copyright (c) 2015年 sunsea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STObject.h"
#import "STParams.h"
typedef void (^InitSuccessBlock)(void);
typedef void (^InitFailBlock)(int);
typedef void (^GetSuccessBlock)(void);
typedef void (^GetFailBlock)(int);
@interface STFactory : NSObject
+(STFactory*)defaultFactory;//获取单例类
-(void)initWithSTParams:(STParams *)params AndInitSuccessBlock:(InitSuccessBlock)sBlock AndInitFailBlock:(InitFailBlock)fBlock;
/*
 初始化
 STParams 说明
 adSpaceID:广告主在时趣广告平台申请的ID
 customInfo:json串 里面包含微信的ID 和新浪微博的ID 以及后续的扩展参数
 isTest:线上和测试环境切换，测试环境传入YES,线上环境传入NO
 block:初始化成功回调 进入回调说明成功获取到数据 可以进行接下来的操作
 */
-(STObject *)getNativeAdsWithADSpaceID:(NSString *)adSpaceID;
/*
 获取广告内容 
 返回的是一个广告的内容的一个对象STObject ,STObject的内容参照STObject.h
 adSpaceID:广告主在时趣广告平台申请的ID
*/
@end
