#import <UIKit/UIKit.h>
#import "FBLiveInfoModel.h"
#import "FBFullScreenViewController.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @brief 热门的直播
 */
@interface FBHotLivesViewController : FBFullScreenViewController

/** 热榜第一名的直播 */
+ (FBLiveInfoModel *)topLive;

@end
