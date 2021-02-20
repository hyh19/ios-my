#import <UIKit/UIKit.h>

/**
 *  @author 李世杰
 *  @brief 编辑个性签名
 */

@interface FBSignatureViewController : FBBaseViewController

@property (nonatomic, copy) NSString *Description;

+ (instancetype)signatureViewController;

@end
