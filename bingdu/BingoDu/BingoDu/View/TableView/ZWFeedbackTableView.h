#import <UIKit/UIKit.h>
#import "LoadMoreTableFooterView.h"
#import "UMFeedback.h"
/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 意见反馈界面
 */
@interface ZWFeedbackTableView : UITableView<LoadMoreTableFooterDelegate,UITableViewDelegate, UITableViewDataSource,UMFeedbackDataDelegate, UIScrollViewDelegate>

/**用于存放所有消息的坐标信息的可变数组*/
@property (nonatomic, strong) NSMutableArray *allMessagesFrame;
/**第三方友盟反馈类属性*/
@property (strong, nonatomic) UMFeedback *feedback;
/**上拉加载更多的view属性*/
@property (nonatomic, strong) LoadMoreTableFooterView *loadMoreView;
/**是否上拉加载属性*/
@property (nonatomic, assign) BOOL pullTableIsLoadingMore;

@end
