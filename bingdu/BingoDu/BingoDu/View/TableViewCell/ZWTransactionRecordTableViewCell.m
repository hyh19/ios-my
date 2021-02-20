#import "ZWTransactionRecordTableViewCell.h"

@interface ZWTransactionRecordTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *backGroundView;
@property (weak, nonatomic) IBOutlet UILabel *exchangeStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ZWTransactionRecordTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setExchangeModel:(ZWExchangeModel *)exchangeModel
{
    if(_exchangeModel != exchangeModel)
    {
        if(exchangeModel)
        {
            _exchangeModel = exchangeModel;
            
            self.backGroundView.layer.borderWidth = 1;
            
            [self.backGroundView.layer setBorderColor:[[UIColor colorWithWhite:0.5 alpha:0.2] CGColor]];
            
            self.timeLabel.text = [NSString stringWithFormat:@"兑换时间:%@",exchangeModel.time];
            
            self.itemTitleLabel.text = [NSString stringWithFormat:@"%@",exchangeModel.goodsName];
            
            self.itemPriceLabel.text =[NSString stringWithFormat:@"¥%.1f",[exchangeModel.goodsPrice floatValue]];
            
            CGRect frame = [NSString heightForString:self.itemPriceLabel.text fontSize:15 andSize:CGSizeMake(130, 20)];
            
            self.exchangeStatusLabel.textColor = [UIColor whiteColor];
            
            self.exchangeStatusLabel.layer.cornerRadius = 9;
            
            self.exchangeStatusLabel.layer.masksToBounds = YES;
            
            CGRect labelFrame = self.exchangeStatusLabel.frame;
            
            labelFrame.origin.x = self.itemPriceLabel.frame.origin.x + frame.size.width + 5;
            
            self.exchangeStatusLabel.font = [UIFont systemFontOfSize:13];
            
            switch (exchangeModel.exchangeStatus) {
                case failStatus:
                    
                    self.exchangeStatusLabel.text = @"失败，金额已返还";
                    
                    self.exchangeStatusLabel.backgroundColor = [UIColor colorWithHexString:@"#a4a4a4"];
                    
                    labelFrame.size.width = 125;
                    
                    if([UIScreen mainScreen].bounds.size.width == 320)
                    {
                        self.exchangeStatusLabel.font = [UIFont systemFontOfSize:10];
                        
                        labelFrame.size.width = 95;
                    }
                    
                    break;
                case succedStatus:
                    
                    self.exchangeStatusLabel.text = @"已发货";
                    
                    self.exchangeStatusLabel.backgroundColor = [UIColor colorWithHexString:@"#85cf4f"];
                    
                    labelFrame.size.width = 65;
                    
                    break;
                case processingStatus:
                    
                    self.exchangeStatusLabel.text = @"处理中";
                    
                    self.exchangeStatusLabel.backgroundColor = [UIColor colorWithHexString:@"#e86414"];
                    
                    labelFrame.size.width = 65;
                    
                    break;
                    
                default:
                    
                    self.exchangeStatusLabel.text = @"";
                    
                    self.exchangeStatusLabel.backgroundColor = [UIColor clearColor];
                    
                    self.exchangeStatusLabel.textColor = [UIColor clearColor];
                    
                    break;
            }
        
            self.exchangeStatusLabel.frame = labelFrame;
            
            self.exchangeStatusLabel.center = CGPointMake(self.exchangeStatusLabel.center.x, self.itemPriceLabel.center.y);
            
            self.itemImageView.image = [UIImage imageNamed:@"default_goods"];
            
            if(exchangeModel.goodsUrl)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *picdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:exchangeModel.goodsUrl]];
                    UIImage *picimg = [UIImage imageWithData:picdata];
                    if (picdata != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.itemImageView setImage:picimg];
                        });
                    }
                });
            }
        }
    }
}


@end
