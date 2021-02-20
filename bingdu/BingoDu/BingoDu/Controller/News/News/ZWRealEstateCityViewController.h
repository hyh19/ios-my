#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 房产频道城市定位控件
 */
@interface ZWRealEstateCityCell : UICollectionViewCell

/** 城市信息 */
@property (nonatomic, strong) NSDictionary *data;

@end

@class ZWRealEstateCityViewController;

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup protocol
 *  @brief 房产频道城市定位界面委托
 */
@protocol ZWRealEstateCityViewControllerDelegate <NSObject>

/** 选定城市后的回调操作 */
- (void)realEstateViewController:(ZWRealEstateCityViewController *)viewController didSelectCity:(NSDictionary *)dict;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 房产频道城市定位界面
 */
@interface ZWRealEstateCityViewController : UICollectionViewController

/** 房产频道城市定位界面委托 */
@property (nonatomic, weak) id<ZWRealEstateCityViewControllerDelegate> delegate;

@end
