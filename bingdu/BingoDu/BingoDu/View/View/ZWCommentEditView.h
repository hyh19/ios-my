
#import <UIKit/UIKit.h>
#import "ZWPlaceholderTextview.h"
typedef NS_ENUM (NSUInteger,ZWCommentTextviewType)
{
    ZWCommentTextviewTextChange,  //文本发生变化
    ZWCommentTextviewSinaShare,  //新浪分享
    ZWCommentTextviewQQZoneShare,  //QQ空间分享
    ZWCommentTextviewFriendShare,  //朋友圈
    ZWCommentTextviewSendComment,  //发送评论
    ZWCommentTextviewSinaAuthor,  //新浪授权

};


typedef NS_ENUM (NSUInteger,ZWSourceType)
{
    ZWSourceNewsDetail,  //新闻详情的评论
    ZWSourceBingYouReply,  //并友的回复
    ZWSourceNewsTalk,  //最新评论
};

/**
 评论编辑的回调
 */
typedef void (^textViewOperationCallBack)(ZWCommentTextviewType commentTextviewType,NSString *content);

/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 发表评论编辑界面
 */
@interface ZWCommentEditView : UIView
/**
 * 构造方法
 * @prama frame view的frame
 * @prama sourceType 评论的来源
 * @prama textViewOperationCallBack 结果回调
 */
- (instancetype)initWithFrame:(CGRect)frame  sourceType:(ZWSourceType) sourceType callBack:(textViewOperationCallBack) textViewOperationCallBack;
/**
 评论view
 */
@property (nonatomic,strong) ZWPlaceholderTextview *commentTextView;
/**
新闻id
 */
@property (nonatomic,strong) NSString *newsId;
/**
  回复某条评论的评论id 当id=0时表示不是回复某条评论
 */
@property (nonatomic,strong) NSNumber *repleyCommentId;
/**
 发表评论是否成功
 */
@property (nonatomic,assign) BOOL isCommentSuccess;
/**
 开始编辑
 */
-(void)startEdit;
/**
结束编辑
*/
-(void)endEdit;
/**
 获取sendBtn
 */
-(UIButton*)getSendBtn;

@end
