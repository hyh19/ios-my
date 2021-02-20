#import <Foundation/Foundation.h>
#import "FBBindUserInfoModel.h"

/**
 *  @author 林思敏
 *  @brief 账号绑定列表Model
 */

@interface FBAccountListModel : NSObject

@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *account;
@property (strong, nonatomic) NSString *platform;
@property (strong, nonatomic) FBBindUserInfoModel *infosModel;

@end
