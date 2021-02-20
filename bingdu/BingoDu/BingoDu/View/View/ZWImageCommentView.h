
#import <UIKit/UIKit.h>


/**
 发表评论框的宽度
 */
const  static CGFloat newsCommentImageWidth=128;
/**
 发表评论框的高度
 */
const static CGFloat newsCommentImageHeight=20;
/**
 textfield的高度
 */
const  static CGFloat newsEditTextHeight=20;
/**
 回复类型枚举
 */
typedef NS_ENUM (NSUInteger,ZWImageCommentType)
{
    ZWImageCommentWrite,  //发送评论
    ZWImageCommentShow,   //显示评论
};
/**
 图评来源
 */
typedef NS_ENUM (NSUInteger,ZWImageCommentSource)
{
    ZWImageCommentSourceNewsDetail,  //新闻详情来源
    ZWImageCommentSourceImageDetail,   //图片详情来源
};
/**
 点击回调block
 */
typedef void (^commentOperation)(NSString *content, NSString *imageUrl,NSString *commentId,BOOL isDelete);

/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief  图片评论view
 */


@interface ZWImageCommentView : UIView<UITextFieldDelegate>

/**
 *  初始化view
 *  @imageCommentType 图评的类型
 *  @content 要显示的内容
 *  @showPoint 内容显示的位置
 *  @commentUserId 评论者id
 *  @commentId 评论者id
 *  @imageCommentSource 图评的来源
 *  @commentOperation blcok回调
 *  @return view
 */
-(id)initWithImageCommentType:(ZWImageCommentType) imageCommentType imageUrl:(NSString*)imageUrl content:(NSString*)content  point:(CGPoint) showPoint commentId:(NSString*)commentUserId  imageCommentId:(NSString*)commentId imageCommentSource:(ZWImageCommentSource)imageCommentSource  callBack:(commentOperation) commentOperation;

/**
 *  用户操作的回调
 */
@property(nonatomic,copy)commentOperation operationBlock;

/**
 *  图评id
 */
@property (nonatomic,strong)NSString *commentId;

@end
