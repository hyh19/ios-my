//
//  ZWLiftStyleIntroduceNewsModel.h
//  BingoDu
//
//  Created by SouthZW on 15/12/23.
//  Copyright © 2015年 NHZW. All rights reserved.
//
/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 生活方式推荐新闻数据模型
 */
#import <Foundation/Foundation.h>

@interface ZWLiftStyleIntroduceNewsModel : NSObject
/**
 标题
 */
@property (nonatomic,strong)NSString *title;
/**
 子类数组
 */
@property (nonatomic,strong)NSMutableArray *subModelArray;
/**
 构建对象
 */
+(id)talkModelFromDictionary:(NSDictionary *)dic;
@end
