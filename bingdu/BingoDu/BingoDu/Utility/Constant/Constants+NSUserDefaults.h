#ifndef BingoDu_Constants_NSUserDefaults_h
#define BingoDu_Constants_NSUserDefaults_h

// 今日已获积分、昨日收入、今日广告分成、昨日广告分成
#define kUserDefaultsIncomeData @"kUserDefaultsIncomeData"

// 主界面积分菜单数据
#define kUserDefaultsPointData @"kUserDefaultsPointData"

// 最近一次上传通讯录手机号码的时间
#define kUserDefaultsLastUploadMobileNumbersTime @"kUserDefaultsLastUploadMobileNumbersTime"

// 启动广告缓存读取的key
#define kLaunchAdvertiseKey @"launchAdvertiseKey"

// 加载启动引导页
#define kDidLoadLaunchGuidance @"didLoadLaunchGuidance"

#define kLoginPhoneNumber  @"loginPhoneNumber"

//用户信息
#define IntegralTotalIncome @"totalIncome"

//弹幕开关状态
#define kBarrageStatus @"barrageStatus"

/** 存储已读的24小时热读新闻key */
#define kNotificationMarkReadHot24Read  @"kNotificationMarkReadHot24Read"

/**
 *  存储最新回复的数值
 */
#define NEWEST_RELPLY_KEY  @"newestReplyKey"
/**
 *  存储并友是否有新的回复
 */
#define BINGYOU_HAVA_NEWREPLY  @"bingyouHavaNewPlay"

#define BELAUD_NEWS @"belaudNews"

#define kEnableForPush  @"enableForPush"

#define HOBBY_NEWS @"hobbyNews"

#define USERINFO @"userInfo"

#define kLatestVersion @"LatestVersion"

#define MYREDPOINT @"myRedPoint"

#define MONEYREDPOINT @"moneyRedPoint"

#define LOCALCHANNEL @"localChannel"

/** 已阅读新闻数量 */
#define kUserDefaultsReadNewsNum @"UserDefaultsReadNewsNum"

#pragma mark - Review -
/** 最近一次提醒用户给好评的时间 */
#define kLatestReviewTime @"LatestReviewTime"

/** 不再提醒好评 */
#define kNoReviewAlertAgain @"NoReviewAlertAgain"

/** 用户阅读过的新闻数 */
#define kReadNewsCount @"ReadNewsCount"

/** 用户收藏的新闻数 */
#define kFavoriteNewsCount @"favoriteNewsCount"

/** 频道版本号 */
#define kChannelVersion @"ChannelVersion"

/** 进入后台的时间 */
#define kEnterBackgroundTime @"kEnterBackgroundTime"

///-----------------------------------------------------------------------------
/// @name 新闻搜索
///-----------------------------------------------------------------------------
#pragma mark - 新闻搜索 -
/** 并友热搜 */
#define kSearchHotWord @"SearchHotWord"

/** 搜索历史 */
#define kSearchHistory @"SearchHistory"

///-----------------------------------------------------------------------------
/// @name 房产频道都惠来
///-----------------------------------------------------------------------------
#pragma mark - 房产频道都惠来 -

/** 房产频道都惠来选中的城市 */
#define kRealEstateSelectedCity @"RealEstateSelectedCity"

/** 房产频道都惠来城市数据 */
#define kRealEstateCityData @"RealEstateCityData"

/**图评开关*/
#define kEnableForImageComment  @"enableForImageComment"

///-----------------------------------------------------------------------------
/// @name 个人中心
///-----------------------------------------------------------------------------
#pragma mark - 个人中心 -

/** 填写邀请码提示 */
#define kUserDefaultsInvitationCodeAlert @"UserDefaultsInvitationCodeAlert"

///-----------------------------------------------------------------------------
/// @name 生活方式
///-----------------------------------------------------------------------------
#pragma mark - 生活方式 -

/** 精选文章列表请求成功后服务端返回的下次请求要传入的参数 */
#define kUserDefaultsFeaturedArticlesRequestParam @"UserDefaultsFeaturedArticlesRequestParam"

/** 最后一次清除文章缓存的时间 */
#define kUserDefaultsLatestDeleteCache @"UserDefaultsLatestDeleteCache"

/** 用户是否已经选择了感兴趣的生活方式 */
#define kUserDefaultsSelectLifeStyleCompleted @"UserDefaultsSelectLifeStyleCompleted"

/** 默认打开的Tab */
#define kUserDefaultsSelectedTab @"UserDefaultsSelectedTab"

#endif
