#import "ZWArticleAdvertisementCell.h"
#import "UIImageView+WebCache.h"
#import "ZWHotReadAndTalkTableView.h"


@implementation ZWArticleAdvertisementCell

- (void)awakeFromNib
{
    // Initialization code
    /**
     *  修改广告containview的frame
     */
    [self changeViewFrame:95.0/304.0];
    self.backgroundColor=COLOR_E7E7E7;
}

/**
 *  改变view的frame
 *  @param rate 图片的比例
 */
-(void)changeViewFrame:(CGFloat)rate
{
    CGRect rect=self.frame;
    rect.size.height=66+(SCREEN_WIDTH-16)*rate;
    self.frame=rect;
    
    rect=self.centerContentView.frame;
    rect.origin.x=0;
    rect.origin.y=8;
    rect.size.width=SCREEN_WIDTH;
    rect.size.height=self.bounds.size.height-16;
    self.centerContentView.frame=rect;
    
    rect=self.adversizeImage.frame;
    rect.origin.x=8;
    rect.origin.y=8;
    rect.size.width=SCREEN_WIDTH-16;
    rect.size.height=(SCREEN_WIDTH-16)*rate;
    self.adversizeImage.frame=rect;
    
    rect=self.advertiseTitle.frame;
    rect.origin.x=8;
    rect.origin.y=self.adversizeImage.frame.origin.y+self.adversizeImage.frame.size.height;
    rect.size.width=SCREEN_WIDTH-16-self.advertiseFlag.bounds.size.width-2;
    self.advertiseTitle.frame=rect;
    
    rect=self.advertiseFlag.frame;
    rect.origin.x=SCREEN_WIDTH-8-rect.size.width;
    rect.origin.y=self.advertiseTitle.frame.origin.y+(self.advertiseTitle.bounds.size.height-rect.size.height)/2;
    self.advertiseFlag.frame=rect;
}
-(void)updateAdvetiseViewFrame:(ZWArticleAdvertiseModel *)articeAdvertizeModel
{

    if(!articeAdvertizeModel.adversizeImgUrl || articeAdvertizeModel.adversizeImageLoadFinish)
        return;
    [self setAdvertiseImageView:articeAdvertizeModel.adversizeImgUrl];

}
//设置广告图片
-(void)setAdvertiseImageView:(NSString*)imgUrl
{
    __weak typeof(self) weakSelf=self;
    [self.adversizeImage sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"icon_banner_ad"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {

         /**调整广告图片frame*/
         ZWLog(@"load advertise image finished");
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            ZWLog(@"the error is %@",error);
                            NSObject *obj=weakSelf.superview.superview;
                            if ([obj isKindOfClass:[ZWHotReadAndTalkTableView class]])
                            {
                                if (!image)
                                {
                                    return;
                                }

                                ZWHotReadAndTalkTableView *talkTalbeView=(ZWHotReadAndTalkTableView*)obj;
                                /**下载下来的图片的比例*/
                                CGFloat rate=image.size.height/image.size.width;
                                talkTalbeView.advertiseImageRate=rate;
                                [weakSelf changeViewFrame:rate];
                                weakSelf.articeAdvertizeModel.adversizeImageLoadFinish=YES;
                                //重新加载广告secton
                                [talkTalbeView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            
                            }
                        });
         
     }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
-(void)setArticeAdvertizeModel:(ZWArticleAdvertiseModel *)articeAdvertizeModel
{
    if (articeAdvertizeModel)
    {
        [self.advertiseTitle setText:articeAdvertizeModel.adversizeTitle];
    }
    else
    {
        [self.adversizeImage  setImage:[UIImage imageNamed:@"icon_banner_ad"]];
        [self.advertiseTitle setText:@""];
    }
    //只有广告详情才显示推广标记
    if (articeAdvertizeModel.redirectType!=AdvertiseType && !articeAdvertizeModel.isAdAllianceAd)
    {
        self.advertiseFlag.hidden=YES;
    }
    else
    {
        self.advertiseFlag.hidden=NO;
    }
    _articeAdvertizeModel=articeAdvertizeModel;

}

@end
