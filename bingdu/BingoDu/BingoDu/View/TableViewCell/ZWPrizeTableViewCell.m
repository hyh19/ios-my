//
//  ZWPrizeTableViewCell.m
//  BingoDu
//
//  Created by SouthZW on 15/7/17.
//  Copyright (c) 2015年 NHZW. All rights reserved.
//

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
    rect.size.height=(131*SCREEN_WIDTH)/320.0f;
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
    
    self.leftPrizeIntrodute.font=[UIFont systemFontOfSize:(13*SCREEN_WIDTH)/320];
    
    //left leftPrizeIntrodute的frame
    rect=self.leftPrizeTime.frame;
    rect.origin.x=0;
    rect.size.width=self.leftPrizeContainView.bounds.size.width;
    rect.size.height=(50*rect.size.width)/290;
    rect.origin.y=self.leftPrzeImageView.bounds.size.height;
    self.leftPrizeTime.frame=rect;
    
    self.leftPrizeTime.font=[UIFont systemFontOfSize:(13*SCREEN_WIDTH)/320];
    
    
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
    
    self.rightPrizeIntrodute.font=[UIFont systemFontOfSize:(13*SCREEN_WIDTH)/320];
    
    //left rightPrizeIntrodute的frame
    rect=self.rightPrizeTime.frame;
    
    rect.origin.x=0;
    rect.size.width=self.rightPrizeContainView.bounds.size.width;
    rect.size.height=(50*rect.size.width)/290;
    rect.origin.y=self.leftPrzeImageView.bounds.size.height;
    self.rightPrizeTime.frame=rect;
    
    self.rightPrizeTime.font=[UIFont systemFontOfSize:(13*SCREEN_WIDTH)/320];
    
    self.leftPrizeIntrodute.backgroundColor=[UIColor blackColor];
    self.leftPrizeIntrodute.alpha=0.5f;
    
    self.rightPrizeIntrodute.backgroundColor=[UIColor blackColor];
    self.rightPrizeIntrodute.alpha=0.5f;
    
    self.leftPrizeContainView.backgroundColor=[UIColor whiteColor];
    self.leftPrizeContainView.layer.borderWidth=0.6f;
    self.leftPrizeContainView.layer.borderColor=[UIColor colorWithHexString:@"#c9c9c9"].CGColor;
    
    self.rightPrizeContainView.backgroundColor=[UIColor whiteColor];
    self.rightPrizeContainView.layer.borderWidth=0.6f;
    self.rightPrizeContainView.layer.borderColor=[UIColor colorWithHexString:@"#c9c9c9"].CGColor;
    
    self.backgroundColor=[UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)fillPrizeData:(ZWPrizeModel*)leftPrizeModel right:(ZWPrizeModel*)rightPrizeModel leftTag:(NSInteger) leftTag rightTag:(NSInteger)rightTag;
{
    [self.leftPrzeImageView sd_setImageWithURL:[NSURL URLWithString:leftPrizeModel.prizeImageUrl] placeholderImage:nil];
    self.leftPrizeTime.text=leftPrizeModel.prizeInfo;
    self.leftPrizeIntrodute.text=leftPrizeModel.prizeName;
    self.leftPrizeContainView.tag=leftTag;
    
    
    
    [self.rightPrzeImageView sd_setImageWithURL:[NSURL URLWithString:rightPrizeModel.prizeImageUrl] placeholderImage:nil];
    self.rightPrizeTime.text=rightPrizeModel.prizeInfo;
    self.rightPrizeIntrodute.text=rightPrizeModel.prizeName;
    self.rightPrizeContainView.tag=rightTag;
}
@end
