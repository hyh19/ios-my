#import <UIKit/UIKit.h>

/**
 *  @author 林思敏
 *  @brief 直播间活动提示view
 */

@protocol FBActivityTipViewDelegate <NSObject>

@required

- (void)clickSureButton;

@end

@interface FBActivityTipView : UIView

@property (strong, nonatomic) id<FBActivityTipViewDelegate> activitydDelegate;

@property (nonatomic, copy) void (^doCancelCallback)(void);

@end
