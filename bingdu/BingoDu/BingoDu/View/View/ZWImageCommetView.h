//
//  ZWImageCommetView.h
//  BingoDu
//
//  Created by SouthZW on 15/9/6.
//  Copyright (c) 2015年 NHZW. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 回复类型枚举
 */
typedef NS_ENUM (NSUInteger,ZWImageCommentType)
{
    ZWImageCommentWrite,  //发送评论
    ZWImageCommentShow,   //显示评论
};

/**
 点击回调block
 */
typedef void (^commentOperation)(NSString *content);




/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief  图片评论view
 */


@interface ZWImageCommetView : UIView<UITextFieldDelegate>

/**
 *  初始化view
 *  @imageCommentType 图评的类型
 *  @content 要显示的内容
 *  @showPoint 内容显示的位置
 *  @commentOperation blcok回调
 *  @return view
 */
-(id)initWithImageCommentType:(ZWImageCommentType) imageCommentType content:(NSString*)content  point:(CGPoint) showPoint callBack:(commentOperation) commentOperation;

/**
 *  用户操作的回调
 */
@property(nonatomic,copy)commentOperation operationBlock;
@end
