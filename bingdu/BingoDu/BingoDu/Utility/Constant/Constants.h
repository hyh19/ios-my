#ifndef BingoDu_Constants_h
#define BingoDu_Constants_h

#define ZWLocalizedString(key) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

/**
 *  失败视图的tag值
 */
#define kFaildViewTag 87025

//广告图片缩放比率
#define AdvImgRatio 95./568

#define DOT_COORDINATE 0
#define ARROW_BUTTON_WIDTH  35
#define NAV_TAB_BAR_HEIGHT     ARROW_BUTTON_WIDTH

#define UIColorWithRGBA(r,g,b,a)        [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

/**
 时分日
 */
#define aMinute 60
#define anHour 3600
#define aDay 86400

/** 订阅频道的标识 */
#define kSubscribeChannelMapping @"wechartSubscribe"

/** 加载数据失败的提示 */
#define kNetworkErrorString @"加载失败，请检查网络连接"

/** 服务端返回的时趣广告标记 */
#define kSTADIdentifier @"-11"

/** 服务端返回的互锋广告标记 */
#define kYDADIdentifier @"-13"

// 测试精选列表轮播新闻
#define TEST_LOOP_AD YES

#endif
