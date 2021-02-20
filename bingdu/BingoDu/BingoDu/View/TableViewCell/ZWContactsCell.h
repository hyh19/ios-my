#import <UIKit/UIKit.h>

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 通讯录列表项
 */

@interface ZWContactsCell : UITableViewCell

/** 用户头像，没有头像则显示默认图片 */
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

/** 姓名 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

/** 手机号 */
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;

/** 邀请按钮 */
@property (strong, nonatomic) IBOutlet UIButton *inviteButton;

@end
