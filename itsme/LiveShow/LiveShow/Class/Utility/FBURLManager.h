#import <Foundation/Foundation.h>

/**
 *  @since 2.0.0
 *  @brief 服务器地址类型
 */
typedef NS_ENUM(NSUInteger, FBServerType) {
    
    /** 正式地址 */
    kServerTypeProduction,
    
    /** 测试地址 */
    kServerTypeDevelopment
};

/**
 *  @author 黄玉辉
 *  @brief 网络请求接口管理器
 */
@interface FBURLManager : NSObject

/**
 *  @since 2.0.0
 *  @brief 网络环境
 */
@property (nonatomic) FBServerType serverType;

/** 单例 */
+ (instancetype)sharedInstance;

/**
 *  @since 2.0.0
 *  @brief 服务器地址
 */
+ (NSString *)baseURL;

/**
 *  @since 2.0.0
 *  @brief 获取所有网络请求接口的地址
 */
+ (NSString *)URLForAllNetworkAPI;

/** 全部URL数据 */
+ (NSDictionary *)URLData;

/** 请求网络接口数据 */
- (void)requestURLData;

/** 获取网络请求接口 */
- (NSString *)URLStringWithKey:(NSString *)key;

/** 获取网络请求接口的Key */
- (NSString *)keyFromURLString:(NSString *)URLString;

/** 获取直播流的地址 */
- (NSString *)streamURLWithParam:(NSString *)param;

@end
