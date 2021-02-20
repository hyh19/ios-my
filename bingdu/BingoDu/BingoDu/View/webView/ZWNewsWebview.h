#import <UIKit/UIKit.h>
#import "ZWNewsModel.h"
#import "ZWNewsImageCommentManager.h"
#import "ZWImageCommentModel.h"
/**
 block回调类型
 */
typedef NS_ENUM (NSUInteger,ZWWebViewStatus)
{
    ZWWebViewStart,  //开始加载
    ZWWebViewFinsh,  //加载完成
    ZWWebViewFaild,  //开始加载
    ZWWebViewLoading,  //正在加载
    ZWWebViewAddImageComment,     //增加图评
    ZWWebViewContentSizeChanged,     //contentSize 变化了
};
/**
 webview状态回调block
 */
typedef void (^webViewStatusCallBack)(ZWWebViewStatus webViewStatus,NSURLRequest* request,ZWImageCommentModel *modle);

@interface ZWNewsWebview : UIWebView<UIWebViewDelegate>
/**
 类构造
 */
-(id)initWithFrame:(CGRect)frame newsModel:(ZWNewsModel*)model callBack:(webViewStatusCallBack) statusCallBack;
/**
 所有图评信息
 */
@property (nonatomic, strong) NSMutableDictionary *imageCommentList;
/**
 所有评论都加载完毕
 */
@property (nonatomic,assign)BOOL isCommentFinished;
/**
 开始加载
 */
-(void)loadNewsRequest;
@end
