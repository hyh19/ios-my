@class ZWImageLoopView;

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @brief 轮播图界面的委托
 */
@protocol ZWImageLoopViewDelegate <NSObject>

@optional

/** 点击轮播图的回调方法 */
- (void)imageLoopView:(ZWImageLoopView *)imageLoopView didClickImageAtIndex:(NSInteger)index;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup view
 *  @brief 轮播图界面
 */
#import <UIKit/UIKit.h>

@interface ZWImageLoopView : UIView <UIScrollViewDelegate>

/** 显示的图片URL数组 */
@property (nonatomic, strong) NSArray *imageURLArr;

/** 网络加载时的占位图片 */
@property (strong, nonatomic) UIImage *placeHodlerImage;

/** 代理对象 */
@property (nonatomic, assign) id<ZWImageLoopViewDelegate> delegate;

/** 图片自动轮播时间间隔, 默认时间为2秒 */
@property (nonatomic, assign) NSTimeInterval loopTime;

/** 图片数据源 */
@property (strong, nonatomic) NSMutableArray *imgData;

/**
 父级控制器
 */
@property (nonatomic, strong)UIViewController* themainview;

/** 频道名称 */
@property (nonatomic, strong)NSString * channelName;

@end
