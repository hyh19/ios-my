#import "FBBaseViewController.h"
#import "FBLiveInfoModel.h"

/**
 *  @author 黄玉辉
 *  @brief 直播间，可上下切换直播
 */
@interface FBLiveRoomViewController : FBBaseViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property(nonatomic, assign) FBLiveRoomFromType fromType;

- (instancetype)initWithLives:(NSArray *)lives focusLive:(FBLiveInfoModel *)live;

/** 提示网络错误 */
- (void)showNetworkError;

@end
