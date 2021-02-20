#import <UIKit/UIKit.h>
#import "ZWBaseViewController.h"
#import "ZWNewsModel.h"

/**
 *  @author 陈新存
 *  @ingroup controller
 *  @brief 专题报道界面
 */
@interface ZWSpecialNewsViewController : ZWBaseViewController

/** 新闻数据源*/
@property (nonatomic, strong) ZWNewsModel *newsModel;

/** 频道名称 */
@property (nonatomic, copy) NSString *channelName;

@end
