#import "ZWGoodsRecordDetailTableViewCell.h"
#import "NSString+NHZW.h"
#import "HTCopyableLabel.h"

@interface ZWGoodsRecordDetailTableViewCell ()<HTCopyableLabelDelegate>

/**商品信息*/
@property (weak, nonatomic) IBOutlet UILabel *goodsInfoLabel;

/**物流信息*/
@property (weak, nonatomic) IBOutlet UILabel *deliverGoodsInfoLabel;

/**发货地址*/
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

/**交易进度数据模型*/
@property (nonatomic, strong)ZWGoodsExchangeStatusModel *statusModel;

/**商品详情数据模型*/
@property (nonatomic, strong)ZWGoodsExchangeDetailModel *detailModel;

/**本tableViewCell所处在tableView里indexpath信息*/
@property (nonatomic, strong)NSIndexPath *indexPath;

@end

@implementation ZWGoodsRecordDetailTableViewCell

- (void)drawRect:(CGRect)rect
{
    if([self.reuseIdentifier isEqualToString:@"statusCell"])
    {
        if([self statusModel])
        {
            //绘制cell中间的大实心圆
            CGContextRef context = UIGraphicsGetCurrentContext(); //设置上下文
            switch ([self statusModel].exchangeStatus) {
                case NotCompleteStatus:
                {
                    CGRect aRect= CGRectMake(20, 23, 8, 8);
                    CGContextSetRGBStrokeColor(context, 107./255., 107./255., 107./255., 1.0);
                    CGContextSetLineWidth(context, 1.5);
                    CGContextAddEllipseInRect(context, aRect); //椭圆
                    CGContextDrawPath(context, kCGPathStroke);
                }
                    break;
                case SuccessStatus:
                    CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"#5fcc50"].CGColor);//线条颜色
                    CGContextFillEllipseInRect(context, CGRectMake(19, 22, 10, 10));//画实心圆,参数2:圆坐标
                    break;
                case FailStatus:
                    CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"#f26859"].CGColor);//线条颜色
                    CGContextFillEllipseInRect(context, CGRectMake(19, 22, 10, 10));//画实心圆,参数2:圆坐标
                    break;
                    
                default:
                    break;
            }
        }
        
        //下面进行画大圆之间的直线绘制
        NSInteger index = [[self detailModel].statusDetails indexOfObject:[self statusModel]];
        
        //向下画直线
        if([self detailModel].statusDetails.count > 1 && index < [self detailModel].statusDetails.count - 1)
        {
            [self drawLineWithStartPoint:35 endPoint:self.frame.size.height];
        }
        //向上画直线
        if([self detailModel].statusDetails.count > 1 && index > 0)
        {
            [self drawLineWithStartPoint:0 endPoint:19];
        }
    }
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma  mark - privrite
/**绘制直线*/
- (void)drawLineWithStartPoint:(CGFloat)startPoint
                      endPoint:(CGFloat)endPoint;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithHexString:@"#cbcbcb"] CGColor]);
    //设置线宽为1
    CGContextSetLineWidth(ctx, 1.0);
    CGContextMoveToPoint(ctx, 23.5, startPoint);
    CGContextAddLineToPoint(ctx, 23.5, endPoint); //画曲线用CGContextAddArc
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}

- (void)detailModel:(ZWGoodsExchangeDetailModel *)detailModel indexPath:(NSIndexPath *)indexPath
{
    _detailModel = detailModel;
    
    if(indexPath.section == 0)
    {
        [self addButtomLineLabel];
        
        if(indexPath.row == 0)
        {
            if([self.contentView viewWithTag:101])
            {
                [[self.contentView viewWithTag:101] removeFromSuperview];
            }
            
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
            
            lineLabel.backgroundColor = COLOR_E7E7E7;
            
            lineLabel.tag = 101;
            
            [self.contentView addSubview:lineLabel];
            
            self.goodsInfoLabel.text = [NSString stringWithFormat:@"流 水 号：%@", detailModel.serialNo];
        }
        else if (indexPath.row == 1)
        {
            self.goodsInfoLabel.text = [NSString stringWithFormat:@"商品名称：%@", detailModel.goodsName];
        }
        else
        {
            switch ([self detailModel].goodsType) {
                case virtualType:
                    self.goodsInfoLabel.text = [NSString stringWithFormat:@"发货详情: %@ %@", detailModel.customerName, detailModel.phoneNum];
                    break;
                case EntityType:
                    self.deliverGoodsInfoLabel.text = [NSString stringWithFormat:@"发货详情: %@ %@", detailModel.customerName, detailModel.phoneNum];
                    self.addressLabel.text = detailModel.address;
                    break;
                    
                default:
                    break;
            }
            
        }
    }
    else
    {
        if(indexPath.row < detailModel.statusDetails.count)
        {
            ZWGoodsExchangeStatusModel *model = detailModel.statusDetails[indexPath.row];
            [self setStatusModel:model];
            
            
            NSArray *subViews = self.contentView.subviews;
            for(UIView *view in subViews)
            {
                [view removeFromSuperview];
            }
            
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_status"]];

            bgImageView.frame = CGRectMake(35, 9, SCREEN_WIDTH - 35 - 15, self.frame.size.height - 18);

            [self.contentView addSubview:bgImageView];
            
            [self addStatusView];
        }
    }
}
/**添加物流信息界面*/
- (void)addStatusView
{
    //状态变更时间
    UILabel *dateLabel = [ZWGoodsRecordDetailTableViewCell
        initLabelWithFrame:CGRectMake(SCREEN_WIDTH-114-20, 16, 114, 15)
                 labelText:[self statusModel].statusTime
                 textColor:COLOR_848484
                      font:[UIFont systemFontOfSize:13]
             textAlignment:NSTextAlignmentRight
             numberOfLines:1];
    
    [self.contentView addSubview:dateLabel];
    
    //状态信息
    CGRect sizeframe = [NSString heightForString:[self statusModel].statusDescription fontSize:15. andSize:CGSizeMake(SCREEN_WIDTH-50-114-20, 64)];
    
    UILabel *statusLabel = [ZWGoodsRecordDetailTableViewCell
        initLabelWithFrame:CGRectMake(50, 15, SCREEN_WIDTH-50-114-20, sizeframe.size.height)
                 labelText:[self statusModel].statusDescription
                 textColor:COLOR_333333
                      font:[UIFont systemFontOfSize:15]
             textAlignment:NSTextAlignmentLeft
             numberOfLines:0];
    
    [self.contentView addSubview:statusLabel];
    
     //状态描述
    CGRect desSizeframe = [NSString heightForString:[self statusModel].statusRemark fontSize:12. andSize:CGSizeMake(SCREEN_WIDTH-50-20, MAXFLOAT)];
    
    HTCopyableLabel *desLabel = [[HTCopyableLabel alloc] initWithFrame:CGRectMake(50, statusLabel.frame.origin.y + statusLabel.frame.size.height + 3, SCREEN_WIDTH-50-20, desSizeframe.size.height)];
    
    desLabel.copyableLabelDelegate = self;
    
    desLabel.backgroundColor = [UIColor clearColor];
    
    desLabel.font = [UIFont systemFontOfSize:12];
    
    desLabel.textColor = [UIColor colorWithHexString:@"#a9a9a9"];
    
    desLabel.text = [self statusModel].statusRemark;
    
    desLabel.numberOfLines = 0;
    
    [self.contentView addSubview:desLabel];
}

//初始化一个label
+ (UILabel *)initLabelWithFrame:(CGRect)frame
                      labelText:(NSString *)text
                      textColor:(UIColor *)color
                           font:(UIFont *)font
                  textAlignment:(NSTextAlignment)alignment
                  numberOfLines:(NSInteger)linesNumber
{
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:frame];
    statusLabel.textAlignment = alignment;
    statusLabel.text = text;
    statusLabel.textColor = color;
    statusLabel.font = font;
    statusLabel.numberOfLines = linesNumber;
    
    return statusLabel;
}

//在cell的底部画细直线
- (void)addButtomLineLabel
{
    if([self.contentView viewWithTag:100])
    {
        [[self.contentView viewWithTag:100] removeFromSuperview];
    }
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, SCREEN_WIDTH, 0.5)];
    
    lineLabel.backgroundColor = COLOR_E7E7E7;
    
    lineLabel.tag = 100;
    
    [self.contentView addSubview:lineLabel];
}

#pragma mark -HTCopyableLabel Delegate
- (NSString *)stringToCopyForCopyableLabel:(HTCopyableLabel *)copyableLabel
{
    occasionalHint(@"已复制");
    
    return copyableLabel.text;
}

- (IBAction)onTouchButtonWithClickAdvertisement:(id)sender {
    if([[self cellDelegate] respondsToSelector:@selector(didClickGoodsAdWithCell:)])
    {
        [[self cellDelegate] didClickGoodsAdWithCell:self];
    }
}

@end
