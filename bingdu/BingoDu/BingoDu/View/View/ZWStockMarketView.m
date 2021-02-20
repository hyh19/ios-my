#import "ZWStockMarketView.h"
#import "ASIFormDataRequest.h"

@implementation ZWStockMarketView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self updataUIWithFrame:frame];
        
        [self setBackgroundColor:[UIColor colorWithHexString:@"f0f0f0"]];
        
        [self reloadPointData];
    }
    return self;
}

#pragma mark - network
/**
 *  刷新股市数据
 */
- (void)reloadPointData
{
    NSArray *urlArray = @[@"s_sh000001", @"s_sz399001", @"hkHSI"];
    
    for(int i = 0; i < 3; i++)
    {
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://hq.sinajs.cn/list=%@", urlArray[i]]]];
        
        [request setShouldAttemptPersistentConnection:NO];
        
        [request setRequestMethod:@"GET"];
        
        //成功
        [request setCompletionBlock:^{
            if ([request responseStatusCode] == 200)
            {
                NSArray *source = [[request responseString] componentsSeparatedByString:@","];
                
                if(source && source.count > 0)
                {
                    UIView *indexView = [self viewWithTag:100+i];
                    if(i < 2)
                    {
                        
                        if(source.count > 1)
                        {
                            [(UILabel *)[indexView viewWithTag:2] setText:source[1]];
                            
                            CGRect frame = [NSString heightForString:source[1] fontSize:16 andSize:CGSizeMake([indexView viewWithTag:2].frame.size.width, 20)];
                        
                            CGRect imageFrame = [indexView viewWithTag:4].frame;
                            
                            imageFrame.origin.x = frame.size.width + 5;
                            
                            [indexView viewWithTag:4].frame = imageFrame;
                        }
                        if(source.count >= 3)
                        {
                            if([source[3] floatValue] >= 0)
                            {
                                [(UILabel *)[indexView viewWithTag:3] setText:[NSString stringWithFormat:@"+%@  +%@%%", source[2], source[3]]];
                                
                                [(UILabel *)[indexView viewWithTag:3] setTextColor:[UIColor colorWithHexString:@"#c13131"]];
                                
                                [(UIImageView *)[indexView viewWithTag:4] setImage:[UIImage imageNamed:@"icon_up"]];
                                
                                [(UILabel *)[indexView viewWithTag:1] setBackgroundColor:[UIColor colorWithHexString:@"#c03231"]];
                            }
                            else
                            {
                                [(UILabel *)[indexView viewWithTag:3] setText:[NSString stringWithFormat:@"%@  %@%%", source[2], source[3]]];
                                
                                [(UILabel *)[indexView viewWithTag:3] setTextColor:[UIColor colorWithHexString:@"#488f4c"]];
                                
                                [(UIImageView *)[indexView viewWithTag:4] setImage:[UIImage imageNamed:@"icon_down-finance"]];
                                
                                [(UILabel *)[indexView viewWithTag:1] setBackgroundColor:[UIColor colorWithHexString:@"#47904c"]];
                            }
                        }
                    }
                    else
                    {
                        if(source.count > 6)
                        {
                            [(UILabel *)[indexView viewWithTag:2] setText:source[6]];
                            
                            CGRect frame = [NSString heightForString:source[6] fontSize:16 andSize:CGSizeMake([indexView viewWithTag:2].frame.size.width, 20)];
                            
                            CGRect imageFrame = [indexView viewWithTag:4].frame;
                            
                            imageFrame.origin.x = frame.size.width+5;
                            
                            [indexView viewWithTag:4].frame = imageFrame;
                        }
                        if(source.count > 8)
                        {
                            if([source[8] floatValue] >= 0)
                            {
                                [(UILabel *)[indexView viewWithTag:3] setText:[NSString stringWithFormat:@"+%@  +%@%%", source[7], source[8]]];
                                
                                [(UILabel *)[indexView viewWithTag:3] setTextColor:[UIColor colorWithHexString:@"#c13131"]];
                                
                                [(UIImageView *)[indexView viewWithTag:4] setImage:[UIImage imageNamed:@"icon_up"]];
                                
                                [(UILabel *)[indexView viewWithTag:1] setBackgroundColor:[UIColor colorWithHexString:@"#c03231"]];
                            }
                            else
                            {
                               [(UILabel *)[indexView viewWithTag:3] setText:[NSString stringWithFormat:@"%@  %@%%", source[7], source[8]]];
                                
                                [(UILabel *)[indexView viewWithTag:3] setTextColor:[UIColor colorWithHexString:@"#488f4c"]];
                                
                                [(UIImageView *)[indexView viewWithTag:4] setImage:[UIImage imageNamed:@"icon_down-finance"]];
                                
                                [(UILabel *)[indexView viewWithTag:1] setBackgroundColor:[UIColor colorWithHexString:@"#47904c"]];
                            }
                        }
                    }
                }
            }
        }];
        //失败
        [request setFailedBlock:^{
        }];
        [request startAsynchronous];
    }
}
/**
 *  更新UI界面
 */
- (void)updataUIWithFrame:(CGRect)frame
{
    NSArray *nameArray = @[@" 上证指数", @" 深证指数", @" 恒生指数"];
    for(int i = 0; i < 3; i++)
    {
        UIView *indexView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 28)/3*i + 10 +4*i, 0, (SCREEN_WIDTH-28)/3, frame.size.height)];
        indexView.backgroundColor = [UIColor clearColor];
        
        UILabel *nameLabel =
        [ZWStockMarketView initWithFrame:
                 CGRectMake(0, 5, indexView.frame.size.width, 20)
                                    font:[UIFont systemFontOfSize:14]
                                   color:[UIColor whiteColor]
                                    text:nameArray[i] tag:1];
        
        nameLabel.backgroundColor = [UIColor colorWithHexString:@"#c03231"];
        
        [indexView addSubview:nameLabel];
        
        UILabel *totlePointLabel = [ZWStockMarketView initWithFrame:CGRectMake(0, 28, indexView.frame.size.width, 20) font:[UIFont boldSystemFontOfSize:16] color:[UIColor blackColor] text:@"----" tag:2];
        
        [indexView addSubview:totlePointLabel];
        
        UILabel *increasePointLabel = [ZWStockMarketView initWithFrame:CGRectMake(0, 50, indexView.frame.size.width, 15) font:(![[UIScreen mainScreen] isiPhone6]) ? [UIFont systemFontOfSize:11] : [UIFont systemFontOfSize:12] color:[UIColor blackColor] text:@"00.00  0.0%" tag:3];
        
        [indexView addSubview:increasePointLabel];
        
        UIImage *pointImage = [UIImage imageNamed:@"icon_up"];
        
        UIImageView *pointImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, totlePointLabel.frame.origin.y, pointImage.size.width, pointImage.size.height)];
        
        pointImageView.center = CGPointMake(pointImageView.center.x, totlePointLabel.center.y);
        
        pointImageView.tag = 4;
        
        [indexView addSubview:pointImageView];
        
        indexView.tag = 100+i;
        
        [self addSubview:indexView];
    }
}

+ (UILabel *)initWithFrame:(CGRect)frame
                      font:(UIFont *)font
                     color:(UIColor *)color
                      text:(NSString *)text
                       tag:(NSInteger)tag
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    label.textColor = color;
    label.text = text;
    label.tag = tag;
    label.minimumScaleFactor = 0.5;
    label.adjustsFontSizeToFitWidth = YES;
    
    return label;
}

@end
