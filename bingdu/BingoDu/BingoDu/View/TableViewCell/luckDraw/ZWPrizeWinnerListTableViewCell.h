#import <UIKit/UIKit.h>

// TODO: 补充填写姓名

/**
 *  @ingroup view
 *  @brief 补充注释
 */
@interface ZWPrizeWinnerListTableViewCell : UITableViewCell
/**
 *  获奖者头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *winnerHeadImage;
/**
 *  获奖者名字
 */
@property (weak, nonatomic) IBOutlet UILabel *winnerName;
/**
 *  获奖者电话号码
 */
@property (weak, nonatomic) IBOutlet UILabel *winnerPhoneNumber;
/**
 *  开奖时间
 */
@property (weak, nonatomic) IBOutlet UILabel *prizeTime;
/**
 *  奖券号码
 */
@property (weak, nonatomic) IBOutlet UILabel *winnerTicketNumber;
/**
 *  底部视图
 */
@property (weak, nonatomic) IBOutlet UIView *bottomContainView;
/**
 *  上部父视图
 */
@property (weak, nonatomic) IBOutlet UIView *upContainView;

/**填充数据*/
-(void)fillContentWithDictionary:(NSDictionary*)dic;
@end
