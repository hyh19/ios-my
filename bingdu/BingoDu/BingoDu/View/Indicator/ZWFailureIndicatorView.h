#import <UIKit/UIKit.h>

/** 错误提示页类型 */
typedef NS_ENUM(NSUInteger, ZWFailureIndicatorViewType) {
    
    /** 默认错误提示页类型 */
    ZWFailureIndicatorViewTypeDefault = 0,
    
    /** 订阅频道新闻列表错误提示页类型 */
    ZWFailureIndicatorViewTypeSubscription
};

typedef void (^ZWFailViewBlock)(void);
/**
 *  @author  黄玉辉
 *  @ingroup view
 *  @brief   调用网路失败后的界面
 */
@interface ZWFailureIndicatorView : UIView

// TODO: 该方法以后要删除，有时间再处理
- (void)initWithContent:(NSString *)content
                  image:(UIImage *)image
            buttonTitle:(NSString *)buttonTitle
             showInView:(UIView *)view
                  event:(void (^)(void))event;

/**
 *  @brief  显示错误页
 *
 *  @param view        所在父类
 *  @param message     提示信息
 *  @param image       提示图片
 *  @param buttonTitle 提示按钮
 *  @param block       按钮事件
 */
+ (void)showInView:(UIView *)view
       withMessage:(NSString *)message
             image:(UIImage *)image
       buttonTitle:(NSString *)buttonTitle
       buttonBlock:(void (^)(void))block;

/**
 *  @brief  显示错误页
 *
 *  @param view            错误页父视图
 *  @param message         提示信息
 *  @param image           提示图片
 *  @param buttonTitle     提示按钮标题
 *  @param buttonBlock     提示按钮事件
 *  @param completionBlock 显示后的回调函数
 */
+ (void)showInView:(UIView *)view
       withMessage:(NSString *)message
             image:(UIImage *)image
       buttonTitle:(NSString *)buttonTitle
       buttonBlock:(void (^)(void))buttonBlock
   completionBlock:(void (^)(void))completionBlock;

+ (void)showInView:(UIView *)view
          withType:(ZWFailureIndicatorViewType)type
           message:(NSString *)message
             image:(UIImage *)image
       buttonTitle:(NSString *)buttonTitle
       buttonBlock:(void (^)(void))block;

+ (void)showSubscribeViewInView:(UIView *)view withButtonBlock:(void (^)(void))block;

/** 移除错误页 */
+ (void)dismissInView:(UIView *)view;

/**
 *  @brief  移除错误页
 *
 *  @param view            错误页父视图
 *  @param completionBlock 移除后的回调函数
 */
+ (void)dismissInView:(UIView *)view
  withCompletionBlock:(void (^)(void))completionBlock;

/**
 *  @brief  判断是否存在错误页
 *  @param view 错误页所在的父视图
 */
+ (BOOL)hasFailureViewInView:(UIView *)view;

@end
