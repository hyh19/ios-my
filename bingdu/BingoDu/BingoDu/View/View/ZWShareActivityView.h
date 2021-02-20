#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>

/**分享类型*/
typedef enum {
    NewsShareType = 1,          /** 分享新闻*/
    WithdrawShareType = 2,      /** 分享提现*/
    GoodsShareType = 3,         /** 分享商品兑换*/
    AdvertisementShareType = 4  /** 分享广告*/
} ShareType;

@interface ZWShareParametersModel : NSObject

/**频道ID*/
@property (nonatomic, strong)NSString *channelID;

/**分享ID*/
@property (nonatomic, strong)NSString *shareID;

/**商品流水ID*/
@property (nonatomic, strong)NSString *orderID;

/**分享类型*/
@property (nonatomic, assign)ShareType shareType;

/**实例化分享接口参数数据模型*/
/**
 *  实例化分享接口参数数据模型
 *
 *  @param channelID        频道ID（只有在新闻分享的时候需要传，其他的传nil）
 *  @param type             分享类型
 *  @param shareID          分享ID（分享新闻：新闻ID；  分享提现：提现ID；
                                  分享兑换：由商品ID；分享广告：广告ID）
 *  @param orderID          商品兑换订单流水号
 */
+(id)shareParametersModelWithChannelId:(NSString *)channelID
                               shareID:(NSString *)shareID
                             shareType:(ShareType)shareType
                               orderID:(NSString *)orderID;

@end

/**
 *  分享内容状态变更回调处理器
 *
 *  @param state            状态
 *  @param type             分享类型
 *  @param userData         附加数据, 返回状态以外的一些数据描述，如：邮件分享取消时，标识是否保存草稿等
 *  @param contentEntity    分享内容实体,当且仅当state为SSDKResponseStateSuccess时返回
 *  @param error            错误信息,当且仅当state为SSDKResponseStateFail时返回
 */
typedef void(^ZWShareFinishBlock) (SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity,  NSError *error);

/**
 *  调用分享接口后的结果返回
 *
 *  @param successed        是否成功，成功则为YES，否则为NO
 *  @param isAddPoint        是否加分，加则为YES，不加则为NO
 *  @param errorString      错误信息
 */
typedef void (^ZWShareRequestResultBlock)(BOOL successed, BOOL isAddPoint, NSString *errorString);

/**
 *  调用新浪微博快捷分享接口后的结果返回
 *
 *  @param successed        是否成功，成功则为YES，否则为NO
 *  @param errorString      错误信息
 */
typedef void (^ZWWeiboAuthorizedResultBlock)(BOOL successed);

/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 第三方分享控件
 */
@interface ZWShareActivityView : UIView

/**
 *	显示带有二维码的分享视图
 *	@param 	title 	      标题（QQ空间、微信、QQ）
 *	@param 	content 	  分享内容（新浪、短信、微信、QQ、拷贝）
 *	@param 	SMS 	      手机短信内容文本
 *	@param 	image 	      分享图片（新浪、微信、QQ、拷贝）
 *	@param 	url 	      链接（QQ空间、微信、QQ）
 *  @param  mobClick      友盟点击事件统计
 *  @param  markSF        用户标记是否在url中添加sf参数
 *	@param 	shareResult   分享结果
 */
- (void)initQrcodeShareViewWithTitle:(NSString *)title
                             content:(NSString *)content
                                 SMS:(NSString *)message
                               image:(UIImage *)image
                                 url:(NSString *)url
                            mobClick:(NSString *)mobClick
                              markSF:(BOOL)isMarkSF
                         shareResult:(ZWShareFinishBlock)shareResult;

/**
 *	显示普通的分享视图
 *	@param 	title 	      标题（QQ空间、微信、QQ）
 *	@param 	content 	  分享内容（新浪、短信、微信、QQ、拷贝）
 *	@param 	SMS           手机短信内容文本
 *	@param 	image 	      分享图片（新浪、微信、QQ、拷贝）
 *	@param 	url 	      链接（QQ空间、微信、QQ）
 *  @param  mobClick      友盟点击事件统计
 *  @param  markSF        用户标记是否在url中添加sf参数
 *	@param 	shareResult   分享结果
 */
- (void)initNormalShareViewWithTitle:(NSString *)title
                              content:(NSString *)content
                                  SMS:(NSString *)message
                                image:(UIImage *)image
                                  url:(NSString *)url
                            mobClick:(NSString *)mobClick
                              markSF:(BOOL)isMarkSF
                          shareResult:(ZWShareFinishBlock)shareResult;

/**
 *	显示带有加入收藏功能的的分享视图（潜入调用分享接口功能）
 *	@param 	title 	                  标题（QQ空间、微信、QQ）
 *	@param 	content 	              分享内容（新浪、短信、微信、QQ、拷贝）
 *	@param 	image 	                  分享图片（新浪、微信、QQ、拷贝）
 *	@param 	url 	                  链接（QQ空间、微信、QQ）
 *  @param  mobClick                  友盟点击事件统计
 *  @param  markSF                    用户标记是否在url中添加sf参数
 *	@param 	requestParametersModel 	  分享接口参数模型
 *	@param 	shareResult               分享结果
 *	@param 	requestResult             调用分享接口结果反馈
 */
- (void)initCollectShareViewWithTitle:(NSString *)title
                              content:(NSString *)content
                                image:(UIImage *)image
                                  url:(NSString *)url
                             mobClick:(NSString *)mobClick
                               markSF:(BOOL)isMarkSF
               requestParametersModel:(ZWShareParametersModel *)model
                          shareResult:(ZWShareFinishBlock)shareResult
                        requestResult:(ZWShareRequestResultBlock)requestResult;


/**
 *	显示普通的分享视图（潜入调用分享接口功能）
 *	@param 	title 	                  标题（QQ空间、微信、QQ）
 *	@param 	content 	              分享内容（新浪、短信、微信、QQ、拷贝）
 *	@param 	SMS 	                  手机短信内容文本
 *	@param 	image 	                  分享图片（新浪、微信、QQ、拷贝）
 *	@param 	url 	                  链接（QQ空间、微信、QQ）
 *  @param  mobClick                  友盟点击事件统计
 *  @param  markSF                    用户标记是否在url中添加sf参数
 *	@param 	requestParametersModel 	  分享接口参数模型
 *	@param 	shareResult               分享结果
 *	@param 	requestResult             调用分享接口结果反馈
 */
- (void)initNormalShareViewWithTitle:(NSString *)title
                             content:(NSString *)content
                                 SMS:(NSString *)message
                               image:(UIImage *)image
                                 url:(NSString *)url
                            mobClick:(NSString *)mobClick
                              markSF:(BOOL)isMarkSF
              requestParametersModel:(ZWShareParametersModel *)model
                         shareResult:(ZWShareFinishBlock)shareResult
                       requestResult:(ZWShareRequestResultBlock)requestResult;

/**
 *  新浪微博快捷分享
 *	@param 	title 	                  标题（QQ空间、微信、QQ）
 *	@param 	content 	              分享内容（新浪、短信、微信、QQ、拷贝）
 *	@param 	image 	                  分享图片（新浪、微信、QQ、拷贝）
 *	@param 	url 	                  链接（QQ空间、微信、QQ）
 *	@param 	requestParametersModel 	  分享接口参数模型
 *	@param 	shareResult               分享结果
 *	@param 	requestResult             调用分享接口结果反馈
 */
+ (void)shareSinaWithTitle:(NSString *)title
                   content:(NSString *)content
                     image:(UIImage *)image
                       url:(NSString *)url
    requestParametersModel:(ZWShareParametersModel *)model
               shareResult:(ZWShareFinishBlock)shareResult
             requestResult:(ZWShareRequestResultBlock)requestResult;

/**
 *  是否授权新浪微博
 */
+ (BOOL)hasAuthorizedWeibo;

/**
 *  取消授权新浪微博
 */
+ (void)cancelAuthorizedWeibo;

/**
 *  授权新浪微博
 */
+ (void)authorizedWeiBo:(ZWWeiboAuthorizedResultBlock)result;
/**
 *
 *  关闭分享界面
 */
+ (void)disMissShareView;

@end
