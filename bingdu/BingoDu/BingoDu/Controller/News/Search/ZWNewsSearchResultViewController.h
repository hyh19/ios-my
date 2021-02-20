#import <UIKit/UIKit.h>
#import "ZWBaseViewController.h"
#import "ZWNewsSearchModel.h"

/**
 *  @author 陈新存
 *  @ingroup controller
 *  @brief 新闻搜索结果界面
 */
@interface ZWNewsSearchResultViewController : ZWBaseViewController

/**搜索词*/
@property (nonatomic, copy)NSString *searchWordString;

/** 搜索数据model*/
@property (nonatomic, strong)ZWNewsSearchModel *searchModel;

@end
