#import <UIKit/UIKit.h>

// TODO: 补充属性的注释
// TODO: 补充方法的注释

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *
 *  @brief 工程里Controller的基类
 */
@interface ZWBaseViewController : UIViewController

@property (nonatomic, assign) BOOL backIsshow;
@property (nonatomic, assign) BOOL isShowBarTitleRefresh;
/*
 @parm 头部刷新按钮点击触发方法
 */
- (void)refreshAction;
- (void)back;

/** 返回按钮的回调函数 */
- (void)onTouchButtonBack;

@end
