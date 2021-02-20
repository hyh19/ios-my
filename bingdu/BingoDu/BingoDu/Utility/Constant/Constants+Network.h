#ifndef BingoDu_Constants_Network_h
#define BingoDu_Constants_Network_h

#pragma mark - Network environment
// 服务器环境，0-生产环境 1-UAT环境 2-测试环境 3-开发环境
#ifndef SERVER_TYPE
#define SERVER_TYPE 0
#endif

// 生产环境
#if SERVER_TYPE == 0
#define BASE_URL                                @"http://api.bingodu.cn"
#define BASE_URL_HTTPS                          @"https://api.bingodu.cn"
#define POINT_RULE_URL                          @"http://news.bingodu.com/static/rule.html"
#define ENVIRONMENT_NAME                        @"Production"
// UAT环境
#elif SERVER_TYPE == 1
#define BASE_URL                                @"http://apip.bingodu.net"
#define BASE_URL_HTTPS                          @"https://apip.bingodu.net"
#define POINT_RULE_URL                          @"http://192.168.1.221:82/static/rule.html"
#define ENVIRONMENT_NAME                        @"UAT"
// 测试环境
#elif SERVER_TYPE == 2
#define BASE_URL                                @"http://apit.bingodu.net"
#define BASE_URL_HTTPS                          @"https://apit.bingodu.net"
#define POINT_RULE_URL                          @"http://192.168.1.221:82/static/rule.html"
#define ENVIRONMENT_NAME                        @"Test"
// 开发环境
#elif SERVER_TYPE == 3
#define BASE_URL                                @"http://192.168.1.221:8081/smartnews"
#define BASE_URL_HTTPS                          @"https://192.168.1.221/smartnews"
#define POINT_RULE_URL                          @"http://192.168.1.221:82/static/rule.html"
#define ENVIRONMENT_NAME                        @"Development"
#endif

#pragma mark - Network API

/** 服务器版本号 */
#define SERVER_VERSION @"1.54"

#define kRequestPathWithdrawWays                @"/api/withdraw/get"
#define kRequestPathWithdrawMoney               @"/api/withdraw/create1_4"
#define kRequestPathCommodityExchange           @"/api/goods/exchGoods"
#define kRequestPathBindChangeCmsCode           @"/api/sendCms"
#define kRequestPathUpdatePhone                 @"/api/register/updatePhone"
#define kRequestPathVerifyBindCode              @"/api/register/verifyCmsCaptcha"
#define kRequestPathUserLottery                 @"/api/activity/userInfo"
#define kRequestPathIntegralRule                @"/api/point/pointrule"
//#define kRequestPathTodayStartUp                @"/api/user/dailySign"
#define kRequestPathSubmitPrizeInfo             @"/api/activity/submitinfo"
#define kRequestPathUserHighOpinionInfo         @"/api/activity/submitStoreInfo"
#define kRequestPathHighOpinionStatus           @"/api/activity/list"
#define kRequestPathAddNewsShareAction          @"/api/user/addNewsShareAction"
#define kRequestPathSynUserIntegral             @"/api/point/syncpoint"
#define kRequestPathNewsImgsTitle               @"/api/news/getNews"
#define kRequestPathGoodsNotice                 @"/api/goods/goodsNotice"
#define kRequestPathWeather                     @"/api/common/weather"
#define kRequestPathSaveUserIntegral            @"/api/point/savepoint"
#define kRequestPathUserinfoRecord              @"/api/point/pointinfo"
#define kRequestPathMoneyExtractRecord          @"/api/point/withdrawrecord"
#define kRequestPathChannelList                 @"/api/channel/list"
#define kRequestPathUploadMyChannelList         @"/api/channel/my_list"
#define kRequestPathNewsList                    @"/api/news/listv15"
#define kRequestPathNewsTalkList                @"/api/comment/hotcmtv15"
#define kRequestPathNewsCommentList             @"/api/comment/listv15"
#define kRequestPathNewsHotReadList             @"/api/news/hotRead"
#define kRequestPathUploadMyNewsTalkNew         @"/api/comment/cmtNews"
#define kRequestPathUploadLikeNews              @"/api/news/interest"
#define kRequestPathUploadLikeTalk              @"/api/comment/praise"
#define kRequestPathUploadReportTalk            @"/api/comment/report"
#define kRequestPathUploadBelaudNews            @"/api/news/praise"
#define kRequestPathLoginByThirdparty           @"/api/register/login"
#define kRequestPathLoginByPhone                @"/api/register/loginByPhone"
#define kRequestPathLoginVerify                 @"/api/register/loginVerify"
#define kRequestPathBindAccount                 @"/api/register/bindAccount"
#define kRequestPathRegister                    @"/api/register/registerByPhone"
#define kRequestPathResetPassword               @"/api/register/resetPassword"
#define kRequestPathSendCaptcha                 @"/api/register/sendCaptcha"
#define kRequestPathVerifyCmsCaptcha            @"/api/register/verifyCmsCaptcha"
#define kRequestPathUpdataFriends               @"/api/user/friendSync"
#define kRequestPathUploadUserInfo              @"/api/register/editAccount"
#define kRequestPathFriends                     @"/api/user/friendaction"
#define kRequestPathFriendsReply                @"/api/user/msg"
#define kRequestPathRecommendCode               @"/api/recommendCode/getRecommendCode"
#define kRequestPathAD                          @"/api/advertise/loadAdvertise"
#define kRequestPathClickAD                     @"/api/advertise/adClick"
#define kRequestPathShare                       @"/api/share15"
#define kRequestPathCmsCode                     @"/api/sendCmsCaptcha"
#define kRequestPathLocalChannel                @"/api/channel/local_channel"
#define kRequestPathBankList                    @"/api/bankInfo/list"
#define kRequestPathDeleteUserBank              @"/api/bankInfo/deleteUserBanks"
#define kRequestPathUploadMobileNumbers         @"/api/addressBook/fullSync"
#define kRequestPathLoadBingFriends             @"/api/addressBook/queryFriendsByNumbers"
#define kRequestPathArticleAdvertise            @"/api/advertise/display"
#define kRequestPathLotteryRecord               @"/api/lottery/history"
#define kRequestPathPrizeList                   @"/api/lottery/list"
#define kRequestPathLotteryRecordDetail         @"/api/lottery/detail"
#define kRequestPathPrizeDetail                 @"/api/lottery/item"
#define kRequestPathPostUserInfo                @"/api/lottery/submit"
#define kRequestPathGoodsExchangeRecord         @"/api/goods/userExcListV1_4"
#define kRequestPathGoodsExchangeRecordDetail   @"/api/goods/userExcDetail15"
#define kRequestPathWinnerList                  @"/api/lottery/win"
#define kRequestPathReadIntegral                @"/api/news/readnews"
#define kRequestPathEntityGoodsExch             @"/api/goods/exchEntityGoods15"
#define kRequestPathGuide                       @"/api/virtual/noviceGuide"
#define kRequestPathClosePushNews               @"/api/virtual/closePushNews"
#define kRequestPathInvite                      @"/api/virtual/recommendDownload"
#define kRequestPathUseChannel                  @"/api/virtual/useChannel"
#define kRequestPathPushOpen                    @"/api/push/count/open"
#define kRequestPathSign                        @"/api/user/sign"

/** 活动信息请求接口 */
#define kRequestPathActivities                  @"/api/activity/listAll"

/** 收入界面九宫格菜单请求接口 */
#define kRequestPathMenus                       @"/api/menu/getMenuConfig"

/** 标记兑换记录界面相应页面为已读状态 */
#define kRequestPathDeleteTipsNumber            @"/api/menu/deleteTipNumber"

/** 24小时热读 */
#define kRequestPathhot24Read                   @"/api/news/hot24Read"

/** 商品详情广告 */
#define kRequestPathGoodsAD                     @"/api/advertise/goodsAd"

///-----------------------------------------------------------------------------
/// @name 消息提醒
///-----------------------------------------------------------------------------
#pragma mark - 消息提醒 -
/** 检测主界面头像的消息提醒（红点） */
#define kRequestPathCheckMessageReminder        @"/api/dynamic/msgRemind"

/** 检测版本信息 */
#define kRequestPathCheckVersion                @"/api/common/version"

///-----------------------------------------------------------------------------
/// @name 用户行为统计
///-----------------------------------------------------------------------------
#pragma mark - 用户行为统计 -
/** 用户下拉到热读时调用 */
#define kRequestPathIsGetHotRead            @"/api/virtual/endRead"

/** 用户下拉到热议时调用 */
#define kRequestPathIsGetHotTalk            @"/api/virtual/commentRead"

/** 用户下拉到热读时调用 */
#define kRequestPathGetLifeNewsReadPercent           @"/api/lifeNews/endRead"

///-----------------------------------------------------------------------------
/// @name 商品兑换
///-----------------------------------------------------------------------------
#pragma mark - 商品兑换 -
/** 可兑换商品 */
#define kRequestPathGoodList                    @"/api/goods/list15"

/** 兑换商品详情 */
#define kRequestPathGoodsDetail                 @"/api/goods/goodsDetail15"

/** 兑换商品 */
#define kRequestPathBuyRecord                   @"/api/goods/userExcList"

///-----------------------------------------------------------------------------
/// @name 新闻图评
///-----------------------------------------------------------------------------
#pragma mark - 新闻图评 -
/** 加载新闻图评 */
#define kRequestPathNewsImageComment            @"/api/picComment/load"

/** 发表新闻图评 */
#define kRequestPathNewsImageCommentUpload      @"/api/picComment/add"

/** 删除新闻图评 */
#define kRequestPathNewsImageCommentDelete      @"/api/picComment/delete"

///-----------------------------------------------------------------------------
/// @name 新闻收藏
///-----------------------------------------------------------------------------
#pragma mark - 新闻收藏 -
/** 新增新闻收藏接口 */
#define kRequestPathNewsFavoriteAdd             @"/api/news/favorite/add"

/** 新闻收藏列表接口 */
#define kRequestPathFavoriteList                @"/api/news/favorite/list"

/** 删除新闻收藏接口 */
#define kRequestPathNewsFavoriteDelete          @"/api/news/favorite/delete"

///-----------------------------------------------------------------------------
/// @name 新闻搜索
///-----------------------------------------------------------------------------
#pragma mark - 新闻搜索 -
/** 新闻搜索热词 */
#define kRequestPathNewsSearchWord              @"/api/search/hotWord"

/** 新闻搜索结果 */
#define kRequestPathNewsSearchResult            @"/api/search/list"

///-----------------------------------------------------------------------------
/// @name 余额提现
///-----------------------------------------------------------------------------
#pragma mark - 余额提现 -
/** 提现记录请求接口 */
#define kRequestPathWithdrawRecord              @"/api/withdraw/history"

/** 提现详情请求接口 */
#define kRequestPathWithdrawDetail              @"/api/withdraw/detail"

/** 银行卡地区列表接口 */
#define kRequestPathBankCardRegionList          @"/api/bankInfo/area/list"

/** 绑定银行卡接口 */
#define kRequestPathAddBankCard                 @"/api/bankInfo/addUserBank1_5"

/** 验证身份证接口 */
#define kRequestPathVerifyID                    @"/api/withdraw/bindingId"

///-----------------------------------------------------------------------------
/// @name 自媒体订阅
///-----------------------------------------------------------------------------
#pragma mark - 自媒体订阅 -
/** 获取自媒体订阅号列表 */
#define kRequestPathLoadSubscriptionList        @"/api/ugm/subscribeList"

/** 订阅自媒体 */
#define kRequestPathAddSubscription             @"/api/ugm/addSubscription"

/** 取消订阅自媒体 */
#define kRequestPathDeleteSubscription          @"/api/ugm/unsubscribe"

/** 加载订阅号新闻列表 */
#define kRequestPathLoadSubscribeNewsList       @"/api/ugm/newsList"

///-----------------------------------------------------------------------------
/// @name 生活方式
///-----------------------------------------------------------------------------
#pragma mark - 生活方式 -
/** 加载精选文章列表 */
#define kRequestPathFeaturedArticles            @"/api/lifeNews/choicenessListV201"

/** 加载生活方式频道列表 */
#define kRequestPathLoadLifestyleChannelList    @"/api/lifeNews/channel"

/** 加载生活方式分类频道列表 */
#define kRequestPathLoadTagArticlesList         @"/api/lifeNews/tagNews"

/** 加载标签新闻列表 */
#define kRequestPathLoadTagNewsList             @"/api/lifeNews/newsList"

/** 加载生活方式分类频道标签数据 */
#define kRequestPathLoadHotTags                 @"/api/lifeNews/hotTags"

/** 加载生活方式分类频道封面或广告数据 */
#define kRequestPathLoadAdvertise               @"/api/advertise/classifyCoverAd"

/** 上传选择的生活方式接口 */
#define kRequestPathSaveStyle                   @"/api/lifestyle/save"

/** 生活方式列表接口 */
#define kRequestPathLifeStyleList               @"/api/lifestyle/list"

/** 生活方式延伸阅读接口 */
#define kRequestPathLifeStyleIntroduce          @"/api/news/expandclassify/getExpandInfo"

#endif
