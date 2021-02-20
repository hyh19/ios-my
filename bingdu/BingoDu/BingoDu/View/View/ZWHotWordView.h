#import <UIKit/UIKit.h>

@class ZWHotWordView;

/**
 *   新闻搜索热词点击响应delegate
 */
@protocol ZWHotWordViewDelegate <NSObject>

@optional

/**
 *   新闻搜索热词点击响应方法
 */
- (void)hotWordView:(ZWHotWordView *)view didSelectTag:(id)sender;

@end


/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 搜索热词界面
 */
@interface ZWHotWordView : UIView

/** 代理对象 */
@property (nonatomic, assign) id<ZWHotWordViewDelegate> delegate;

/** 设置热词数据 */
- (void)setTags:(NSArray *)array;

/** 界面展示方法 */
- (void)display;

/** 自适应大小方法 */
- (CGSize)fittedSize;

@end
