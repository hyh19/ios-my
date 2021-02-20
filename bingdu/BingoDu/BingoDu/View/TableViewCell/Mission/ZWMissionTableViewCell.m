
#import "ZWMissionTableViewCell.h"
#import "ZWIntegralStatisticsModel.h"

@interface ZWMissionTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *lookUpPointRuleLabel;

@property (weak, nonatomic) IBOutlet UILabel *missionTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *missionDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *missionPointLabel;

@property (weak, nonatomic) IBOutlet UILabel *subItemsMissionTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *subItemsMissionPointLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *completeProgressView;

@end

@implementation ZWMissionTableViewCell

#define LINE_TAG   200

- (void)awakeFromNib {
    // Initialization code
    [[self viewWithTag:LINE_TAG] removeFromSuperview];
    
    if([self.reuseIdentifier isEqualToString:@"TodayAdvertisingRevenueSharingCell"])
    {
        [self addSubview:[self lineViewWithOriginX:0]];
    }
    
    self.missionButton.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsShowAdvertisement:(BOOL)isShowAdvertisement
{
    if(_isShowAdvertisement != isShowAdvertisement)
    {
        _isShowAdvertisement = isShowAdvertisement;
        if([self.reuseIdentifier isEqualToString:@"TodayAdvertisingRevenueSharingCell"] && self.isShowAdvertisement == NO)
        {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
            line.backgroundColor = COLOR_E7E7E7;
            
            line.tag = LINE_TAG;
            [self addSubview:line];
        }
    }
}

- (void)setRuleModel:(ZWIntegralRuleModel *)ruleModel
{
    if(ruleModel)
    {
        _ruleModel = ruleModel;
        
        [[self viewWithTag:LINE_TAG] removeFromSuperview];
        
        if([self.reuseIdentifier isEqualToString:@"TodayAdvertisingRevenueSharingCell"])
        {
            [self addSubview:[self lineViewWithOriginX:0]];
        }
        else if([self.reuseIdentifier isEqualToString:@"MissionCell"])
        {
            [self addSubview:[self lineViewWithOriginX:0]];
            
            self.missionTitleLabel.text = ruleModel.pointName;
            
            if([ruleModel.pointType integerValue] == 14)
            {
                self.missionDescriptionLabel.text = [NSString stringWithFormat: @"签到领取%@积分", [ruleModel.pointValue stringValue]];
            }
            else if([ruleModel.pointType integerValue] == 8)
            {
                self.missionDescriptionLabel.text = @"浏览文章轻松获取积分";
            }
            else
            {
                self.missionDescriptionLabel.text = [NSString stringWithFormat: @"每次奖励%@分", [ruleModel.pointValue stringValue]];
            }
            float point = [self findSinglePointWithModel:ruleModel];
            
            NSString *pointString = [self stringDisposeWithFloat:point];
            
            if([pointString componentsSeparatedByString:@"."].count == 2 && [[pointString componentsSeparatedByString:@"."][1] length] > 2)
            {
                pointString = [NSString stringWithFormat:@"%@.%@", [pointString componentsSeparatedByString:@"."][0], [[pointString componentsSeparatedByString:@"."][1] substringToIndex:2]];
            }
            
            self.missionPointLabel.text = pointString;
            
            if([ruleModel.pointType integerValue] == 8)
            {
                [self addSubview:[self lineViewWithOriginX:24]];
            }
            else
            {
                [self addSubview:[self lineViewWithOriginX:0]];
            }
        }
        else if ([self.reuseIdentifier isEqualToString:@"ReadNewsDetailCell"])
        {
            [self addSubview:[self lineViewWithOriginX:24]];
            
            self.subItemsMissionTitleLabel.text = [self subItemsMisddionTitle:ruleModel];
            
            NSString *completeTime = [self completeTimeWithModel:ruleModel];
            
            self.subItemsMissionPointLabel.text = completeTime;
            
            self.completeProgressView.progress = 0;
            
            double delayInSeconds = 0.5;
            
            __weak typeof(self) weakSelf=self;
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [weakSelf.completeProgressView setProgress:[[completeTime componentsSeparatedByString:@"/"][0] floatValue] / [[completeTime componentsSeparatedByString:@"/"][1] floatValue] animated:YES];
            });
        }
    }
}

- (UIView *)lineViewWithOriginX:(CGFloat)originX
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(originX, self.frame.size.height-0.5, SCREEN_WIDTH-originX, 0.5)];
    line.backgroundColor = COLOR_E7E7E7;
    
    line.tag = LINE_TAG;
    
    return line;
}

- (NSString *)subItemsMisddionTitle:(ZWIntegralRuleModel *)ruleModel
{
    NSString *title = @"";
    
    float count = ([ruleModel.pointMax floatValue])/([ruleModel.pointValue floatValue]);
    
    switch ([ruleModel.pointType integerValue]) {
        case 2:
        case 8:
            title = [NSString stringWithFormat:@"%@%.f篇", ruleModel.pointName, count];
            break;
        case 4:
        case 6:
            title = [NSString stringWithFormat:@"%@%.f次", ruleModel.pointName, count];
            break;
        case 7:
        case 5:
            title = [NSString stringWithFormat:@"%@%.f条", ruleModel.pointName, count];
            break;
            
        default:
            break;
    }
    
    return title;
}

- (float)findSinglePointWithModel:(ZWIntegralRuleModel *)model
{
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    
    switch ([model.pointType integerValue]) {
        case 14:
            [self.missionButton setTitle:@"签到" forState:UIControlStateNormal];
            return [obj.userSignIntegral floatValue];
            break;
            
        case 3:
            [self.missionButton setTitle:@"邀请" forState:UIControlStateNormal];
            return [obj.registration floatValue];
            break;
            
        case 9:
            [self.missionButton setTitle:@"看广告" forState:UIControlStateNormal];
            return [obj.lookAdvertising floatValue];
            break;
            
        case 10:
            [self.missionButton setTitle:@"去分享" forState:UIControlStateNormal];
            return [obj.shareExtract floatValue];
            break;
            
        case 11:
            [self.missionButton setTitle:@"去分享" forState:UIControlStateNormal];
            return [obj.shareConvert floatValue];
            break;
            
        case 8:
        {
            [self.missionButton setTitle:@"看新闻" forState:UIControlStateNormal];
            float count = 0.0;
            count += [obj.readNews floatValue];
            count += [obj.shareRead floatValue];
            count += [obj.shareByRead floatValue];
            count += [obj.review floatValue];
            count += [obj.reviewLike floatValue];
            count += [obj.reviewCoverLike floatValue];
            
            return count;
        }
            break;
            
        default:
            break;
    }
    return 0;
}

- (NSString *)completeTimeWithModel:(ZWIntegralRuleModel *)ruleModel
{
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    
    float currentPoint = 0.0;
    
    switch ([ruleModel.pointType integerValue]) {
        case 8:
            currentPoint = [obj.readNews floatValue];
            break;
        case 2:
            currentPoint = [obj.shareRead floatValue];
            break;
        case 4:
            currentPoint = [obj.shareByRead floatValue];
            break;
        case 7:
            currentPoint = [obj.review floatValue];
            break;
        case 5:
            currentPoint = [obj.reviewLike floatValue];
            break;
        case 6:
            currentPoint = [obj.reviewCoverLike floatValue];
            break;
            
        default:
            break;
    }
    return [NSString stringWithFormat:@"%.f/%.f", currentPoint/[ruleModel.pointValue floatValue], [ruleModel.pointMax floatValue]/[ruleModel.pointValue floatValue]];
}

//浮点数处理并去掉多余的0
-(NSString *)stringDisposeWithFloat:(float)floatValue
{
    NSString *str = [NSString stringWithFormat:@"%f",floatValue];
    NSInteger len = str.length;
    for (int i = 0; i < len; i++)
    {
        if (![str  hasSuffix:@"0"])
            break;
        else
            str = [str substringToIndex:[str length]-1];
    }
    if ([str hasSuffix:@"."])//避免像2.0000这样的被解析成2.
    {
        return [str substringToIndex:[str length]-1];//s.substring(0, len - i - 1);
    }
    else
    {
        return str;
    }
}

- (IBAction)onTouchButtonWithLookupPointRule:(id)sender {
    
    if([[self delegate] respondsToSelector:@selector(onTouchButtonWithLookUpPointRule)])
    {
        [[self delegate] onTouchButtonWithLookUpPointRule];
    }
}

- (IBAction)onTouchButtonWithMission:(id)sender {
    if([[self delegate] respondsToSelector:@selector(missionTableCell:didSelectedMissonWithModel:)])
    {
        [[self delegate] missionTableCell:self didSelectedMissonWithModel:self.ruleModel];
    }
}
- (IBAction)onTouchButtonWithAdvertisement:(id)sender {
    
    if([[self delegate] respondsToSelector:@selector(clickAdvertisementWithMissionTableCell:)])
    {
        [[self delegate] clickAdvertisementWithMissionTableCell:self];
    }
    
}
- (IBAction)onTouchButtonWithCloseAdvertisement:(id)sender {
    
    if([[self delegate] respondsToSelector:@selector(closeAdvertisementWithMissionTableCell:)])
    {
        [self.advertiseButton removeFromSuperview];
        
        [[self delegate] closeAdvertisementWithMissionTableCell:self];
    }
}

@end
