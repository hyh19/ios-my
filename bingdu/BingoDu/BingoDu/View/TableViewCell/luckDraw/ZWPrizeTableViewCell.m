#import "ZWPrizeTableViewCell.h"
#import "UIImageView+WebCache.h"
@implementation ZWPrizeTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    //conview的frame
    
    //等比例缩放视图
    CGRect rect=self.frame;
    rect.size.width=SCREEN_WIDTH;
    rect.size.height=(135*SCREEN_WIDTH)/320.0f;
    self.frame=rect;
    
    rect=self.leftPrizeContainView.frame;
    rect.origin.x=(10*SCREEN_WIDTH)/320.0f;
    rect.origin.y=0.0f;
    rect.size.width=(145*SCREEN_WIDTH)/320.0f;
    rect.size.height=(250*rect.size.width)/290;
    self.leftPrizeContainView.frame=rect;
    
    //left imageview的frame
    rect=self.leftPrzeImageView.frame;
    rect.origin.x=0;
    rect.origin.y=0.0f;
    rect.size.width=self.leftPrizeContainView.bounds.size.width;
    rect.size.height=(200*rect.size.width)/290;
    self.leftPrzeImageView.frame=rect;
    
    //left leftPrizeIntrodute的frame
    rect=self.leftPrizeIntrodute.frame;
    rect.origin.x=0;
    rect.size.width=self.leftPrizeContainView.bounds.size.width;
    rect.size.height=(50*rect.size.width)/290;
    rect.origin.y=self.leftPrzeImageView.bounds.size.height-rect.size.height;
    self.leftPrizeIntrodute.frame=rect;
    
    _leftBlackView.frame=_leftPrizeIntrodute.frame;

    
    //left leftPrizeIntrodute的frame
    rect=self.leftPrizeTime.frame;
    rect.origin.x=0;
    rect.size.width=self.leftPrizeContainView.bounds.size.width;
    rect.size.height=(50*rect.size.width)/290;
    rect.origin.y=self.leftPrzeImageView.bounds.size.height;
    self.leftPrizeTime.frame=rect;

    
    
    rect=self.rightPrizeContainView.frame;
    rect.origin.x=(165*SCREEN_WIDTH)/320.0f;
    rect.origin.y=0.0f;
    rect.size.width=(145*SCREEN_WIDTH)/320.0f;
    rect.size.height=(250*rect.size.width)/290;
    self.rightPrizeContainView.frame=rect;
    
    //right imageview的frame
    rect=self.rightPrzeImageView.frame;
    rect.origin.x=0;
    rect.origin.y=0.0f;
    rect.size.width=self.rightPrizeContainView.bounds.size.width;
    rect.size.height=(200*rect.size.width)/290;
    self.rightPrzeImageView.frame=rect;
    
    
    //left rightPrizeIntrodute的frame
    rect=self.rightPrizeIntrodute.frame;
    rect.origin.x=0;
    rect.size.width=self.rightPrizeContainView.bounds.size.width;
    rect.size.height=(50*rect.size.width)/290;
    rect.origin.y=self.leftPrzeImageView.bounds.size.height-rect.size.height;
    self.rightPrizeIntrodute.frame=rect;
    
    _rightBlackVIew.frame=_rightPrizeIntrodute.frame;
    //动态设置字体大小  暂时别删
   // self.rightPrizeIntrodute.font=[UIFont systemFontOfSize:(13*SCREEN_WIDTH)/320];
    
    //left rightPrizeIntrodute的frame
    rect=self.rightPrizeTime.frame;
    
    rect.origin.x=0;
    rect.size.width=self.rightPrizeContainView.bounds.size.width;
    rect.size.height=(50*rect.size.width)/290;
    rect.origin.y=self.leftPrzeImageView.bounds.size.height;
    self.rightPrizeTime.frame=rect;
      //动态设置字体大小  暂时别删
  //  self.rightPrizeTime.font=[UIFont systemFontOfSize:(13*SCREEN_WIDTH)/320];
    
    self.leftPrizeIntrodute.backgroundColor=[UIColor clearColor];
    self.rightPrizeIntrodute.backgroundColor=[UIColor clearColor];
    self.leftPrizeIntrodute.alpha=1;
    self.rightPrizeIntrodute.alpha=1;
   
    
    self.leftPrizeContainView.backgroundColor=[UIColor whiteColor];
    self.leftPrizeContainView.layer.borderWidth=0.6f;
    self.leftPrizeContainView.layer.borderColor=[UIColor colorWithHexString:@"#c9c9c9"].CGColor;
    
    self.rightPrizeContainView.backgroundColor=[UIColor whiteColor];
    self.rightPrizeContainView.layer.borderWidth=0.6f;
    self.rightPrizeContainView.layer.borderColor=[UIColor colorWithHexString:@"#c9c9c9"].CGColor;
    
    self.backgroundColor=[UIColor clearColor];
    
    
    self.leftBlackView.alpha=0.5f;
    self.leftBlackView.backgroundColor=[UIColor blackColor];
    
    self.rightBlackVIew.alpha=0.5f;
    self.rightBlackVIew.backgroundColor=[UIColor blackColor];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)fillPrizeData:(ZWPrizeModel*)leftPrizeModel right:(ZWPrizeModel*)rightPrizeModel leftTag:(NSInteger) leftTag rightTag:(NSInteger)rightTag;
{
    [self.leftPrzeImageView sd_setImageWithURL:[NSURL URLWithString:leftPrizeModel.prizeImageUrl] placeholderImage:nil];
    self.leftPrizeTime.text=[NSString stringWithFormat:@"  %@",leftPrizeModel.prizeInfo];
    self.leftPrizeIntrodute.text=[NSString stringWithFormat:@"  %@",leftPrizeModel.prizeName];

    self.leftPrizeContainView.tag=leftTag;
    
    if (rightPrizeModel)
    {
        self.rightPrizeContainView.hidden=NO;
        [self.rightPrzeImageView sd_setImageWithURL:[NSURL URLWithString:rightPrizeModel.prizeImageUrl] placeholderImage:nil];
        self.rightPrizeTime.text=[NSString stringWithFormat:@"  %@",rightPrizeModel.prizeInfo];
        self.rightPrizeIntrodute.text=[NSString stringWithFormat:@"  %@",rightPrizeModel.prizeName];
        self.rightPrizeContainView.tag=rightTag;
    }
    else
    {
        self.rightPrizeContainView.hidden=YES;
    }
    

}
@end
