#import "ZWBarrageItemView.h"
#import "UIView+FrameTool.h"
#import "UIImageView+WebCache.h"

@implementation ZWBarrageItemView {
    
    /**用户头像*/
    UIImageView *_avatarView;
    
    /**评论内容*/
    UILabel *_contentLabel;
}

#pragma mark -init
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setBackgroundColor:[UIColor colorWithHexString:@"#000000" alpha:0.8]];
        
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 4, 20, 20)];
        
        [_avatarView.layer setMasksToBounds:YES];
        
        [_avatarView.layer setCornerRadius:10];
        
        [self addSubview:_avatarView];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+20+8, 0, 1, 28)];
        
        [_contentLabel setFont:[UIFont systemFontOfSize:13]];
        
        [_contentLabel setTextColor:[UIColor whiteColor]];
        
        [_contentLabel setNumberOfLines:1];
        
        [self addSubview:_contentLabel];
        
        [self.layer setMasksToBounds:YES];
        
        [self.layer setCornerRadius:14];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (void)setModel:(ZWNewsTalkModel *)model
{
    if(_model != model)
    {
        _model = model;
        if(model)
        {
            [self setAvatarWithImageString:model.uIcon
                           withContent:model.comment];
        }
    }
}

- (void)setAvatarWithImageString:(NSString *)imageString
                     withContent:(NSString *)content
{
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:imageString] placeholderImage:[UIImage imageNamed:@"defaultImage_me"]];
    
    [_contentLabel setText:content];
    
    [_contentLabel sizeToFit];
    
    CGRect frame = _contentLabel.frame;
    
    frame.size.height = 28;
    
    _contentLabel.frame = frame;
    
    self.width = _contentLabel.width+5+20+8+10;
    [self fitSize];
}

#pragma mark - Praviate method
/**如果超过屏幕宽度则显示一屏，文字最后以...结尾*/
- (void)fitSize
{
    CGRect frame = _contentLabel.frame;
    if(self.width > SCREEN_WIDTH)
    {
        self.width = SCREEN_WIDTH;
        frame.size.width = SCREEN_WIDTH - 5-20-8-10;
        _contentLabel.frame = frame;
    }
}


@end
