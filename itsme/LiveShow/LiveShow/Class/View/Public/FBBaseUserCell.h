#import <UIKit/UIKit.h>
#import "FBContactsModel.h"

/**
 *  @author 黄玉辉
 *  @brief 用户列表Cell的基类，如我的关注、我的粉丝、达人推荐等
 */
@interface FBBaseUserCell : UITableViewCell

/** 头像 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/** 昵称 */
@property (nonatomic, strong) UILabel *nickNameLabel;

/** 简介 */
@property (nonatomic, strong) UILabel *summaryLabel;

/** 关注按钮 */
@property (nonatomic, strong) UIButton *followButton;

/** 关注按钮的Block */
@property (nonatomic, copy) void (^followButtonBlock)(UIButton *button);

@end
