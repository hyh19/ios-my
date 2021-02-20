#import "ZWNewsBaseCell.h"
#import "YDSDKHeaders.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 互锋移动广告
 */
@interface ZWYDADCell : ZWNewsBaseCell <YDNativeAdRendering, YDNativeAdDelegate>

/** 高度 */
+ (CGFloat)height;

/** 互锋广告数据 */
@property (nonatomic, strong) YDNativeAd *nativeAd;

/** 负责弹出广告的视图控制器 */
@property (nonatomic, weak) UIViewController *presentingViewController;

@end
