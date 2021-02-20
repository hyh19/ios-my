#import <UIKit/UIKit.h>
#import "FBNetworkManager.h"

/**
 *  @author 黄玉辉
 *  @brief View controller的基类
 */
@interface FBBaseViewController : UIViewController

/** 统计打点信息 */
@property (nonatomic, strong) NSMutableDictionary *statisticsInfo;

- (void)goBack;

@end
