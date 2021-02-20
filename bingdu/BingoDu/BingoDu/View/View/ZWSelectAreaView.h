
#import <UIKit/UIKit.h>

@interface ZWSelectAreaView : UIView

/**
 *  选择区域结果返回
 *
 *  @param area      地区
 */
typedef void (^ZWSelectAreaResultBlock)(NSString *area);

- (void)initSelectAreaViewWithSelectResult:(ZWSelectAreaResultBlock)areaResult;

- (void)showAreaView;

@end
