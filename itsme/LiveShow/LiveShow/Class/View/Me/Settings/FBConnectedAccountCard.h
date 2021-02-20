#import <UIKit/UIKit.h>
#import "FBAccountListModel.h"
#import "ColorButton.h"

@protocol FBEmailUnConnectedAccountCardDelegate <NSObject>

@required
/** 更新邮箱绑定后的数据 */
- (void)updateEmailData;

@end

/**
 *  @author 林思敏
 *  @brief  弹出的添加邮箱绑定账号卡片
 */

@interface FBEmailUnConnectedAccountCard : UIView

/** icon */
@property (strong, nonatomic) UIImageView *icon;

@property (strong, nonatomic) id<FBEmailUnConnectedAccountCardDelegate> delegate;

@property (nonatomic, copy) void (^doCancelCallback)(void);

@end



@protocol FBConnectedAccountCardDelegate <NSObject>

@required
/** 点击添加绑定账号的事件 */
- (void)clickConnectedAccount:(NSString *)type;

/** 更新绑定后的数据 */
- (void)updateData;

@end

/**
 *  @author 林思敏
 *  @brief  弹出的已绑定账号卡片
 */
@interface FBConnectedAccountCard : UIView

/** 添加按钮 */
@property (strong, nonatomic) ColorButton *addbutton;

@property (nonatomic, strong) FBAccountListModel *accountModel;

/** 是否绑定 */
@property (assign, nonatomic) BOOL isConnected;

@property (strong, nonatomic) id<FBConnectedAccountCardDelegate> delegate;

@property (nonatomic, copy) void (^doCancelCallback)(void);

@end



