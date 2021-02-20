#import "ZWBaseViewController.h"
#import "PullTableView.h"
// 交接
/** 新闻列表动作事件 */
typedef NS_ENUM(NSUInteger, ZWNewsListActionType){
    /** 静止状态 */
    kNewsListActionTypeIdle = 1,
    
    /** 下拉刷新 */
    kNewsListActionTypeRefresh = 2,
    
    /** 上拉加载更多 */
    kNewsListActionTypeLoadMore = 3,
    
    /** 切换频道 */
    kNewsListActionTypeChannelSwitch = 4,
    
    /** 从后台重新进入前台 */
    kNewsListActionTypeEnterForeground = 5
};

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup controller
 *  @brief 新闻列表界面
 */
@interface ZWNewsListViewController : ZWBaseViewController

/** 频道ID */
@property (nonatomic, assign) NSInteger channelId;

/**
 *  @brief 频道唯一标识
 *  @since 1.5.0
 */
@property (nonatomic, copy) NSString *channelMapping;

/** 新闻列表 */
@property (nonatomic, strong) PullTableView *tableView;

/** 新闻列表动作事件 */
@property (nonatomic, assign) ZWNewsListActionType actionType;

/** 首次进入频道是否成功加载数据 */
@property (nonatomic, assign) BOOL firstLoadFinished;

/** 是否处于正在加载状态 */
@property (nonatomic, assign) BOOL loading;

/** 加载数据 */
- (void)reloadData;

/** 点击底部标签刷新 */
- (void)tapRefresh;

@end
