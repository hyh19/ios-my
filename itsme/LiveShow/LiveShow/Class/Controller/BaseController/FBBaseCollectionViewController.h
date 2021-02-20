#import <UIKit/UIKit.h>
#import "FBNetworkManager.h"

/**
 *  @author 黄玉辉
 *  @brief collection view controller的基类
 */
@interface FBBaseCollectionViewController : UICollectionViewController

/** 统计打点信息 */
@property (nonatomic, strong) NSMutableDictionary *statisticsInfo;

@end
