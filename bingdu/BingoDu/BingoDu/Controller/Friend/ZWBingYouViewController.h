#import "ZWBaseViewController.h"

/**
 *  并友类型
 */
typedef NS_ENUM(NSUInteger, SegmentType)
{
    kBingyou,  //并友
    kMsg       //消息
};

/**
 *  @author 刘云鹏
 *  @ingroup controller
 *  @brief 并友
 */


@interface ZWBingYouViewController : ZWBaseViewController
/**标记当前所选的segement类型*/
@property(nonatomic,assign)  SegmentType  currentType;
/**
 *  @brief 构造函数
 *  @prama segmentType 并友或者是回复
 */
-(id)initWithViewType:(SegmentType) segmentType;

/** 工厂方法 */
+ (instancetype)viewController;
/**显示或者影藏红点*/
-(void)hideOrShowRedPoint:(BOOL) isShow;
@end
