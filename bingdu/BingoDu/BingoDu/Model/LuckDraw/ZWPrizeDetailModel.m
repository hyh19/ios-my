#import "ZWPrizeDetailModel.h"
#import "NSString+NHZW.h"
@implementation ZWPrizeDetailModel
+(id)prizeDetailObjByDictionary:(NSDictionary *)dictionary
{
    ZWPrizeDetailModel *model=[[ZWPrizeDetailModel alloc] init];
    [model setPrizeId:[dictionary[@"id"] integerValue]];
    [model setIsCanPrize:[dictionary[@"accept"] boolValue]];
    [model setPrizeImageArray:dictionary[@"images"]];
    [model setPrizeIntroduction:dictionary[@"introduction"]];
    [model setPrizeJoinNumber:[dictionary[@"join"] integerValue]];
    [model setPrizePregressMaxNumber:[dictionary[@"pbMax"] integerValue]];
    [model setPrizeProgressMsg:dictionary[@"pbMsg"]];
    [model setPrizePrice:[dictionary[@"price"] floatValue]];
    [model setCurrentPrizeProgress:[dictionary[@"progress"] integerValue]];
    [model setPrizeRule:dictionary[@"rule"]];
    [model setCurrentPrizeStatues:[dictionary[@"status"] integerValue]];
    [model setIllegalityUserTip:dictionary[@"tips"]];
    [model setPrizeName:dictionary[@"title"]];
    [model setPrizeType:[dictionary[@"type"] integerValue]];
    [model setIsVirtualPrize:[dictionary[@"virtual"] boolValue]];
    [model setPrizewinners:dictionary[@"winLists"]];
    [model caculateSectionHeight];
    [model setUserAllMoney:[dictionary[@"balance"] floatValue]];

    return model;
}
//计算各section的高度
-(void)caculateSectionHeight
{
    CGFloat rate=SCREEN_WIDTH/320.0f;
    self.progressSectionHeight=62*rate;
    CGFloat dis=10;
    if (((int)[UIScreen mainScreen].bounds.size.width)==320) {
        dis=14;
    }
    CGRect introRect=[NSString heightForString:self.prizeIntroduction fontSize:13 andSize:CGSizeMake(294*rate, MAXFLOAT)];
   
    
    CGRect oneLineRect=[NSString heightForString:@"你好，中国" fontSize:13 andSize:CGSizeMake(294*rate, MAXFLOAT)];
    
    if (introRect.size.height>3*oneLineRect.size.height)
    {
        self.isMorePrizeIndtroduction=YES;
        self.prizeIntrodutionFactSectionHeight=15*rate+dis+12*rate+introRect.size.height+6*rate+12+8*rate;
        self.prizeIntrodutionSectionHeight=15*rate+dis+12*rate+3*oneLineRect.size.height+6*rate+12+8*rate;
    }
    else
    {
        self.isMorePrizeIndtroduction=NO;
        self.prizeIntrodutionSectionHeight=15*rate+dis+12*rate+13*rate+introRect.size.height;
    }
    
    CGRect ruleRect=[NSString heightForString:self.prizeRule fontSize:13 andSize:CGSizeMake(294*rate, MAXFLOAT)];
    
    self.prizeRuleSectionHeight=17*rate+dis+12*rate+13*rate+ruleRect.size.height;
    
    if(self.prizeType==2)
    {
      self.prizeNameListSectionHeight=17*rate+25+12*rate+34;
    }
    else
    {
        NSInteger itemCount=[self.prizewinners count];
        if (itemCount<=0)
        {
            self.prizeNameListSectionHeight=17*rate+25+12*rate+38
            ;
            return;
        }
        //注意符合的优先级
       int lineNum=(int)(itemCount/3)+(int)(itemCount%3>0?1:0);
       self.prizeNameListSectionHeight=17*rate+28+12*rate+lineNum*(30*rate+10*rate);
    }
    
}
@end
