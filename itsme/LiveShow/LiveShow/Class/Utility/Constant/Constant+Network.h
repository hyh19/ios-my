#ifndef Constant_Network_h
#define Constant_Network_h

#pragma mark - Network API
/** 读取网络请求接口 */
#define REQUEST_URL(key) [[FBURLManager sharedInstance] URLStringWithKey:key]

/** 直播流地址 */
#define LIVESTRING_URL(param) [[FBURLManager sharedInstance] streamURLWithParam:param]

/** 登录 */
#define kRequestURLLogin REQUEST_URL(@"USER_LOGIN")

/** 关注的直播 */
#define kRequestURLFollowingLives REQUEST_URL(@"LIVE_HOMEPAGE")

/** 热门的直播 */
#define kRequestURLHotLives REQUEST_URL(@"LIVE_SIMPLEALL")

/** 置顶的热门直播 */
#define kRequestURLTopHotLives REQUEST_URL(@"LIVE_GETTOP")

/** 推荐的达人 */
#define kRequestURLRecommendedUsers REQUEST_URL(@"LIVE_LATEST")



/** 用户的个人资料 */
#define kRequestURLUserInfo REQUEST_URL(@"USER_INFO")

/** 用户的关注和粉丝数量 */
#define kRequestURLFollowNumber REQUEST_URL(@"NUM_RELATION")

/** 用户的关注列表 */
#define kRequestURLFollowingList REQUEST_URL(@"RELATION_FOLLOWINGS")

/** 用户的粉丝列表 */
#define kRequestURLFollowerList REQUEST_URL(@"RELATION_FANS")

/** 关注用户的直播回放列表 */
#define kRequestURLFollowingRecord REQUEST_URL(@"FOLLOW_RECORD")

/** 查看某个用户的回放 */
#define kRequestURLSomeoneRecord REQUEST_URL(@"RECORDS")

/** 用户的映票贡献榜 */
#define kRequestURLContributionRanking REQUEST_URL(@"STATISTIC_CONTRIBUTION")

/** 加入黑名单 */
#define kRequestURLAddBlack REQUEST_URL(@"RELATION_BLACK")

/** 移除黑名单 */
#define kRequestURLDeleteBlack REQUEST_URL(@"RELATION_DEL_BLACK")

/** 黑名单状态 */
#define kRequestURLBlackStatus REQUEST_URL(@"RELATION_BLACK_STAT")

/** 加载黑名单列表 */
#define kRequestURLBlackList REQUEST_URL(@"RELATION_BLACKS")

/** 关注 */
#define kRequestURLFollow REQUEST_URL(@"FOLLOW")

/** 取消关注 */
#define kRequestURLUnFollow REQUEST_URL(@"UNFOLLOW")

/** 获取推送状态 */
#define kRequestURLNotifyStatus REQUEST_URL(@"NOTIFY_STATUS")

/** 修改当前推送状态 */
#define kRequestURLSwitchNotifyStatus REQUEST_URL(@"NOTIFY_SWITCH")

/** 封锁某人开播的推送消息 */
#define kRequestURLAddSomeoneToNotifyBlack REQUEST_URL(@"NOTIFY_BLACK")

/** 解封某人开播的推送消息 */
#define kRequestURLRemoveSomeoneToNotifyBlack REQUEST_URL(@"NOTIFY_UNBLACK")

/** 推送状态的列表 */
#define kRequestURLNotifyStatusList REQUEST_URL(@"NOTIFY_RECENT")

/** 查找自己与其他用户的关注关系 */
#define kRequestURLRelationWithOther REQUEST_URL(@"RELATION")

/** 搜索用户 */
#define kRequestURLSearchUsers REQUEST_URL(@"USER_SEARCH")

/** 更新用户资料 */
#define kRequestURLUpdateUserInfo REQUEST_URL(@"USER_UPDATE_PROFILE")
/** 更改用户头像 */
#define kRequestURLUpdatePortrait REQUEST_URL(@"UPDATE_PROTRAIT")

/** 个人当前财富情况 */
#define kRequestURLProfitInfo REQUEST_URL(@"STATISTIC_INFO")

/** 历史财富统计情况 */
#define kRequestURLProfitRecord REQUEST_URL(@"STATISTIC_INOUT")

/** 以票兑钻比例 */
#define kRequestURLPaymentInfo REQUEST_URL(@"PAYMENT_INFO")

/** 提现比例说明 */
#define kRequestURLConversionRate REQUEST_URL(@"CONVERSION_RATE")

/** 加载礼物列表 */
#define kRequestURLGiftInfo REQUEST_URL(@"GIFT_INFO")

/** 送礼物 */
#define kRequestURLGiftSend REQUEST_URL(@"GIFT_SEND")

/** 举报 */
#define kRequestURLReport REQUEST_URL(@"REPORT")

/** 加载礼物图片 */
#define kRequestURLImageGift REQUEST_URL(@"IMAGE_GIFT")

/** 加载指定尺寸的图片 */
#define kRequestURLImageScale REQUEST_URL(@"IMAGE_SCALE")

#define kImagePath @"/image/scaleimage.php?url="

#define kImageURLWithName(imageName) [NSString stringWithFormat:@"%@%@%@", BASE_URL, kImagePath, imageName]

/** 绑定账号列表 */
#define kRequestURLBlindList REQUEST_URL(@"BIND_LIST")

/** 绑定账号信息 */
#define kRequestURLBlindUser REQUEST_URL(@"BIND_USER")

/** 绑定账号信息（含有昵称数据的返回请求） */
#define kRequestURLBlindUserInfo REQUEST_URL(@"BIND_INFOS")

/** 解决绑定账号 */
#define kRequestURLUNBlindUser REQUEST_URL(@"UNBIND_USER")

/**
 *  开播直播相关接口
 */

/** 准备开始直播 */
#define kRequestURLPrepareLive  REQUEST_URL(@"LIVE_PRE")

/** 开始开播 */
#define kRequestURLStartLive    REQUEST_URL(@"LIVE_START")

/** 结束开播 */
#define kRequestURLStopLive     REQUEST_URL(@"LIVE_STOP")

/** 保持在线开播 */
#define kRequestURLKeepLiveALIVE REQUEST_URL(@"LIVE_KEEPALIVE")

/** 保持连接地址，msglib要用 */
#define kRequestURLGateWayAddress REQUEST_URL(@"GATEWAYIPS")

/** 获取当前开播房间地址，msglib要用 */
#define kRequestURLCurretRoomAddress REQUEST_URL(@"LIVE_IPS")

/** 获取直播用户列表 */
#define kRequestURLLiveUsers REQUEST_URL(@"LIVE_USERS")

/** 发送私信 */
#define kRequestURLSendMessage REQUEST_URL(@"MSG_SEND")

/** 获取直播结束数据 */
#define kRequestURLLiveEndData REQUEST_URL(@"LIVE_STATISTIC")

/** 观看开播 */
#define kRequestURLWathLive REQUEST_URL(@"VIEW_LIVE")

/** 观看回放 */
#define kRequestURLLiveRecord REQUEST_URL(@"VIEW_RECORD")

/** 获取开播流 */
#define kRequestURLPublishStream LIVESTRING_URL(@"?name=CreateStream")

/** 获取直播播放流 */
#define kRequestURLLivePlayStream LIVESTRING_URL(@"index.php?name=PlayStream")

/** 获取region信息（用于开播，直播） */
#define kRequestURLRegionInfo   LIVESTRING_URL(@"index.php?name=Test")

/** 更新推送token */
#define kRequestURLUpdateApnsToken REQUEST_URL(@"UPDATE_DEV_TOKEN")

/** 上报数据 */
#define kRequestURLReportDataLog   REQUEST_URL(@"TEST_LOG")

/** 分享链接 */
#define kURLShare(broadcasterID, liveID, userID) [NSString stringWithFormat:@"http://www.itsme.media/mobile/share/share.php?uid=%@&liveid=%@&share_from=%@&dev=ios", broadcasterID, liveID, userID]

/** 上报当前程序激活状态 */
#define kRequestURLReportActive   REQUEST_URL(@"WAKEUP")

/** 获取回放数量 */
#define kRequestURLReplayNumber REQUEST_URL(@"RECORD_NUM")

/** 反馈 */
#define kRequestURlFeedBack REQUEST_URL(@"FEEDBACK")

/** 获取某个用户的直播状态 */
#define kRequestURLLiveStatus REQUEST_URL(@"USERLIVEINFO")

/** 获取关于规则信息 */
#define kRequestURLAboutRules REQUEST_URL(@"ABOUT_RULES")

/** 获取关于团队信息 */
#define kRequestURLAboutTerms REQUEST_URL(@"ABOUT_TERMS")

/** 获取关于政策信息 */
#define kRequestURLAboutPolicy REQUEST_URL(@"ABOUT_POLICY")

/** 获取关于ushow信息 */
#define kRequestURLAboutUShow REQUEST_URL(@"ABOUT_CONTACT")

/** 注册 */
#define kRequestURLRegister REQUEST_URL(@"REGISTER")

/** 删除回放记录 */
#define kRequestURLDeleteReplay REQUEST_URL(@"DELETE_RECORD")

/** 忘记密码 */
#define kRequestURLForgotPassword REQUEST_URL(@"FORGET_PASSWORD")

/** 重设密码 */
#define kRequestURLResetPassword REQUEST_URL(@"RESET_PASSWORD")

/** 通知服务端更新用户信息，如地理位置等 */
#define kRequestURLUpdateLastInfo REQUEST_URL(@"UPDATE_LAST_INFO")

/** 弹幕的基本信息 */
#define kRequestURLDanmuInfo REQUEST_URL(@"DANMUKU_INFO")

/** 查看版本号 */
#define kRequestURLCheckUpdate REQUEST_URL(@"CHECK_VERSION")

/** 热门列表的Banner广告 */
#define kRequestURLBannerAD REQUEST_URL(@"LIVE_BANNER_AD")

/** 推荐主播列表 */
#define kRequestURLRecommend REQUEST_URL(@"RECOMMENDS")

/** 实时更新的推荐的主播列表 */
#define kRequestURLMgrRecommend REQUEST_URL(@"MGR_RECOMMDEN")

/** 批量关注主播 */
#define kRequestURLBatchFollow REQUEST_URL(@"BATCHFOLLOW")

/** tag直播中的主播列表 */
#define kRequestURLTagLiveList REQUEST_URL(@"LIVE_TAGSEARCH")

/** tag回放的主播列表 */
#define kRequestURLRecordTagLiveList REQUEST_URL(@"LIVE_TAGSEARCH_RECORD")

/** 榜单按钮显示状态 */
#define kRequestURLRankListButton REQUEST_URL(@"RANK_FANS_AREA")

///-----------------------------------------------------------------------------
/// Payment
///-----------------------------------------------------------------------------
#pragma mark - Payment -
/** 获取内购商品列表 */
#define kRequestURLProductList REQUEST_URL(@"PRODUCT_INFO")

/** 充值 */
#define kRequestURLDeposit REQUEST_URL(@"DEPOSIT")

// 越南版
#if TARGET_VERSION_VIETNAM
    /** 检查是否打开点卡 */
    #define kRequestURLStoreVCardStatus REQUEST_URL(@"CHECK_TP_DEPOSIT")
#endif

// 泰国版和越南版
#if TARGET_VERSION_THAILAND || TARGET_VERSION_VIETNAM
    /** 检查是否打开提现 */
    #define kRequestURLCheckWithdraw REQUEST_URL(@"CHECK_WITHDRAW")
#endif

///-----------------------------------------------------------------------------
/// 禁言管理
///-----------------------------------------------------------------------------
#pragma mark - 禁言管理 -
/** 查询用户在直播间的状态（是否为管理员，是否被禁言等） */
#define kRequestURLCheckUserStatus REQUEST_URL(@"LIVE_USER_ROOM_STATUS")

/** 授权用户为管理员 */
#define kRequestURLSetManager REQUEST_URL(@"LIVE_SETMANAGER")

/** 取消授权用户为管理员 */
#define kRequestURLUnsetManager REQUEST_URL(@"LIVE_UNSETMANAGER")

/** 加载管理员列表 */
#define kRequestURLLoadManagers REQUEST_URL(@"LIVE_GETMANAGER")

/** 禁止用户发言 */
#define kRequestURLFreezeTalk REQUEST_URL(@"LIVE_BANTALK")

/** 自动分享 */
#define kRequestURLAutoShare  REQUEST_URL(@"BINDPF_SHARE")

/** 直播间分享领钻石 */
#define kRequestURLShareGainGold  REQUEST_URL(@"SHARE_GAIN_GOLD")

/** tags */
#define kRequestURLTagsName  REQUEST_URL(@"HASH_TAG")

/** 全部tags */
#define kRequestURLAllTagsName  REQUEST_URL(@"HASH_TAG_ALL")

/** 个人页显示tw fb账号 */
#define kRequestURLBindingList  REQUEST_URL(@"USER_UBIND_LIST")


///-----------------------------------------------------------------------------
/// 快速发言
///-----------------------------------------------------------------------------
#pragma mark - 快速发言 -
/** 快速发言 */
#define kRequestURLFastStatement REQUEST_URL(@"QUICK_SPEECH")

///-----------------------------------------------------------------------------
/// 热门
///-----------------------------------------------------------------------------
#pragma mark - 热门 -
/** 热门回放 */
#define kRequestURLHotReplays REQUEST_URL(@"RECORD_MODULE")

///-----------------------------------------------------------------------------
/// 活动
///-----------------------------------------------------------------------------
#pragma mark - 热门 -

// key暂时还没有给出

/** 首页活动入口 */
#define kRequestURLRoomActivity REQUEST_URL(@"PACKAGE")

/** 首页活动入口是否点击领取 */
#define kRequestURLClickActivity REQUEST_URL(@"RECEIVEPACKAGE")

/** 直播间活动入口 */
#define kRequestURLLiveActivity REQUEST_URL(@"LIVEPACKAGE")

/** 直播间发送活动礼物 */
#define kRequestURLActivitySendGift REQUEST_URL(@"SENDPACKAGE")

/** 附近开播主播 */
#define kRequestURLLiveNearby   REQUEST_URL(@"LIVE_NEARBY")

///-----------------------------------------------------------------------------
/// 分组整理，方便查找！
///-----------------------------------------------------------------------------
#pragma mark - 分组整理，方便查找！ -
/** 服务器配置信息 */
#define kRequestURLServerSettings REQUEST_URL(@"SETTINGS")


#endif
