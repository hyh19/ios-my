

#import <Foundation/Foundation.h>
#import "ZWCommentPopView.h"
/**
 block回调类型
 */
typedef NS_ENUM (NSUInteger,ZWCommentOperationResultType)
{
    ZWNewsCommentOperation,  //新闻评论的操作
    ZWFriendReplyCommentOperation,  //并友评论的操作
};

/**
 点击回调block
 */
typedef void (^commentOperationResultCallBack)(ZWCommentOperationResultType commentOperationResultType, ZWClickType clickType);

/**评论操作view的tag*/
# define commentViewTag 50034
/**
 *  @author  刘云鹏
 *  @ingroup utility
 *  @brief 新闻评论操作管理
 */
@interface ZWCommentOperationManager : NSObject
/**
 构造函数
 */
-(id) initWithCommentOperationType:(ZWCommentOperationResultType)commentOperationResultType cell:(UITableViewCell*) tabelCell allBack:(commentOperationResultCallBack) operationResultCallBack;
;
/**
 * @brief显示或者评论操作视图
 *  isShow  是否显示
 *  @isAuto 自动  为yes 时 isshow 无效
 */
-(void)animateShowOrHideOpretationView:(BOOL)isShow auto:(BOOL)isAuto;

@end
