#import <Foundation/Foundation.h>
#import "FBFailureView.h"

/**
 *  @author 黄玉辉
 *  @ingroup category
 *  @brief 调试时用于描绘控件线框
 */
@interface UIView (Debug)

/**
 *  描绘控件的轮廓线框，线框颜色默认为红色，粗细默认为1
 */
- (void)debug;

/**
 *  描绘控件的轮廓线框，线框粗细默认为1
 *
 *  @param color 线框颜色
 */
- (void)debugWithBorderColor:(UIColor *)color;

/**
 *  描绘控件的轮廓线框
 *
 *  @param color 线框颜色
 *  @param width 线框粗细
 */
- (void)debugWithBorderColor:(UIColor *)color andBorderWidth:(CGFloat)width;

@end

/**
 *  @author 黄玉辉
 *  @ingroup category
 *  @brief 错误页
 */
@interface UIView (Failure)

/** 添加错误页 */
- (FBFailureView *)addFailureViewWithFrame:(CGRect)frame image:(NSString *)image message:(NSString *)message;

/** 移除错误页 */
- (void)removeFailureView;

@end