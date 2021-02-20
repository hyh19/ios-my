#import <UIKit/UIKit.h>
#import "FBMessageModel.h"

/**
 *  @author 黄玉辉
 *  @brief 直播室消息列表
 */
@interface FBChatView : UIView

/** 是否自动滚动消息 */
@property (nonatomic) BOOL autoScroll;

/** 接收新消息 */
- (void)receiveMessage:(FBMessageModel *)model;

@end
