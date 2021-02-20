#import <UIKit/UIKit.h>

/** 提现界面引导页 */
#define kGuidePageWithdraw    @"GuidePageWithdraw"

/** 新闻详情界面引导页 */
#define kGuidePageNeswDetail  @"GuidePageNeswDetail"

/** 用户中心引导页 */
#define kGuidePageUser      @"GuidePageUser"

/** 图片详情界面引导页 */
#define kGuidePageImageDetail @"GuidePageImageDetail"

@class ZWGuideView;

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 引导页管理器
 */
@interface ZWGuideManager : NSObject

/**
 *  打开引导页
 *  @param name 引导页名称
 */
+ (void)showGuidePage:(NSString *)name;

/** 关闭引导页 */
+ (void)dismissGuidePage;

/** 当前屏幕是否有引导页 */
+ (BOOL)hasGuidePage;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  引导页
 */
@interface ZWGuideView : UIView

/**
 *  初始化
 *  @param name 引导页名称
 */
- (instancetype)initWithName:(NSString *)name;

@end
