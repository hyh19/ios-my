#import <Foundation/Foundation.h>
#import "GMGridView.h"

@class ZWUnSelectedChannelDataSource;

/** 频道数据委托*/
@protocol UnSelectedChannelDataSourceDelegate <NSObject>

/**点击频道代理方法*/
- (void)channelDataSource:(ZWUnSelectedChannelDataSource *)channelDataSource
        didTapOnItemTitle:(NSString *)itemTitle;

@end

@interface ZWUnSelectedChannelDataSource : NSObject<GMGridViewDataSource,GMGridViewActionDelegate>

/** 频道代理*/
@property (nonatomic, weak) id<UnSelectedChannelDataSourceDelegate> delegate;

/** 频道数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
