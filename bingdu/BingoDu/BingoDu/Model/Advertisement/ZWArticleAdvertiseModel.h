#import <Foundation/Foundation.h>
@class ZWNewsModel;

/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 广告id
 */
@interface ZWArticleAdvertiseModel : NSObject

/**
 *  广告图片加载已完成
 */
@property (nonatomic,assign)BOOL adversizeImageLoadFinish;

/**
 *  广告id
 */
@property (nonatomic,strong)NSString *adversizeID;

/**
 *  广告位id
 */
@property (nonatomic,strong)NSString *adversizePositionID;

/**
 *  频道id
 */
@property (nonatomic,strong)NSString *adversizeChannerID;

/**
 *  广告类型
 */
@property (nonatomic,strong)NSString *adversizeType;

/**
 *  广告标题
 */
@property (nonatomic,strong)NSString *adversizeTitle;

/**
 *  广告图片的url
 */
@property (nonatomic,strong)NSString *adversizeImgUrl;

/**
 *  广告详情的url
 */
@property (nonatomic,strong)NSString *adversizeDetailUrl;

/**
 *  广告跳转类型
 */
@property (nonatomic,assign)RedirectType redirectType;
/**
 *  跳转目标ID
 */
@property (nonatomic,strong)NSString *redirectTargetId;

/**
 *  是否是网盟广告
 */
@property (nonatomic,assign)BOOL  isAdAllianceAd;

/**
 *  联盟广告url
 */
@property (nonatomic,strong)NSString *unionAdvertiseUrl;
/**
 *  联盟广告展现日志的url
 */
@property (nonatomic,strong)NSArray *impressionUrl;
/**
 *  联盟广告点击监控url
 */
@property (nonatomic,strong)NSArray *clickMonitorUrl;
/**
 *  创建本对象
 */
+(instancetype)ariticleModelBy:(NSDictionary *)dic;

/**
 *  创建本对象(此方法适用于新闻列表广告的转换时使用)
 */
+(instancetype)ariticleModelByNewsModel:(ZWNewsModel *)newsModel;

@end
