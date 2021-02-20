//
//  ZWArticleDetailViewController.h
//  BingoDu
//
//  Created by SouthZW on 15/9/16.
//  Copyright (c) 2015年 NHZW. All rights reserved.
//

#import "ZWBaseViewController.h"
#import "ZWNewsModel.h"

/**
 *  @author 刘云鹏
 *  @ingroup controller
 *  @brief 新闻详情界面
 */
@interface ZWArticleDetailViewController : ZWBaseViewController
/**
  类初始化
 */
-(id)initWithNewsModel:(ZWNewsModel*)model;

@property(nonatomic,strong) UIViewController *themainview;


/**是否加载完成*/
@property (nonatomic, assign) BOOL loadFinish;
@end
