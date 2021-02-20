#import <UIKit/UIKit.h>

/**
 *  @author 林思敏
 *  @brief 活动视图
 */

@protocol FBActivityViewDelegate <NSObject>

@required

- (void)clickSureButton;

- (void)clickIntroduceButton;

@end

@interface FBActivityView : UIView

/** 活动标题 */
@property (strong, nonatomic) UILabel *title;

/** 活动标题说明 */
@property (strong, nonatomic) UILabel *detail;

/** 活动图片 */
@property (strong, nonatomic) UIImageView *icon;

@property (strong, nonatomic) id<FBActivityViewDelegate> activitydDelegate;

@property (nonatomic, copy) void (^doCancelCallback)(void);

@end
