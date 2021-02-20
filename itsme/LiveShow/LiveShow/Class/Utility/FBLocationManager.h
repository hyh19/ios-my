#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  @author 黄玉辉
 *  @ingroup utility
 *  @brief 定位服务管理器，主要用于获取经纬度和省份、城市
 */
@interface FBLocationManager : NSObject

/**
 *  更新当前地理位置
 *  @param success 成功后的回调函数
 *  @param failure 失败后的回调函数
 */
+ (void)updateLocationWithSuccess:(void(^)())success failure:(void(^)())failure;

/** 定位服务是否可用 */
+ (BOOL)locationAvailable;

/** 定位服务不可用则提示设置 */
+ (BOOL)alertToLocationSetting;

/** 获取省份名称 */
+ (NSString *)province;

/** 获取城市名称 */
+ (NSString *)city;

/** 获取区名称 */
+ (NSString *)region;

/** 获取经度 */
+ (NSString *)longitude;

/** 获取纬度 */
+ (NSString *)latitude;

@end





