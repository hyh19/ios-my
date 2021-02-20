//
//  MJRefreshNormalHeader.h
//  MJRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJRefreshStateHeader.h"

@interface MJRefreshNormalHeader : MJRefreshStateHeader
@property (weak, nonatomic, readonly) UIImageView *arrowView;

/**
 *  @author 林思敏
 *  @brief  添加一个箭头图标距离中心偏移量
 */
/** 箭头图标距离中心偏移量 **/
@property (assign, nonatomic) CGFloat arrowViewOffset;

/** 菊花的样式 */
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle;
@end
