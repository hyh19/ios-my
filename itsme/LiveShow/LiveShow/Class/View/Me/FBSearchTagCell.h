#import <UIKit/UIKit.h>
#import "FBTagsModel.h"
#import "FBRecordModel.h"
#import "FBLiveInfoModel.h"

/**
 *  @author 李世杰
 *  @brief  搜索界面TAG的cell
 */
@class FBSearchAvatarView;

@interface FBSearchTagCell : UITableViewCell
/** tag模型 */
@property (nonatomic, strong) FBTagsModel *tags;

@property (nonatomic, copy) void (^onClickAvatar)(id model);

+ (instancetype)searchTagCell:(UITableView *)tableView;

@end



/**
 *  @author 李世杰
 *  @since 2.0
 *  @brief HashTags里面的主播头像
 */
@interface FBSearchAvatarView : UIButton

@property (nonatomic, strong) id model;

@end
