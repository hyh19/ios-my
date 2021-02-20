//
//  STObject.h
//  SQAdevertisement
//
//  Created by sunsea on 15/7/23.
//  Copyright (c) 2015年 sunsea. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef  void(^LoadADBlock)(NSString *);
@interface STObject : NSObject
{
    LoadADBlock _lBlock;
}
@property(nonatomic,copy)NSString *title;//广告的名称
@property(nonatomic,copy)NSString *contentDescrip;//广告的内容描述
@property(nonatomic,copy)NSString *btn_text;//广告内容按钮的文字
@property(nonatomic,strong)NSURL *logo_image_url;//logo的图片获取链接
@property(nonatomic,strong)NSURL *content_image_url;//内容大图获取链接
@property(nonatomic,copy)NSString *brandName;
-(void)adClick:(LoadADBlock)block;
/*
 用户在自己的页面点击广告内容时候调用
 */
@end
