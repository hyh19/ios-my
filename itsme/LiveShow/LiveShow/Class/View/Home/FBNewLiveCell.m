#import "FBNewLiveCell.h"
#import "FBLevelView.h"

@interface FBNewLiveCell ()

/** 头像 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/** 等级 */
@property (nonatomic, strong) FBLevelView *levelView;

/** 距离/城市 */
@property (nonatomic, strong) UILabel   *labelDescription;

/** 是否发生了长按操作 */
@property (nonatomic) BOOL longPressed;

@end

@implementation FBNewLiveCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *superView = self;
        [self addSubview:self.avatarImageView];
        // 用户头像
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.edges.equalTo(superView);
            make.left.equalTo(superView.mas_left);
            make.top.equalTo(superView.mas_top);
            make.size.equalTo(CGSizeMake(frame.size.width, frame.size.width));
        }];
        
        CGFloat centertY = frame.size.width + (frame.size.height - frame.size.width)/2.0;
        //user level
        [superView addSubview:self.levelView];
        [self.levelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(36, 13));
            make.left.equalTo(superView.mas_left).offset(2);
            make.centerY.equalTo(superView.mas_top).offset(centertY);
        }];
        self.levelView.background.layer.cornerRadius = 13.0/2;
        
        //description
        [superView addSubview:self.labelDescription];
        [self.labelDescription mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(14);
            make.left.equalTo(self.levelView.mas_right).offset(2);
            make.right.equalTo(superView.mas_right).offset(-2);
            make.centerY.equalTo(superView.mas_top).offset(centertY);
        }];
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressAction)];
        gesture.minimumPressDuration = 5;
        [self addGestureRecognizer:gesture];
        
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.image = [UIImage imageNamed:kLogoDefaultAvatar];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        [_avatarImageView debug];
    }
    return _avatarImageView;
}

- (FBLevelView*)levelView
{
    if(nil == _levelView) {
        _levelView = [[FBLevelView alloc] initWithLevel:1];
    }
    return _levelView;
}

- (UILabel*)labelDescription
{
    if(nil == _labelDescription) {
        _labelDescription = [[UILabel alloc] init];
        _labelDescription.font = [UIFont systemFontOfSize:12];
        _labelDescription.textColor = [UIColor hx_colorWithHexString:@"#888888"];
        _labelDescription.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _labelDescription;
}

- (void)setLive:(FBLiveInfoModel *)live {
    _live = live;
    if ([_live.broadcaster.portrait isValid]) {
        [self flashImage];
    } else {
        self.avatarImageView.image = [UIImage imageNamed:kLogoDefaultAvatar];
    }
    
    NSInteger level = [live.broadcaster.ulevel integerValue];
    [self.levelView setLevel:level];
    
    //距离为空则填城市
    NSString *description = [live.distance length] ? live.distance : live.city;
    if(0 == [description length]) {
        description = kLocalizationOnMars;
    }
    self.labelDescription.text = description;
}

/** 闪烁效果 */
-(void)flashImage
{
    CGFloat width = (SCREEN_WIDTH - 4 * 2) / 3;
    width = width*2;
    
    NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@&w=%d&h=%d", kRequestURLImageScale, _live.broadcaster.portrait, (int)width, (int)width];
    __weak typeof(self) wself = self;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:[UIImage imageNamed:kLogoDefaultAvatar] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            //
        } else {
            if (image) {
                CGRect frame = wself.avatarImageView.frame;
                wself.avatarImageView.frame = CGRectMake(wself.avatarImageView.centerX, wself.avatarImageView.centerY, 0, 0);
                NSData *data = UIImagePNGRepresentation(image);
                wself.avatarImageView.image = [UIImage imageWithData:data];
                [UIView animateWithDuration:0.5 animations:^{
                    wself.avatarImageView.frame = frame;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
    }];
}

/** 响应长按操作 */
- (void)onLongPressAction {
    if (!self.longPressed) {
        self.longPressed = YES;
        __weak typeof(self) wself = self;
        [UIAlertView bk_showAlertViewWithTitle:nil
                                       message:kLocalizationPopularDelete
                             cancelButtonTitle:kLocalizationPublicCancel
                             otherButtonTitles:@[kLocalizationPublicConfirm]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (alertView.cancelButtonIndex != buttonIndex) {
                                               
                                               [FBUtility blockUser:wself.live.broadcaster.userID];
                                               
                                               if (wself.doRemoveAction) {
                                                   wself.doRemoveAction(wself.live);
                                               }
                                           }
                                           wself.longPressed = NO;
                                       }];
    }
}

@end
