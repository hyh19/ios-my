#ifndef Constant_Version_h
#define Constant_Version_h

// APPS_FLYER_DEV_KEY       AppsFlyer的开发者Key
// ACT_CONVERSION_ID        Google AdWords的转化ID
// ACT_CONVERSION_LABEL     Google AdWords的转化Label

// 国际版
#if TARGET_VERSION_GLOBAL
    #define APPS_FLYER_DEV_KEY      @"nYQeXjBTuBegTQqc2BLj8n"
    #define ACT_CONVERSION_ID       @"878275836"
    #define ACT_CONVERSION_LABEL    @"Rh-pCKKJi2kQ_NnlogM"

// 泰国版
#elif TARGET_VERSION_THAILAND
    #define APPS_FLYER_DEV_KEY      @"nYQeXjBTuBegTQqc2BLj8n"
    #define ACT_CONVERSION_ID       @"886161791"
    #define ACT_CONVERSION_LABEL    @"_qAyCPmGwWYQ_4LHpgM"

// 越南版
#elif TARGET_VERSION_VIETNAM
    #define APPS_FLYER_DEV_KEY      @"nYQeXjBTuBegTQqc2BLj8n"
    #define ACT_CONVERSION_ID       @"878275836"
    #define ACT_CONVERSION_LABEL    @"oolOCL-X7mgQ_NnlogM"

// 日本版
#elif TARGET_VERSION_JAPAN
    #define APPS_FLYER_DEV_KEY      @"nYQeXjBTuBegTQqc2BLj8n"
    #define ACT_CONVERSION_ID       @"878275836"
    #define ACT_CONVERSION_LABEL    @"WExeCJa-imkQ_NnlogM"

// 其他版本（包括企业版和其他）
#else
    #define APPS_FLYER_DEV_KEY      @"NULL"
    #define ACT_CONVERSION_ID       @"NULL"
    #define ACT_CONVERSION_LABEL    @"NULL"

#endif

///-----------------------------------------------------------------------------
/// 不同版本的Logo
///-----------------------------------------------------------------------------
#pragma mark - 不同版本的Logo -
#if TARGET_VERSION_THAILAND
    #define kLogoFailureView @"pub_icon_logo_failure_th" // 错误页面的Logo
    #define kLogoLiveCover @"pub_icon_livecover_th" // 直播列表的默认封面
    #define kLogoDefaultAvatar @"pub_icon_default_avatar_th" // 默认头像
    #define kLogoLogin @"login_icon_logo_th" // 登录界面的Logo
    #define kLogoAboutUs @"aboutus_icon_logo_th" // 关于界面的Logo
    #define kLogoBanner @"pub_icon_banner_th" // banner广告的默认图片

#elif TARGET_VERSION_VIETNAM
    #define kLogoFailureView @"pub_icon_logo_failure_th" // 错误页面的Logo
    #define kLogoLiveCover @"pub_icon_livecover_th" // 直播列表的默认封面
    #define kLogoDefaultAvatar @"pub_icon_default_avatar_th" // 默认头像
    #define kLogoLogin @"login_icon_logo_th" // 登录界面的Logo
    #define kLogoAboutUs @"aboutus_icon_logo_th" // 关于界面的Logo
    #define kLogoBanner @"pub_icon_banner_th" // banner广告的默认图片

#elif TARGET_VERSION_JAPAN
    #define kLogoFailureView @"pub_icon_logo_failure_jp" // 错误页面的Logo
    #define kLogoLiveCover @"pub_icon_livecover_jp" // 直播列表的默认封面
    #define kLogoDefaultAvatar @"pub_icon_default_avatar_jp" // 默认头像
    #define kLogoLogin @"login_icon_logo_jp" // 登录界面的Logo
    #define kLogoAboutUs @"aboutus_icon_logo_jp" // 关于界面的Logo
    #define kLogoBanner @"pub_icon_banner_jp" // banner广告的默认图片

#else
    #define kLogoFailureView @"pub_icon_logo_failure_global" // 错误页面的Logo
    #define kLogoLiveCover @"pub_icon_livecover_big_global" // 直播列表的默认封面
    #define kLogoDefaultAvatar @"pub_icon_default_avatar_global" // 默认头像
    #define kLogoLogin @"login_icon_logo_global" // 登录界面的Logo
    #define kLogoAboutUs @"about_icon_logo" // 关于界面的Logo
    #define kLogoBanner @"pub_icon_banner_global" // banner广告的默认图片
#endif

///-----------------------------------------------------------------------------
/// 不同版本下某些功能的可用状态
///-----------------------------------------------------------------------------
#pragma mark - 不同版本下某些功能的可用状态 -
// 国际版
#if TARGET_VERSION_GLOBAL
    /** 是否展示钻石数 */
    static BOOL DIAMOND_NUM_ENABLED = YES;

    /** 是否保持钻石数的变化与礼物动画一致，即看到礼物动画来才变更钻石数 */
    static BOOL DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED = YES;

// 泰国版
#elif TARGET_VERSION_THAILAND
    static BOOL DIAMOND_NUM_ENABLED = YES;

    static BOOL DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED = YES;

// 越南版 
#elif TARGET_VERSION_VIETNAM
    static BOOL DIAMOND_NUM_ENABLED = YES;

    static BOOL DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED = YES;

// 日本版
#elif TARGET_VERSION_JAPAN
    static BOOL DIAMOND_NUM_ENABLED = YES;

    static BOOL DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED = YES;

// 后备版
#elif TARGET_VERSION_BACKUP
    static BOOL DIAMOND_NUM_ENABLED = YES;

    static BOOL DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED = YES;

// 其他版本（包括企业版和其他）
#else
    static BOOL DIAMOND_NUM_ENABLED = YES;

    static BOOL DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED = YES;

#endif


#endif /* Constant_Version_h */
