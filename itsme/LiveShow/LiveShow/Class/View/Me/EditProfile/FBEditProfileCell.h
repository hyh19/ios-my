#import <UIKit/UIKit.h>
@class FBUserInfoModel;

typedef NS_ENUM(NSInteger, FBEditProfileCellType) {
    FBEditProfileCellTypePortrait, //<头像
    FBEditProfileCellTypeNick,     //<昵称
    FBEditProfileCellTypeGender,   //<性别
    FBEditProfileCellTypeMood      //<心情
};

/**
 *  @author 李世杰
 *  @brief  编辑资料cell
 */

@interface FBEditProfileCell : UITableViewCell

@property (nonatomic, strong) UILabel *typeLabel;

@property (nonatomic, strong) UIImageView *portraitImageView;

@property (nonatomic, strong) UILabel *nickLabel;

@property (nonatomic, strong) UIImageView *genderImageView;

- (instancetype)initWithType:(FBEditProfileCellType)type;

@end
