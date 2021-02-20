#import <UIKit/UIKit.h>
#import "PullCollectionView.h"

/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 读图频道下的新闻列表展示
 */
@interface ZWImageChannelCollectionView : PullCollectionView<UICollectionViewDataSource>

/** 新闻数据 */
@property (nonatomic, strong) NSMutableDictionary *newsDictionary;

/**
 *  强制刷新数据
 */
-(void)forceToFreshData;

@end
