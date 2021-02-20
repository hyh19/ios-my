#import <UIKit/UIKit.h>
#import "Friend.h"
#import "ZWCommentOperationManager.h"


/**进入新闻新闻详情的按钮tag*/
#define BINGYOUCELL_DETAILBTN_TAG  10987

@class ZWBingYouCell;

/**并友结果回调*/
@protocol ZWBingYouTableCellDelegate <NSObject>

@optional
/** 结果回调 */
- (void)bingYouTableViewCell:(ZWBingYouCell *)tableViewCell didClickCellWithNewsInfo:(Friend *)newsInfo;
- (void)bingYouTableViewCell:(ZWBingYouCell *)tableViewCell reply:(BOOL)isReply;
@end
/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 并友tableViewCell
 */
@interface ZWBingYouCell : UITableViewCell

/**
 *  点击cell详情的代理
 */
@property(nonatomic, weak)id<ZWBingYouTableCellDelegate>delegate;
/**
 *  存储并友信息的对象
 */
@property(nonatomic, strong) id friend;
/**
 *  评论内容label
 */
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
/**
 *  品论操作view管理器
 */
@property (strong, nonatomic) ZWCommentOperationManager *operationMagager;

@end
