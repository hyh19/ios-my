#import "ZWGoodsExchangeRecordTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface ZWGoodsExchangeRecordTableViewCell ()

/**已消费lebael*/
@property (weak, nonatomic) IBOutlet UILabel *consumeLabel;

/**商品图标imageView*/
@property (weak, nonatomic) IBOutlet UIImageView *goodsIconImageView;

/**商品名称*/
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;

/**交易时间以及交易状态label*/
@property (weak, nonatomic) IBOutlet UILabel *exchangeTimeAndStatusLabel;

/**查看详情按钮*/
@property (weak, nonatomic) IBOutlet UIButton *checkDetailButton;

/**商品价格*/
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceLabel;

/**商品数据模型*/
@property (nonatomic, strong)ZWGoodsExchangeRecordModel *recordModel;

/**本tableViewCell所处在tableView里indexpath信息*/
@property (nonatomic, strong)NSIndexPath *indexPath;

@end

@implementation ZWGoodsExchangeRecordTableViewCell
- (void)drawRect:(CGRect)rect
{
    //去掉第一根线
    if(self.indexPath.section == 0 && self.indexPath.row == 0)
    {
        if(self.subviews.count == 4)
        {
            UIView *view = [[self subviews] lastObject];

            [view removeFromSuperview];
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
- (void)recordModel:(ZWGoodsExchangeRecordModel *)recordModel indexPath:(NSIndexPath *)indexPath
{
    if(_indexPath != indexPath)
    {
        _indexPath = indexPath;
    }
    
    if(_recordModel != recordModel)
    {
        _recordModel = recordModel;
    }
    
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        if([self.contentView viewWithTag:100])
        {
            [[self.contentView viewWithTag:100] removeFromSuperview];
        }
        if(recordModel.goodsExchangeRecordList.count > 0)
        {
        
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, SCREEN_WIDTH, 0.5)];
            
            lineLabel.backgroundColor = COLOR_E7E7E7;
            
            lineLabel.tag = 100;
            
            [self.contentView addSubview:lineLabel];
        }
        
        self.backgroundColor = COLOR_F8F8F8;
        
        NSMutableAttributedString *consumeAttributed =
        [[NSMutableAttributedString alloc] initWithString:@"已消费:"
                                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:COLOR_333333}];
        [consumeAttributed appendAttributedString:
         [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %.2f",[recordModel.hisCash floatValue]]
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#fd8313"]}]];
        
        [consumeAttributed appendAttributedString:
         [[NSAttributedString alloc] initWithString:@"元"
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#fd8313"]}]];
        
        [self.consumeLabel setAttributedText:consumeAttributed];
    }
    else
    {
        ZWGoodsExchangeInfoModel *model = [recordModel.goodsExchangeRecordList objectAtIndex:indexPath.section];
        
        self.goodsNameLabel.text = model.goodsName;
        
        self.goodsPriceLabel.text = [NSString stringWithFormat:@"%.2f元", [model.goodsPrice floatValue]];
        
        [self.goodsIconImageView sd_setImageWithURL:[NSURL URLWithString:model.goodsImageUrl] placeholderImage:[UIImage imageNamed:@"icon_lottery"]];
        
        UIColor *statusColor = [UIColor clearColor];
        NSString *status = @"";
        switch (model.exchangeStatus) {
            case failStatus:
                statusColor = [UIColor colorWithHexString:@"#e75c46"];
                status = @"失败";
                break;
                
            case succedStatus:
                statusColor = [UIColor colorWithHexString:@"#46b03f"];
                status = @"成功";
                break;
                
            case queueStatus:
                
            case processingStatus:
                statusColor = COLOR_848484;
                status = @"处理中";
                break;
                
            default:
                break;
        }
        
        NSMutableAttributedString *statusAtribute =
        [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",model.exchangeTime]
                                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:COLOR_848484}];
        [statusAtribute appendAttributedString:
         [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"    %@",status]
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:statusColor}]];
        
        [self.exchangeTimeAndStatusLabel setAttributedText:statusAtribute];
    }
}

@end
