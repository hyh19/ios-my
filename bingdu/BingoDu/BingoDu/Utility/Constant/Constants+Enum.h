#ifndef BingoDu_Constants_Enum_h
#define BingoDu_Constants_Enum_h

typedef enum
{
    UnknowActionType = 0,//未知类型
    ShareActionType = 2,//分享
    PraiseActionType = 9,//点赞
    commetActionType = 7,//评论
    readActionType = 8//阅读
}ActionType;

typedef enum {
    ZWNoSpread_State =0,
    ZWSpread_State = 1
}ZWSpreadState;//推广非推广

typedef enum {
    ZWNormal =0,
    ZWLike = 1,
    ZWHate = 2
}ZWLikeOrNolike;//喜欢不喜欢



typedef enum{
    ZWADVERSTARTUP = 1,// 启动页
    ZWADVERCAROUSEL = 2,//轮播
    ZWADVERSTREAM = 3,//信息流
    ZWADVERTORIAL = 4,//软文
    ZWADVERARTICLE = 5//文章
}ZWAdvType;//广告从属类型

/**广告跳转类型*/
typedef enum {
    AdvertiseType = 1,       /** 广告类型*/
    GoodsDetailType = 2,     /** 商品详情*/
    LotteryDetailType = 3,   /** 抽奖详情*/
    ActivityDetailType = 4,  /** 活动详情*/
    GoodsListType = 5,       /** 商品首页*/
    LotteryListType = 6      /** 抽奖首页*/
} RedirectType;

/**搜索类型*/
typedef enum {
    NewsType = 1,       /** 普通新闻*/
    TopicType = 2,      /** 专题*/
    FavoriteType = 3,   /** 收藏*/
} SearchType;

///-----------------------------------------------------------------------------
/// @name 新闻
///-----------------------------------------------------------------------------
#pragma mark - 新闻 -


/**绑定类型*/
typedef enum {
    SinaType = 0,/**新浪微博*/
    WechatType = 1,/**微信*/
    QQType = 2 /**QQ*/
} BindingType;

#endif
