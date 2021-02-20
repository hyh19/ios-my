#import "ZWGiftButton.h"

@interface ZWGiftButton()

/**商品标题*/
@property (nonatomic, strong)UILabel *giftTitleLabel;

/**商品价格标签*/
@property (nonatomic, strong)UILabel *giftPriceLabel;

/**商品剩余标签*/
@property (nonatomic, strong)UILabel *giftRemainLabel;

/**商品图片*/
@property (nonatomic, strong)UIImageView *giftImageView;

@end

#define IMAGE_HEIGHT   85
#define IMAGE_Wight    120
#define LABEL_HIGHT    14
#define SPACING        7
#define SELF_HEIGHT    self.frame.size.height
#define SELF_WIGHT     self.frame.size.width

@implementation ZWGiftButton

- (id)initWithFrame:(CGRect)frame
         goodsModel:(ZWGoodsModel *)model
{
    self = [super init];
    if(self)
    {
        self.frame = frame;
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.userInteractionEnabled = YES;
        
        [self addSubview:[self giftImageView]];
        
        [self addSubview:[self giftTitleLabel]];
        
        [self addSubview:[self giftPriceLabel]];
        
        if(model.isOnline == YES)
        {
            [self addPrepareForSaleView];
        }
        
        [[self giftTitleLabel] setText:model.name];
        
        NSMutableAttributedString *price =
        [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.1f", [model.price floatValue]]
                                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:COLOR_E66514}];
        [price appendAttributedString:
         [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@", [NSString stringWithFormat:@"剩%@份", model.number]]
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:COLOR_848484}]];
        [[self giftPriceLabel] setAttributedText:price];
        
        [[self giftImageView] setImage:[UIImage imageNamed:@"btn_gift"]];
        
        if(model.pictureUrl)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *picdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.pictureUrl]];
                UIImage *picimg = [UIImage imageWithData:picdata];
                if (picdata != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[self giftImageView] setImage:picimg];
                    });
                }
            });
        }
    }
    return self;
}

- (UILabel *)giftPriceLabel
{
    if(!_giftPriceLabel)
    {
        _giftPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(SPACING, [self giftImageView].frame.size.height + SPACING + (SELF_HEIGHT - [self giftImageView].frame.size.height - SPACING)/5*3, SELF_WIGHT-SPACING*2, LABEL_HIGHT)];
        _giftPriceLabel.textAlignment = NSTextAlignmentLeft;
        _giftPriceLabel.minimumScaleFactor = 0.5;
        _giftPriceLabel.adjustsFontSizeToFitWidth = YES;
        _giftPriceLabel.backgroundColor = [UIColor clearColor];
    }
    return _giftPriceLabel;
}

- (UILabel *)giftTitleLabel
{
    if(!_giftTitleLabel)
    {
        _giftTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SPACING,  [self giftImageView].frame.size.height + SPACING + (SELF_HEIGHT - [self giftImageView].frame.size.height - SPACING)/5*1, self.frame.size.width - SPACING, LABEL_HIGHT)];
        _giftTitleLabel.textColor = COLOR_333333;
        _giftTitleLabel.textAlignment = NSTextAlignmentLeft;
        _giftTitleLabel.font = [UIFont systemFontOfSize:15.];
        _giftTitleLabel.backgroundColor = [UIColor clearColor];
    }
    return _giftTitleLabel;
}

- (UIImageView *)giftImageView
{
    if(!_giftImageView)
    {
        _giftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SPACING, SPACING, SELF_WIGHT - SPACING*2, (SELF_WIGHT - SPACING*2)/120 * IMAGE_HEIGHT)];
    }
    return _giftImageView;
}

- (void)addPrepareForSaleView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self giftImageView].frame.size.width, [self giftImageView].frame.size.height)];
    [view setBackgroundColor:[UIColor colorWithHexString:@"#000000" alpha:0.5]];
    [[self giftImageView] addSubview:view];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width-50, 22)];
    label.text = @"即将开售";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = COLOR_MAIN;
    label.textAlignment = NSTextAlignmentCenter;
    label.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    label.layer.cornerRadius = 3;
    label.layer.masksToBounds = YES;
    [view addSubview:label];
}

@end
