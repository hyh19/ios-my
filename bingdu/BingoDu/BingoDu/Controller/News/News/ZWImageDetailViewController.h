#import "ZWBaseViewController.h"

/**
 *  @author 刘云鹏
 *  @ingroup controller
 *  @brief 点击网页图片查看大图模块
 */
@interface ZWImageDetailViewController : ZWBaseViewController
/**
 图片与标题数据源
 */
@property(nonatomic,strong)NSMutableDictionary *imgData;
/**
 更新用户滑动到某一位置的图片信息数据
 */
-(void)updateView;

@end