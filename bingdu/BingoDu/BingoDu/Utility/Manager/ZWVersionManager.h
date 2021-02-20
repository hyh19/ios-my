#import <Foundation/Foundation.h>

/** 版本检测类型 */
typedef NS_ENUM(NSUInteger, ZWVersionCheckType) {
    
    /** 自动检测 */
    kVersionCheckTypeAutomatic = 0,
    
    /** 手工检测 */
    kVersionCheckTypeMannual = 1,
    
    /** 从不检测 */
    kVersionCheckTypeIgnore = 2
};

/** 更新提示类型 */
typedef NS_ENUM(NSUInteger, ZWVersionReminderType) {
    
    /** 弹窗不强制 */
    kVersionReminderTypeAlertAndNonForced = 0,
    
    /** 弹窗且强制 */
    kVersionReminderTypeAlertAndForced = 1,
    
    /** 不弹窗不强制 */
    kVersionReminderTypeNoAlertAndNonForced = 2
};

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 版本检测管理器
 */
@interface ZWVersionManager : NSObject

/**
 *  版本检测
 *
 *  @param type   版本检测类型
 *  @param finish 版本检测完成后的回调函数
 */
+ (void)checkVersionWithType:(ZWVersionCheckType)type
                 finishBlock:(void (^)(BOOL hasNewVersion, id versionData))finish;

/** 是否有新版本，当前版本与保存在本地配置文件的最新版本号比较 */
+ (BOOL)hasNewVersion;

@end
