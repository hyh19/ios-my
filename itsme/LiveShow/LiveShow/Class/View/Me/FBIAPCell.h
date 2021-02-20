#import <UIKit/UIKit.h>
#import <StoreKit/SKProduct.h>

/**
 *  @author 黄玉辉
 *
 *  @brief App Store内置购买
 */
@interface FBIAPCell : UITableViewCell

/** 内置购买商品数据 */
@property (nonatomic, strong) SKProduct *product;

@end
