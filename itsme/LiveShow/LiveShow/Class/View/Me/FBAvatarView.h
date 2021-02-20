#import <UIKit/UIKit.h>
@class FBAvatarView;

typedef enum : NSUInteger {
    /** 修改用户头像 */
    FBAvatarViewTypeEdit,
    /** 查看保存头像 */
    FBAvatarViewTypeSave,
    
} FBAvatarViewType;

/**
 *  @author 李世杰
 *  @brief  个人中心/个人主页查看头像view
 */

@protocol FBAvatarViewDelegeate <NSObject>

@optional

- (void)takePhoto:(FBAvatarView *)avatarView button:(UIButton *)button;

- (void)selectFromAlbums:(FBAvatarView *)avatarView button:(UIButton *)button;

- (void)onClickAvatarView;
@end

@interface FBAvatarView : UIView

@property (nonatomic, weak) id<FBAvatarViewDelegeate> delegate;

@property (nonatomic, strong) UIImageView *avatarImageView;

- (instancetype)initWithFrame:(CGRect)frame type:(FBAvatarViewType)type;

@end
