#ifndef Constant_UserDefaults_h
#define Constant_UserDefaults_h

/** 是否首次推送授权 */
#define kUserDefaultsShowAPNSAuthor @"UserDefaultsShowAPNSAuthor"

/** 是否禁用美颜 */
#define kUserDefaultsDisableBeauty  @"UserDefaultsDisableBeauty"

/** 是否满足评分向导条件 */
#define kUserDefaultsEnableScoringGuide  @"UserDefaultsEnableScoringGuide"

/** 开播次数 */
#define kUserDefaultsOpenLiveCount  @"UserDefaultsOpenLiveCount"

/** 是否正常退出开播 */
#define kUserDefaultsNormalExitOpenLive  @"UserDefaultsNormalExitOpenLive"

/** 是否已经出现评分对话框 */
#define kUserDefaultsNormalExistedGuide  @"UserDefaultsNormalExistedGuide"

/** 邮箱账号 */
#define kUserDefaultsEmail  @"EmailLogin"

/** 回放/关注/粉丝 数量数组 */
#define kUserDefaultsReplayFollowFansNumber @"UserDefaultsReplayFollowFansNumber"

/** 用户是否观看直播 */
#define kUserDefaultsWatch  @"UserDefaultsWatch"

/** 观众是否关注过主播 */
#define kUserDefaultsEnableFollow @"UserDefaultsEnableFollow"

/** 是否出现推荐主播列表 */
#define kUserDefaultsEnableRecommend @"UserDefaultsEnableRecommend"

/** 是否已经过了出现推荐主播列表 */
#define kUserDefaultsEnableHasRecommend @"UserDefaultsEnableHasRecommend"

/** 开播是否Facebook分享 */
#define kUserDefaultsAutoShareToFacebook  @"UserDefaultsAutoShareToFacebook"

/** 开播是否Twitter分享 */
#define kUserDefaultsAutoShareToTwitter  @"UserDefaultsAutoShareToTwitter"

/** 是否高清开播 */
#define kUserDefaultsHighQualityOpenLive  @"UserDefaultsHighQualityOpenLive"

/** 最近一次检测更新的时间 */
#define kUserDefaultsUpdateCheckingDate  @"UserDefaultsUpdateCheckingDate"

///-----------------------------------------------------------------------------
/// Payment
///-----------------------------------------------------------------------------
#pragma mark - Payment -
// 越南版
#if TARGET_VERSION_VIETNAM
    /** 点卡的开启状态 */
    #define kUserDefaultsStoreVCardStatus  @"UserDefaultsStoreVCardStatus"
#endif

// 泰国版和越南版
#if TARGET_VERSION_THAILAND || TARGET_VERSION_VIETNAM
    /** 提现功能的开关状态 */
    #define kUserDefaultsWithdrawStatus  @"UserDefaultsWithdrawStatus"
#endif

///-----------------------------------------------------------------------------
/// 分组整理，方便查找！
///-----------------------------------------------------------------------------
#pragma mark - 分组整理，方便查找！ -

/** hashTag开播/搜索标签 */
#define kUserDefaultsHashTags  @"UserDefaultsHashTags"

/** 榜单按钮显示状态 */
#define kUserDefaultsRankListButtonStatus  @"UserDefaultsRankListButtonStatus"

/** app安装时间 */
#define kUserDefaultsInstallDate @"UserDefaultsInstallDate"

/** app升级时间 */
#define kUserDefaultsUpdateDate @"UserDefaultsUpdateDate"

/** 第一次登陆 */
#define kUserDefaultsUserFirstLogin @"UserDefaultsUserFirstLogin"

/** 版本build号 */
#define kUserDefaultsVersion @"UserDefaultsVersion"

/** 登录时间戳 */
#define kUserDefaultsLoginTimeStamp @"UserDefaultsLoginTimeStamp"

/** 不再提示apns */
#define kUserDefaultsNotRemindApnsAlert @"UserDefaultsNotRemindApnsAlert"

/** apns稍后提示时间戳 */
#define kUserDefaultsApnsRemindLaterTimeStamp @"UserDefaultsApnsRemindLaterTimeStamp"

///-----------------------------------------------------------------------------
/// 主页
///-----------------------------------------------------------------------------
#pragma mark - 主页 -
/** 在主页直播列表屏蔽的用户列表 */
#define kUserDefaultsBlockUsers @"UserDefaultsBlockUsers"

/** 开播用户的uids 用来判断是否显示修改头像 */
#define kUserDefaultsEditPortraitUids @"UserDefaultsEditPortraitUids"

///-----------------------------------------------------------------------------
/// 最新tag和全球tags
///-----------------------------------------------------------------------------
#pragma mark - 最新tag和全球tags -
/** 用户是否从最新tag列表进入直播（或回放） */
#define kUserDefaultsFormNewTag @"UserDefaultsFormNewTag"

/** 用户是否从全球tag列表进入直播（或回放） */
#define kUserDefaultsFormAllTags @"UserDefaultsFormAllTags"

/** 用户是否解除了绑定twitter */
#define kUserDefaultsUnbindTwitter @"kUserDefaultsUnbindTwitter"

/** 用户开播时是否提示设置定位 */
#define kUserDefaultsAlertLocationWhenOpenLive @"kUserDefaultsAlertLocationWhenOpenLive"

/** 用户点附近提示设置定位时的时间 */
#define kUserDefaultsTicksOnAlertLocationWhenNearby @"kUserDefaultsTicksOnAlertLocationWhenNearby"

#endif
