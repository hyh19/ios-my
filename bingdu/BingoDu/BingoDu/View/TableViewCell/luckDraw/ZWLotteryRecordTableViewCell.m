#import "ZWLotteryRecordTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface ZWLotteryRecordTableViewCell ()

/**奖券状态label*/
@property (weak, nonatomic) IBOutlet UILabel *lotteryStatusLabel;

/**奖券背景imageView*/
@property (weak, nonatomic) IBOutlet UIImageView *lotteryRecordBgImageView;

/**奖券icon图片*/
@property (weak, nonatomic) IBOutlet UIImageView *lotteryIconImageView;

/**奖券名字标签*/
@property (weak, nonatomic) IBOutlet UILabel *lotteryNameLabel;

/**奖券日期*/
@property (weak, nonatomic) IBOutlet UILabel *lotteryDateLabel;

@end

@implementation ZWLotteryRecordTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Getter & Setter
- (void)setLotteryModel:(ZWLotteryModel *)lotteryModel
{
    if(lotteryModel != _lotteryModel)
    {
        _lotteryModel = lotteryModel;
        
        self.lotteryNameLabel.text = lotteryModel.lotteryName;
        
        self.lotteryDateLabel.text = [NSString stringWithFormat:@"%@\n%@", lotteryModel.lotteryInfo, lotteryModel.lotterySurplus];
        
        [self.lotteryIconImageView sd_setImageWithURL:[NSURL URLWithString:lotteryModel.lotteryImageUrl] placeholderImage:[UIImage imageNamed:@"icon_lottery"]];

        switch (lotteryModel.lotteryStatus) {
            case NotLotteryStatus:
                [self.lotteryRecordBgImageView setImage:[[UIImage imageNamed:@"bg_defaulting"] stretchableImageWithLeftCapWidth:60 topCapHeight:0]];
                self.lotteryStatusLabel.text = @"未开奖";
                break;
                
            case NotWinningStatus:
                [self.lotteryRecordBgImageView setImage:[[UIImage imageNamed:@"bg_failure"] stretchableImageWithLeftCapWidth:60 topCapHeight:0]];
                self.lotteryStatusLabel.text = @"未中奖";
                break;
                
            case HasWinningStatus:
                [self.lotteryRecordBgImageView setImage:[[UIImage imageNamed:@"bg_success"] stretchableImageWithLeftCapWidth:60 topCapHeight:0]];
                self.lotteryStatusLabel.text = @"已中奖";
                break;
            case VoidedStatus:
                [self.lotteryRecordBgImageView setImage:[[UIImage imageNamed:@"bg_cancel"] stretchableImageWithLeftCapWidth:60 topCapHeight:0]];
                self.lotteryStatusLabel.text = @"已作废";
                break;
            case RefundStatus:
                [self.lotteryRecordBgImageView setImage:[[UIImage imageNamed:@"bg_cancel"] stretchableImageWithLeftCapWidth:60 topCapHeight:0]];
                self.lotteryStatusLabel.text = @"已退款";
                break;
                
            default:
                break;
        }
    }
}

@end
