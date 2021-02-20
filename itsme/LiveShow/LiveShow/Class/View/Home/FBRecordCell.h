#import <UIKit/UIKit.h>
#import "FBRecordModel.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @author 李世杰
 *  @brief 直播回放
 */
@interface FBRecordCell : UITableViewCell

/** 回放数据 */
@property (nonatomic, strong) FBRecordModel *model;

/* cell的背景颜色 */
- (void)cellColorWithIndexPath:(NSIndexPath *)indexPath;

@end
