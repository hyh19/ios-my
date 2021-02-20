#import <UIKit/UIKit.h>
#import "ZWNewsTalkModel.h"
#import "ZWHotReadAndTalkTableView.h"
#import "ZWCommentOperationManager.h"
/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 新闻热议cell
 */
@interface ZWReviewCell : UITableViewCell

/**
 *  用户头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
/**
 *  用户名称
 */
@property (weak, nonatomic) IBOutlet UILabel *userName;
/**
 *  评论发表时间
 */
@property (weak, nonatomic) IBOutlet UILabel *publishTime;
/**
 *  评论内容
 */
@property (weak, nonatomic) IBOutlet UILabel *publishContent;
/**
 *  点赞按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *approvalButton;
/**
 *  评论数据对象
 */
@property (strong, nonatomic) ZWNewsTalkModel *reviewData;
/**
 *  cell所在的talbeview
 */

@property (weak, nonatomic) ZWHotReadAndTalkTableView *baseTabView;

/**
 * 图评标记
 */
@property (weak, nonatomic) IBOutlet UILabel *imageComentLable;

/**
 * 是否是热议cell的标记
 */
@property (assign, nonatomic) BOOL isHotTalkCell;

/**
 *  点赞响应函数
 *  @param sender
 */
- (IBAction)chickLike:(id)sender;

/**
 *  点举报响应函数
 *  @param sender
 */
- (void)chickReport:(id)sender;
/**
 *  品论操作view管理器
 */
@property (strong, nonatomic) ZWCommentOperationManager *operationMagager;

@end
