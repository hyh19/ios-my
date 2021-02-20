#import <Foundation/Foundation.h>
#import "ZWNewsModel.h"

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 新闻搜索数据model
 */
@interface ZWNewsSearchModel : NSObject

/**新闻数*/
@property (nonatomic, strong)NSNumber *newsSum;

/**专题数*/
@property (nonatomic, strong)NSNumber *topicSum;

/**收藏数*/
@property (nonatomic, strong)NSNumber *favoriteSum;

/**新闻列表数组*/
@property (nonatomic, strong)NSArray *newsListArray;

/**专题列表数组*/
@property (nonatomic, strong)NSArray *topicListArray;

/**收藏列表数组*/
@property (nonatomic, strong)NSArray *favoriteListArray;

/**
 初始化model
 */
+(id)newsSearchModelFromDictionary:(NSDictionary *)dictionary
                        searchType:(SearchType)searchType;

/**
更新model
 */
- (void)updateSearchModelWithDictionary:(NSDictionary *)dictionary
                             searchType:(SearchType)searchType;
/**
 重置数据
 */
- (void)resetNewsData;

@end
