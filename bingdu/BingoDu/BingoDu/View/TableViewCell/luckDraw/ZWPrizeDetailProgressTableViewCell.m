#import "ZWPrizeDetailProgressTableViewCell.h"

@implementation ZWPrizeDetailProgressTableViewCell

- (void)awakeFromNib
{
    
    // Initialization code
    //等比例缩放视图
    CGRect rect=self.frame;
    rect.size.width=SCREEN_WIDTH;
    rect.size.height=(62*SCREEN_WIDTH)/320.0f;
    self.frame=rect;
    
    rect=self.pregressInfoLable.frame;
    rect.origin.x=0;
    rect.origin.y=(14*SCREEN_WIDTH)/320.0f;
    rect.size.width=SCREEN_WIDTH;
    rect.size.height=(16*SCREEN_WIDTH)/320.0f;
    self.pregressInfoLable.frame=rect;
    
    rect=self.pregressOutView.frame;
    rect.origin.x=(20*SCREEN_WIDTH)/320.0f;
    rect.origin.y=(33*SCREEN_WIDTH)/320.0f;
    rect.size.width=(280*SCREEN_WIDTH)/320.0f;
    rect.size.height=(12*rect.size.width)/280;
    self.pregressOutView.frame=rect;
    
    rect=self.progressInnerView.frame;
    rect.origin.x=0;
    rect.origin.y=0;
    rect.size.width=0;
    rect.size.height=self.pregressOutView.bounds.size.height;
    self.progressInnerView.frame=rect;
    
    //调整view的外观
    self.pregressOutView.layer.cornerRadius=0.5*self.pregressOutView.bounds.size.height;
    self.pregressOutView.clipsToBounds=YES;
    
    
    self.layer.borderWidth=1.0f;
    self.layer.borderColor=COLOR_E7E7E7.CGColor;
    
    self.pregressInfoLable.textColor=COLOR_00BAA2;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)fillThePregressWithModle:(ZWPrizeDetailModel*)detailModel
{
    if (detailModel)
    {
        //即时开奖
        if (detailModel.prizeType==2)
        {
            [self.pregressOutView removeFromSuperview];
            self.pregressInfoLable.text=@"购买奖券后即可查看抽奖结果";
            self.pregressInfoLable.frame=self.bounds;
            self.pregressInfoLable.textColor=[UIColor blackColor];
            return;
        }
        //人数开奖
        if (detailModel.prizeType==1)
        {
            self.pregressOutView.backgroundColor=[UIColor colorWithRed:238/255.0f green:110/255.0f  blue:80/255.0f  alpha:0.9f];
        }

        __weak typeof(self) weakSelf=self;
        self.pregressInfoLable.text=detailModel.prizeProgressMsg;
        [UIView animateWithDuration:2.0f animations:^{
            CGFloat rate=((CGFloat)detailModel.currentPrizeProgress)/detailModel.prizePregressMaxNumber;
            CGRect rect=weakSelf.progressInnerView.frame;
            rect.size.width=weakSelf.pregressOutView.bounds.size.width*rate;
            weakSelf.progressInnerView.frame=rect;
        } completion:nil];
    }
}
@end
