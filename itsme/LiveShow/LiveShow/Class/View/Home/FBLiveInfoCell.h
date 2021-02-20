#import <UIKit/UIKit.h>
#import "FBLiveInfoModel.h"

@protocol FBLiveInfoCellDelegate <NSObject>

@required

- (void)clickHeadViewWithModel:(FBLiveInfoModel *)live ;

@end

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @brief 直播信息
 */
@interface FBLiveInfoCell : UITableViewCell

@property (nonatomic, strong) UIView *separatorView;

/** 直播信息 */
@property (nonatomic, strong) FBLiveInfoModel *model;

+ (CGFloat)topHeight;

@property (strong, nonatomic) id<FBLiveInfoCellDelegate> delegate;

/** 长按的回调函数 */
@property (nonatomic, copy) void (^doRemoveAction)(FBLiveInfoModel *model);

@end
