#import "ZWMessageCell.h"
#import "ZWMessageModel.h"
#import "UIImage+NHZW.h"

@interface ZWMessageCell ()
{
    /**事件按钮*/
    UIButton     *_timeBtn;
    
    /**头像视图*/
    UIImageView *_iconView;
    
    /**内容按钮*/
    UIButton    *_contentBtn;
    
    /** 事件背景图片*/
    UIImageView *_timeImageView;
}

@end

@implementation ZWMessageCell

#pragma mark -init
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        // 1、创建时间按钮
        _timeBtn = [[UIButton alloc] init];
        [_timeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _timeBtn.titleLabel.font = kTimeFont;
        _timeBtn.enabled = NO;
        [_timeBtn setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_timeBtn];
        
        _timeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"times"]];
        _timeImageView.frame = CGRectMake(_timeBtn.frame.origin.x - 20, _timeBtn.frame.origin.y, 11, 11);
        [self.contentView addSubview:_timeImageView];
        
        // 2、创建头像
        _iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconView];
        
        // 3、创建内容
        _contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        _contentBtn.titleLabel.font = kContentFont;
        _contentBtn.titleLabel.numberOfLines = 0;
        
        [self.contentView addSubview:_contentBtn];
    }
    return self;
}

#pragma mark - Getter & Setter
- (void)setMessageFrame:(ZWMessageFrame *)messageFrame{
    
    _messageFrame = messageFrame;
    ZWMessageModel *message = _messageFrame.message;
    
    // 1、设置时间
    [_timeBtn setTitle:message.time forState:UIControlStateNormal];
    [_timeBtn setTitleColor:COLOR_848484 forState:UIControlStateNormal];

    _timeBtn.frame = _messageFrame.timeFrame;
    
    _timeImageView.frame =  CGRectMake(_timeBtn.frame.origin.x - 12, _timeBtn.frame.origin.y, 11, 11);
    _timeImageView.center = CGPointMake(_timeImageView.center.x, _timeBtn.center.y);
    
    // 2、设置头像
    if(message.type == MessageTypeMe)
    {
        _iconView.image = [UIImage imageNamed:@"defaultImage_me"];
        if(message.icon)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *picdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[ZWUserInfoModel sharedInstance] headImgUrl]]];
                UIImage *picimg = [UIImage imageWithData:picdata];
                if (picdata != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *newImage = [UIImage imageByScalingImage:picimg toSize:CGSizeMake(40, 40)];
                        [_iconView setImage:newImage];
                    });
                }
            });
        }
        else
        {
            _iconView.image = [UIImage imageNamed:@"defaultImage_me"];
        }
    }
    else
    {
        _iconView.image = [UIImage imageNamed:message.icon];
    }
    _iconView.layer.cornerRadius = 20;
    _iconView.layer.masksToBounds = YES;
    _iconView.frame = _messageFrame.iconFrame;
    
    // 3、设置内容
    [_contentBtn setTitle:message.content forState:UIControlStateNormal];
    _contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentLeft, kContentBottom, kContentRight);
    _contentBtn.frame = _messageFrame.contentFrame;
    
    if (message.type == MessageTypeMe) {
        _contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentRight, kContentBottom, kContentLeft);
    }
    
    UIImage *normal;
    if (message.type == MessageTypeMe) {
    
        normal = [UIImage imageNamed:@"chatto_bg_normal"];
        normal = [normal stretchableImageWithLeftCapWidth:normal.size.width * 0.5 topCapHeight:30/2];
        [_contentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [_contentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
        normal = [normal stretchableImageWithLeftCapWidth:normal.size.width * 0.5 topCapHeight:30/2];
        
    }
    
    [_contentBtn setBackgroundImage:normal forState:UIControlStateNormal];
}

@end

#import "ZWMessageModel.h"

@implementation ZWMessageFrame

#pragma mark - Getter & Setter
- (void)setMessage:(ZWMessageModel *)message{
    
    _message = message;
    
    // 0、获取屏幕宽度
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    // 1、计算时间的位置
    if (_showTime){
        
        CGFloat timeY = kMargin;
        CGSize timeSize = [_message.time sizeWithFont:kTimeFont];
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeFrame = CGRectMake(timeX, timeY, timeSize.width + kTimeMarginW, timeSize.height + kTimeMarginH);
    }
    // 2、计算头像位置
    CGFloat iconX = kMargin;
    // 2.1 如果是自己发得，头像在右边
    if (_message.type == MessageTypeMe) {
        iconX = screenW - kMargin - kIconWH;
    }
    
    CGFloat iconY = CGRectGetMaxY(_timeFrame) + kMargin;
    _iconFrame = CGRectMake(iconX, iconY, kIconWH, kIconWH);
    
    // 3、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconFrame) + kMargin;
    CGFloat contentY = iconY;
    CGSize contentSize = [_message.content sizeWithFont:kContentFont constrainedToSize:CGSizeMake(kContentW, CGFLOAT_MAX)];
    
    if (_message.type == MessageTypeMe) {
        contentX = iconX - kMargin - contentSize.width - kContentLeft - kContentRight;
    }
    
    _contentFrame = CGRectMake(contentX, contentY, contentSize.width + kContentLeft + kContentRight, contentSize.height + kContentTop + kContentBottom);
    
    // 4、计算高度
    _cellHeight = MAX(CGRectGetMaxY(_contentFrame), CGRectGetMaxY(_iconFrame))  + kMargin;
}

@end

