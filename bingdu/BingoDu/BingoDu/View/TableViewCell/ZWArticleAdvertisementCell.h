#import <UIKit/UIKit.h>
#import "ZWArticleAdvertiseModel.h"

/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 新闻详情的广告cell
 */
@interface ZWArticleAdvertisementCell : UITableViewCell

/**
 *  文章广告containview
 */
@property (weak, nonatomic) IBOutlet UIView *centerContentView;

/**
 *  广告图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *adversizeImage;

/**
 *  广告标题
 */
@property (weak, nonatomic) IBOutlet UILabel *advertiseTitle;

/**
 *  广告标记
 */
@property (weak, nonatomic) IBOutlet UIImageView *advertiseFlag;

/**
 *  文章广告数据源
 */
@property (strong, nonatomic) ZWArticleAdvertiseModel *articeAdvertizeModel;

/**
 *  更新广告viewFrame
 */
-(void)updateAdvetiseViewFrame:(ZWArticleAdvertiseModel *)articeAdvertizeModel;
/**
 *  设置图片url
 */
-(void)setAdvertiseImageView:(NSString*)imgUrl;

@end
