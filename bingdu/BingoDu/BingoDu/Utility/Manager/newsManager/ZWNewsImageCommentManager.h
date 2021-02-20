#import <Foundation/Foundation.h>
#import "ZWImageCommentView.h"
#import "ZWImageCommentModel.h"

/**
 block回调类型
 */
typedef NS_ENUM (NSUInteger,ZWImageCommentResultType)
{
    ZWStartImageComment,  //开始图评
    ZWImageCommentUpload,  //上传图评
    ZWImageCommentLoad,  //下载图评
    ZWImageShowComment,  //显示图评
    ZWImageCommentDelete,  //删除图评
    ZWImageCommentAdd,  //增加图评

};

/**
 点击回调block
 */
typedef void (^imageCommentResultCallBack)(ZWImageCommentResultType imageCommentResultType,ZWImageCommentModel* model,BOOL isSuccess);
/**
 *  @author  刘云鹏
 *  @ingroup utility
 *  @brief 新闻图评管理
 */
@interface ZWNewsImageCommentManager : NSObject
/**
 * 类初始化函数
 * @parma commentView 需要添加图评的view
 * @parma newsId 新闻id
 * @parma imageComentUrl 添加图评的图片的url
 * @parma imageCommentLoadResultCallBack  结果回调
 */
-(id)initWithImageCommentType:(UIView*) commentView newsID:(NSString*)newsId imageUrl:(NSString*) imageComentUrl loadResultBlock:(imageCommentResultCallBack) imageCommentLoadResultCallBack;
/**
 * 显示一条图评
 * @parma model 图评数据model
 */
-(void)addOneImageCommentView:(ZWImageCommentModel*)model;
@end
