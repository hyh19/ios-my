#import <Foundation/Foundation.h>
#import "GMGridView.h"

@class ZWChannelDataSource;

/** 频道数据委托*/
@protocol ChannelDataSourceDelegate <NSObject>

/**点击频道代理方法*/
- (void)dataSource:(ZWChannelDataSource *)channelDataSource didTapOnItemTitle:(NSString *)itemTitle;

@end

/**
 *  @author 陈新存
 *  @ingroup controller
 *  @brief 频道数据代理
 */
@interface ZWChannelDataSource : NSObject<GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewActionDelegate>

/** 频道代理*/
@property (nonatomic, weak) id<ChannelDataSourceDelegate> delegate;

/** 频道数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
