#import <UIKit/UIKit.h>
#import "FBLiveInfoModel.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @brief 最新直播
 */
@interface FBNewLiveCell : UICollectionViewCell

@property (nonatomic, strong) FBLiveInfoModel *live;

/** 长按的回调函数 */
@property (nonatomic, copy) void (^doRemoveAction)(FBLiveInfoModel *model);

@end
