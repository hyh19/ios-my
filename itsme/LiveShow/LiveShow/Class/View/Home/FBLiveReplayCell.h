#import <UIKit/UIKit.h>
#import "FBHotRecordModel.h"

@protocol FBHotReplayViewDelegate <NSObject>

@required

- (void)clickReplayView:(FBRecordModel *)replay;

@end

/**
 *  @author 林思敏
 *  @brief  热门回放view
 */

@interface FBLiveReplayCell : UITableViewCell

@property (strong, nonatomic) FBHotRecordModel *hotRecordModel;

@property (strong, nonatomic) id<FBHotReplayViewDelegate> repalyDelegate;

@end
