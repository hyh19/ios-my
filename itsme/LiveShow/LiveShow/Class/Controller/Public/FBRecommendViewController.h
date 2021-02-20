#import "FBBaseViewController.h"
#import "FBRecommendModel.h"

/**
 *  @author 林思敏
 *  @brief  推荐主播界面
 */

@interface FBRecommendViewController : FBBaseViewController

/** 工厂方法 */
+ (instancetype)viewController;

@property (strong, nonatomic) FBRecommendModel *recommendModel;

@property (strong, nonatomic) NSString *recommendSort;

@end
