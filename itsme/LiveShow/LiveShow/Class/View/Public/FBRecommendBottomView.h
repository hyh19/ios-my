#import <UIKit/UIKit.h>

@class FBRecommendBottomView;

@protocol FFBRecommendBottomViewDelegate <NSObject>
- (void)onTouchButtonDone;

@end

/**
 *  @author 林思敏
 *  @brief  推荐主播列表bottom视图
 */

@interface FBRecommendBottomView : UIView

/** 完成按钮 */
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, weak) id <FFBRecommendBottomViewDelegate> delegate;

@end
