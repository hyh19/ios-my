#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "Friend.h"

@class ZWBingYouTableView;

/**并友代理*/
@protocol ZWBingYouTableViewDelegate <NSObject>

/**并友代理的回调*/
- (void)pushToNewsDetailViewWithTableView:(ZWBingYouTableView *)tableView dataSource:(Friend *)dataSource;

@end

/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 并友tableView
 */
@interface ZWBingYouTableView : PullTableView <UITableViewDataSource, UITableViewDelegate>

/*
 存放每个cell的数据源
 */
@property (nonatomic, strong) NSMutableArray *cellDataSources;

// TODO: 补充属性的注释
@property (nonatomic, weak) id<ZWBingYouTableViewDelegate>tableViewDelegate;

@end
