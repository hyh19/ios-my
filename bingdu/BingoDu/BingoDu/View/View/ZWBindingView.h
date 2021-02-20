#import <UIKit/UIKit.h>

@class ZWBindingView;

/**
 *  @brief   点击绑定社交账号的代理方法
 */
@protocol ZWBindingViewDelegate <NSObject>

- (void)bingdingPlatformWithType:(BindingType)type;

@end

/**
 *  @author  陈新存
 *  @ingroup view
 *  @brief   点击绑定社交账号时弹出绑定界面
 */
@interface ZWBindingView : UIView

/** 代理属性*/
@property (nonatomic, weak)id<ZWBindingViewDelegate>bingdingDelegate;

@end
