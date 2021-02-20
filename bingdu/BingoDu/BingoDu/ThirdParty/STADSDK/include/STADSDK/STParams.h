//
//  STParams.h
//  SQAdevertisement
//
//  Created by sunsea on 15/7/31.
//  Copyright (c) 2015年 sunsea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STParams : NSObject
+(STParams *)shareParams;
@property(nonatomic,retain)NSString *adSpaceID; //广告位ID
@property(nonatomic,assign)BOOL isTest;//是线上环境还是测试环境
@property(nonatomic,retain)NSString *wxID;//微信平台的参数
@property(nonatomic,retain)NSString *sinaID;//新浪平台的参数
@property(nonatomic,assign)BOOL translucent;
@end
