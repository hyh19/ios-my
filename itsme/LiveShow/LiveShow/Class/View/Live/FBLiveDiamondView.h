#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉
 *  @brief 主播收到的钻石
 */
@interface FBLiveDiamondView : UIView

/** 点击事件 */
@property (nonatomic, copy) void (^doTapViewAction)(void);

/** 更新钻石数量 */
- (void)updateDiamondCount:(NSInteger)count;

/** 送礼端本地增加钻石数量，避免因为网络问题导致主播收到礼物时钻石数没有增加 */
- (void)addDiamondCount:(NSInteger)count;

/** 显示/隐藏连接房间失败状态 */
- (void)showSocketErrorView:(BOOL)bShow;

@end
