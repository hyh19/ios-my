#import <UIKit/UIKit.h>
#import "FBRecommendModel.h"

@class FBRecommendCell;

@protocol FBRecommendCellDelegate <NSObject>
- (void)cell:(FBRecommendCell *)cell button:(UIButton *)button;
- (void)clickHeadViewWithModel:(FBRecommendModel *)model;

@end

/**
 *  @author 林思敏
 *  @brief  推荐主播列表cell
 */

@interface FBRecommendCell : UITableViewCell

@property (strong, nonatomic) FBRecommendModel *data;

/** 打勾按钮 */
@property (strong, nonatomic) UIButton *sureButton;

@property (strong, nonatomic) NSString *uid;

@property (nonatomic, weak) id <FBRecommendCellDelegate> delegate;

- (BOOL)isOneOfUIDs:(NSMutableArray *)uids;

@end
