#import "ZWPrizeWinnerListTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation ZWPrizeWinnerListTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.winnerHeadImage.layer.cornerRadius=self.winnerHeadImage.bounds.size.width/2;
    self.winnerHeadImage.clipsToBounds=YES;
    
    CGRect rect=self.upContainView.frame;
    rect.size.width=SCREEN_WIDTH-2*rect.origin.x;
    self.upContainView.frame=rect;
    
    self.upContainView.layer.borderWidth=1.0f;
    self.upContainView.layer.borderColor=COLOR_E7E7E7.CGColor;
    
    rect=self.bottomContainView.frame;
    rect.size.width=self.upContainView.bounds.size.width;
    self.bottomContainView.frame=rect;
    
    self.bottomContainView.backgroundColor=[UIColor colorWithHexString:@"fb8313"];
    self.upContainView.backgroundColor=[UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)fillContentWithDictionary:(NSDictionary*)dic
{
    if (dic)
    {
        [self.winnerHeadImage sd_setImageWithURL:[NSURL URLWithString:dic[@"image"]] placeholderImage:nil];
        self.winnerName.text=[NSString stringWithFormat:@"姓名：%@",dic[@"name"]];
        self.winnerPhoneNumber.text=[NSString stringWithFormat:@"电话：%@",dic[@"mobile"]];
        self.winnerTicketNumber.text=[NSString stringWithFormat:@"奖券号码：%@",dic[@"code"]];
        self.prizeTime.text=[NSString stringWithFormat:@"开奖时间：%@",dic[@"date"]];
        
    }
}
@end
