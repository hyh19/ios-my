#import <UIKit/UIKit.h>
#import "ZWLoadingView.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief 自定义UIView的拓展功能
 */
@interface UIView (NHZW)

@end


/**
 *  @author 黄玉辉->陈梦杉
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
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief 正在加载提示
 */
@interface UIView (Loading)

/** 是否有正在加载提示 */
- (BOOL)hasLoadingView;

/** 添加正在加载提示 */
- (void)addLoadingView;

/**
 *  @brief  添加正在加载提示
 *  @param block 添加完成后的回调操作
 */
- (void)addLoadingViewWithCompletionBlock:(void (^)(void))block;

/**
 *  @brief  添加正在加载提示
 *  @param block 添加完成后的回调操作
 *  @param type 加载提示所在的界面类型，主要分为一般的界面和并友、收藏等小界面
 */
- (void)addLoadingViewWithCompletionBlock:(void (^)(void))block andType:(ZWLoadingParentType)type;

/**
 *  @brief  添加正在加载提示
 *  @param frame 位置
 */
- (void)addLoadingViewWithFrame:(CGRect)frame;

/**
 *  @brief  添加正在加载提示
 *  @param frame 位置
 *  @param type 加载提示所在的界面类型，主要分为一般的界面和并友、收藏等小界面
 */
- (void)addLoadingViewWithFrame:(CGRect)frame andType:(ZWLoadingParentType)type;

/**
 *  @brief  添加正在加载提示
 *  @param frame 位置
 *  @param block 添加完成后的回调操作
 */
- (void)addLoadingViewWithFrame:(CGRect)frame andCompletionBlock:(void (^)(void))block;

/**
 *  @brief  添加正在加载提示
 *  @param frame 位置
 *  @param block 添加完成后的回调操作
 *  @param type 加载提示所在的界面类型，主要分为一般的界面和并友、收藏等小界面
 */
- (void)addLoadingViewWithFrame:(CGRect)frame type:(ZWLoadingParentType)type andCompletionBlock:(void (^)(void))block;

/** 移除正在加载提示 */
- (void)removeLoadingView;

/**
 *  @brief  移除正在加载提示
 *  @param block 移除完成后的回调操作
 */
- (void)removeLoadingViewWithCompletionBlock:(void (^)(void))block;

@end