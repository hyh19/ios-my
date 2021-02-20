#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉
 *
 *  @brief 切换冲钻方式的标签栏
 */
@interface FBStoreSegmentedControl : UIView

@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, copy) void (^indexChangeBlock)(NSUInteger index);

@end

/**
 *  @author 黄玉辉
 *
 *  @brief 切换冲钻方式的标签
 */
@interface FBStoreSegmentCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, getter=isChecked) BOOL checked;

@end
