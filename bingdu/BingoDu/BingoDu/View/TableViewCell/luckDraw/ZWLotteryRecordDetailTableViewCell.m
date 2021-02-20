#import "ZWLotteryRecordDetailTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+NHZW.h"
#import "HTCopyableLabel.h"

@interface ZWLotteryRecordDetailTableViewCell ()<HTCopyableLabelDelegate>

/**奖券icon图片*/
@property (weak, nonatomic) IBOutlet UIImageView *lotteryIconImageView;

/**奖券名字标签*/
@property (weak, nonatomic) IBOutlet UILabel *lotteryNameLabel;

/**奖券日期标签*/
@property (weak, nonatomic) IBOutlet UILabel *lotteryDateLabel;

/**模块标题*/
@property (weak, nonatomic) IBOutlet UILabel *contentsLabel;

/**奖券状态*/
@property (weak, nonatomic) IBOutlet UILabel *lotteryStatusLabel;

/**奖券码*/
@property (weak, nonatomic) IBOutlet UILabel *lotteryNumLabel;

/**我的奖券状态*/
@property (weak, nonatomic) IBOutlet UILabel *myLotteryStatusLabel;

/**客户姓名*/
@property (weak, nonatomic) IBOutlet UILabel *customerName;

/**客户手机号码*/
@property (weak, nonatomic) IBOutlet UILabel *customerMobileLabel;

/**客户地址*/
@property (weak, nonatomic) IBOutlet UILabel *customerAddressLabel;

/**送货方式*/
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;

/**物流订单号码*/
@property (weak, nonatomic) IBOutlet UILabel *deliveryNumLabel;

/**奖券数据模型*/
@property (nonatomic, strong)ZWLotteryDetailModel *lotteryDetailModel;

@end

@implementation ZWLotteryRecordDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma  mark - privrite
- (void)lotteryDetailModel:(ZWLotteryDetailModel *)lotteryDetailModel
                 indexPath:(NSIndexPath *)indexPath
{
    if(lotteryDetailModel)
    {
        _lotteryDetailModel = lotteryDetailModel;
        
        if([self.reuseIdentifier isEqualToString:@"lotteryInfoCell"])
        {
            [self.lotteryIconImageView sd_setImageWithURL:[NSURL URLWithString:lotteryDetailModel.lotteryImageUrl] placeholderImage:[UIImage imageNamed:@"icon_lottery"]];
            
            self.lotteryNameLabel.text = lotteryDetailModel.lotteryName;
            
            self.lotteryDateLabel.text = lotteryDetailModel.lotteryInfo;
            
            if(self.subviews.count == 3)
            {
                UIView *view = [[self subviews] lastObject];
                [view removeFromSuperview];
            }
            
            if([self.contentView viewWithTag:100])
            {
                [[self.contentView viewWithTag:100] removeFromSuperview];
            }
            
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, SCREEN_WIDTH, 0.5)];
            
            lineLabel.backgroundColor = COLOR_E7E7E7;
            
            lineLabel.tag = 100;
            
            [self.contentView addSubview:lineLabel];
        }
        else if([self.reuseIdentifier isEqualToString:@"contentsCell"])
        {
            self.lotteryStatusLabel.text = @"";
            if(indexPath.section == 0)
            {
                self.contentsLabel.text = @"我的奖券";
            }
            else
            {
                if(!lotteryDetailModel.isVirtual)
                {
                    self.contentsLabel.text = @"寄送信息";
                
                    self.lotteryStatusLabel.text = lotteryDetailModel.deliveryState;
                }
                else
                {
                    self.contentsLabel.text = @"获奖信息";
                }
            }
        }
        else if ([self.reuseIdentifier isEqualToString:@"myLotteryCell"])
        {
            ZWLotteryTicketInfoModel *currentModel = [lotteryDetailModel.lotteryTickets objectAtIndex:indexPath.row - 2];
            
            self.lotteryNumLabel.text = currentModel.ticketsCode;
            
            self.lotteryNumLabel.textColor = COLOR_333333;
            
            switch (currentModel.lotteryStatus) {
                case NotLotteryStatus:
                    
                    [self.myLotteryStatusLabel setBackgroundColor:[UIColor colorWithHexString:@"#f4be00"]];
                    
                    self.myLotteryStatusLabel.text = @"未开奖";
                    
                    break;
                    
                case NotWinningStatus:
                    
                    [self.myLotteryStatusLabel setBackgroundColor:[UIColor colorWithHexString:@"#f25b5b"]];
                    
                    self.myLotteryStatusLabel.text = @"未中奖";
                    
                    break;
                    
                case HasWinningStatus:
                    
                    [self.myLotteryStatusLabel setBackgroundColor:[UIColor colorWithHexString:@"#4bc259"]];
                    
                    self.myLotteryStatusLabel.text = @"已中奖";
                    
                    break;
                case VoidedStatus:
                    
                    [self.myLotteryStatusLabel setBackgroundColor:[UIColor colorWithHexString:@"#aaabb0"]];
                    
                    self.myLotteryStatusLabel.text = @"已退款";
                    
                    break;
                    
                default:
                    break;
            }

        }
        else if([self.reuseIdentifier isEqualToString:@"customerInfoCell"])
        {
            self.customerName.text = [NSString stringWithFormat:@"姓名：%@", lotteryDetailModel.customerName];
            
            self.customerMobileLabel.text = [NSString stringWithFormat:@"电话：%@",lotteryDetailModel.mobile];
            
            self.customerAddressLabel.text = [NSString stringWithFormat:@"地址：%@",lotteryDetailModel.address];
        }
        else if([self.reuseIdentifier isEqualToString:@"deliveryInfoCell"])
        {
            self.deliveryLabel.text = [NSString stringWithFormat:@"送货方式：%@",lotteryDetailModel.delivery];
            
            self.deliveryNumLabel.text = [NSString stringWithFormat:@"货运单号：%@",lotteryDetailModel.deliveryTicket];
        }
        else if ([self.reuseIdentifier isEqualToString:@"prizeCell"])
        {
            
            NSArray *subViews = self.contentView.subviews;
            for(UIView *view in subViews)
            {
                [view removeFromSuperview];
            }
            
            NSInteger interval = 16;
            
            NSInteger hight = 17;
            
            for(NSString *prize in lotteryDetailModel.prizeInfo)
            {
                [self.contentView addSubview:[self creatPrizeView:CGRectMake(0, interval+hight*[lotteryDetailModel.prizeInfo indexOfObject:prize], SCREEN_WIDTH, hight) prizeNum:prize]];
                
                interval += 16;
            }
            
            NSInteger labelHight = 0;
            if(lotteryDetailModel.prizeInfo.count > 0){
                
                labelHight = interval + hight*lotteryDetailModel.prizeInfo.count;
            }
            else{
                labelHight = interval;
            }
            
            UILabel *prizeNoticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, labelHight, SCREEN_WIDTH-30, hight)];
            
            prizeNoticeLabel.backgroundColor = [UIColor clearColor];
            
            prizeNoticeLabel.text = @"注：长按兑换码可复制";
            
            prizeNoticeLabel.font = [UIFont systemFontOfSize:14];
            
            prizeNoticeLabel.textColor = COLOR_848484;
            
            [self.contentView addSubview:prizeNoticeLabel];
            
        }
        else if ([self.reuseIdentifier isEqualToString:@"prizeDescriptionCell"])
        {
            NSArray *subViews = self.contentView.subviews;
            for(UIView *view in subViews)
            {
                [view removeFromSuperview];
            }
            
            CGRect rect = [NSString heightForString:lotteryDetailModel.prizeDescription fontSize:13 andSize:CGSizeMake(SCREEN_WIDTH-30, 2000)];
            
            UILabel *prizeDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, SCREEN_WIDTH-30, rect.size.height)];
            
            prizeDescriptionLabel.backgroundColor = [UIColor clearColor];
            
            prizeDescriptionLabel.text = lotteryDetailModel.prizeDescription;
            
            prizeDescriptionLabel.font = [UIFont systemFontOfSize:13];
            
            prizeDescriptionLabel.numberOfLines = 0;
            
            prizeDescriptionLabel.textColor = COLOR_333333;
            
            [self.contentView addSubview:prizeDescriptionLabel];
        }
    }
}

//创建兑换码界面
- (UIView *)creatPrizeView:(CGRect)frame prizeNum:(NSString *)prizeNum
{
    UIView *prizeView = [[UIView alloc] initWithFrame:frame];
    
    NSInteger wight = 85;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, wight, frame.size.height)];
    
    label.backgroundColor = [UIColor clearColor];
    
    label.text = @"奖品兑换码：";
    
    label.font = [UIFont systemFontOfSize:14];
    
    label.textColor = COLOR_333333;
    
    [prizeView addSubview:label];
        
    CGRect rect = [NSString heightForString:prizeNum fontSize:14 andSize:CGSizeMake(SCREEN_WIDTH-30, 2000)];
    
    BOOL isMoreLines = NO;
    
    if(rect.size.width > SCREEN_WIDTH - 30-85)
    {
        rect.size.width = SCREEN_WIDTH - 30-85;
        rect.size.height = 34;
        isMoreLines = YES;
    }
    
    HTCopyableLabel *prizeNumLabel = [[HTCopyableLabel alloc] initWithFrame:CGRectMake(15+wight, 0, rect.size.width, rect.size.height)];
    
    prizeNumLabel.copyableLabelDelegate = self;
    
    prizeNumLabel.backgroundColor = [UIColor clearColor];
    
    prizeNumLabel.font = [UIFont systemFontOfSize:14];
    
    prizeNumLabel.tag = 100;
    
    prizeNumLabel.minimumScaleFactor = 0.5;
    
    prizeNumLabel.textColor = COLOR_MAIN;
    
    [prizeView addSubview:prizeNumLabel];
    
    prizeNumLabel.text = prizeNum;
    
    prizeNumLabel.numberOfLines = 2;
    
    if(isMoreLines == YES)
    {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:prizeNum];
        NSRange contentRange = {0,[content length]};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        prizeNumLabel.attributedText = content;
    }
    else
    {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, prizeNumLabel.frame.size.height-1, prizeNumLabel.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"#00baa2" alpha:0.8];
        [prizeNumLabel addSubview:lineView];
    }
    
    return prizeView;
}
#pragma mark -HTCopyableLabel Delegate
- (NSString *)stringToCopyForCopyableLabel:(HTCopyableLabel *)copyableLabel
{
    occasionalHint(@"已复制");
    
    return copyableLabel.text;
}

@end
