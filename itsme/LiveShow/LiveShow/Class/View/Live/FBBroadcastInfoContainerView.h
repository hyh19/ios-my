#import <UIKit/UIKit.h>
#import "FBBroadcastInfoView.h"



/**
 *  @author 黄玉辉
 *  @brief 开播界面信息层父容器
 */
@interface FBBroadcastInfoContainerView : UIView

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame type:(FBLiveType)type;

/** 开播信息层 */
@property (nonatomic, strong) FBBroadcastInfoView *contentView;

@end
