#import "PullTableView.h"
#import "ZWCommentPopView.h"
/**
 点击回调block
 */
typedef void (^commentTableViewCallBack)(ZWClickType clickType ,id obj);
/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 并友评论tableview
 */
@interface ZWBingyouCommentTableView : PullTableView<UITableViewDataSource>

/**
 *  table的数据源
 */
@property(nonatomic,strong)NSMutableArray *cellDataSources;

/**
 *  存储是否需要显示section下面的subitem
 */
@property(nonatomic,strong)NSMutableArray *isShowsubitemArray;
/**
 *  操作回调
 */
@property(nonatomic,copy)commentTableViewCallBack commentCallback;

@end
