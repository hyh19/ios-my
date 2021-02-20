#import <UIKit/UIKit.h>
@class FBContactsModel;
@class FBUserInfoModel;
@class FBContactsCell;

/**
 *  @author 李世杰
 *  @brief  关注,粉丝,搜索,列表cell
 */

@protocol FBContactsCellDelegate <NSObject>

@required
- (void)contactsCell:(FBContactsCell *)cell changeFollowStatus:(UIButton *)button;

@end

@interface FBContactsCell : UITableViewCell

@property (nonatomic, strong) FBContactsModel *contacts;

@property (nonatomic, weak) id<FBContactsCellDelegate> delegate;


- (void)cellColorWithIndexPath:(NSIndexPath *)indexPath;

@end
