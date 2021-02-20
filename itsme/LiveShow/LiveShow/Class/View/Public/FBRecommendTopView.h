#import <UIKit/UIKit.h>

@class FBRecommendTopView;

@protocol FBRecommendTopViewDelegate <NSObject>
- (void)onTouchButtonClose;

@end

/**
 *  @author 林思敏
 *  @brief  推荐主播列表top视图
 */

@interface FBRecommendTopView : UIView

@property (nonatomic, weak) id <FBRecommendTopViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title;

@end
