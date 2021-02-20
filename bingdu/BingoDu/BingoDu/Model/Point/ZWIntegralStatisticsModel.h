#import <Foundation/Foundation.h>
#import "ZWIntegralRuleModel.h"
#import "ZWPointNetworkManager.h"

typedef enum {
    /**
     登陆
     */
    IntegralLoginFrequency = 0,
    /**
     分享阅读
     */
    IntegralShareRead = 1,
    /**
     推广注册
     */
    IntegralRegistration = 2,
    /**
     分享带来阅读
     */
    IntegralShareByRead = 3,
    /**
     评论点赞
     */
    IntegralReviewLike = 4,
    /**
     评论被点赞
     */
    IntegralReviewCoverLike = 5,
    /**
     评论新闻
     */
    IntegralReview = 6,
    /**
     阅读新闻
     */
    IntegralReadNews = 7,
    /**
     查看广告
     */
    IntegralLookAdvertising = 8,
    /**
     提现分享
     */
    IntegralShareExtract = 9,
    /**
     兑换分享
     */
    IntegralShareConvert = 10,
    /**
     绑定
     */
    IntegralOtherIntegral = 11,
    /**
     活动
     */
    IntegralExerciseIntegral = 12,
    /**
     签到
     */
    IntegralUserSignIntegral = 13
}ZWIntegralType;

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 积分详情model
 */
@interface ZWIntegralStatisticsModel : NSObject<NSCoding>
{
    NSNumber *loginFrequency;
    NSNumber *registration;
    NSNumber *shareByRead;
    NSNumber *shareRead;
    NSNumber *reviewLike;
    NSNumber *reviewCoverLike;
    NSNumber *review;
    NSNumber *readNews;
    NSNumber *lookAdvertising;
    NSNumber *shareExtract;
    NSNumber *shareConvert;
    NSNumber *otherIntegral;
    NSNumber *exerciseIntegral;
    NSNumber *userSignIntegral;
}

/**
 积分接口 Manager
 */
@property (nonatomic, strong)ZWPointNetworkManager *integralManager;

/** 登陆 */
@property (nonatomic,strong) NSNumber *loginFrequency;

/** 推广注册 */
@property (nonatomic,strong) NSNumber *registration;

/** 分享阅读 */
@property (nonatomic,strong) NSNumber *shareRead;

/** 评论点赞 */
@property (nonatomic,strong) NSNumber *reviewLike;

/** 评论被点赞 */
@property (nonatomic,strong) NSNumber *reviewCoverLike;

/** 评论 */
@property (nonatomic,strong) NSNumber *review;

/** 阅读资讯 */
@property (nonatomic,strong) NSNumber *readNews;

/** 查看广告 */
@property (nonatomic,strong) NSNumber *lookAdvertising;

/** 提现分享 */
@property (nonatomic,strong) NSNumber *shareExtract;

/** 兑换分享 */
@property (nonatomic,strong) NSNumber *shareConvert;

/** 存储日期 */
@property (nonatomic,strong) NSString *curDataTime;

/** 分享带来阅读 */
@property (nonatomic,strong) NSNumber *shareByRead;

/** 绑定积分 */
@property (nonatomic,strong) NSNumber *otherIntegral;

/** 活动积分 */
@property (nonatomic,strong) NSNumber *exerciseIntegral;

/**签到*/
@property (nonatomic, strong)NSNumber *userSignIntegral;

/** 积分model单例 */
+ (instancetype)sharedInstance;

/** 设置完新参数后 保存数据 */
+ (void)saveCustomObject:(ZWIntegralStatisticsModel *)obj;

/** 加载本地数据 */
+ (ZWIntegralStatisticsModel *)loadCustomObjectWithKey:(NSString *)key;

/** 当前本地积分总数 */
+(float)sumIntegrationBy:(ZWIntegralStatisticsModel*)obj;

/** 覆盖本地积分数据 */
+ (void )arrangeData:(NSDictionary *)result;

/** 初始化积分 */
+(void)initNewData:(ZWIntegralStatisticsModel *)obj;

/** 存储各项积分 */
+(ZWIntegralRuleModel *)saveIntergralItemData:(ZWIntegralType)type;

/** 登录后上传积分方法,并返回一个状态，，YES表示成功上传并同步积分，NO则失败 */
+ (void)upoadLocalIntegralWithFinish:(void (^)(BOOL success))finish;

/** 同步积分，NO则失败 */
+ (void)synchronizationIntegralWithFinish:(void (^)(BOOL success))finish;

/** 获取本地积分规则 */
+(NSMutableArray *)loadDefaultIntegralRule;

/** 初始化积分（不包含系统给予积分与活动积分） */
+(void)initCurNewData:(ZWIntegralStatisticsModel *)obj;

/** 上传积分数组 */
+(NSMutableArray *)sumArray;

@end
