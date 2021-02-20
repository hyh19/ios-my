#import "FBFlyingGiftView.h"
#import "FBGiftAnimationHelper.h"
#import "FCFileManager.h"
#import "UIImageView+AnimationCompletion.h"

@interface FBFlyingGiftView ()<CAAnimationDelegate>

/** 背景 */
@property (nonatomic, strong) UIView *backgroundView;

/** 送礼人头像 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/** 送礼人昵称 */
@property (nonatomic, strong) UILabel *nickNameLabel;

/** 礼物名称 */
@property (nonatomic, strong) UILabel *giftNameLabel;

/** 礼物图片 */
@property (nonatomic, strong) UIImageView *giftImageView;

/** 礼物数量 */
@property (nonatomic, strong) UILabel *numberLabel;

/** 礼物数字 */
@property (nonatomic, strong) NSMutableArray *numberStringArray;

@property (nonatomic, strong) UIImageView *VIPView;

@end

@implementation FBFlyingGiftView

- (void)dealloc {
    [self.giftImageView stopAnimating];
    self.giftImageView.animationImages = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgroundView];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.nickNameLabel];
        [self addSubview:self.giftNameLabel];
        [self addSubview:self.giftImageView];
        [self addSubview:self.numberLabel];
        [self addSubview:self.VIPView];
        
        UIView *superview = self;
        
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview);
        }];
        
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superview).offset(10);
            make.size.equalTo(CGSizeMake(40, 40));
            make.centerY.equalTo(superview);
        }];
        
        [self.VIPView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(13, 13));
            make.right.equalTo(self.avatarImageView);
            make.bottom.equalTo(self.avatarImageView);
        }];
        
        CGFloat maxNickWidth = 120;
        [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView.mas_right).offset(6);
            make.top.equalTo(superview).offset(5);
            make.width.lessThanOrEqualTo(@(maxNickWidth));
        }];
        
        [self.giftNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nickNameLabel.mas_left);
            make.bottom.equalTo(superview).offset(-5);
        }];
        
        [self.giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(superview.mas_right).offset(-18);
            make.size.equalTo(CGSizeMake(90, 90));
            make.centerY.equalTo(superview);
        }];
        
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.giftImageView.mas_right).offset(-25);
            make.centerY.equalTo(superview);
        }];
    }
    return self;
}

- (UIImageView *)VIPView {
    if (!_VIPView) {
        _VIPView = [[UIImageView alloc] init];
    }
    return _VIPView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.5] ;
//        _backgroundView.layer.cornerRadius = 25;
        CGRect frame = CGRectMake(0, 0, 210, 50);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(25, 25)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = frame;
        maskLayer.path = maskPath.CGPath;
        _backgroundView.layer.mask = maskLayer;
        [_backgroundView debug];
    }
    return _backgroundView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = 20;
        _avatarImageView.clipsToBounds = YES;
        [_avatarImageView debug];
    }
    return _avatarImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.textColor = COLOR_ASSIST_TEXT;
        _nickNameLabel.font = FONT_SIZE_14;
        _nickNameLabel.font = [UIFont boldSystemFontOfSize:14];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        [_nickNameLabel debug];
    }
    return _nickNameLabel;
}

- (UILabel *)giftNameLabel {
    if (!_giftNameLabel) {
        _giftNameLabel = [[UILabel alloc] init];
        _giftNameLabel.textColor = COLOR_ASSIST_BUTTON;
        _giftNameLabel.font = FONT_SIZE_13;
        _giftNameLabel.font = [UIFont boldSystemFontOfSize:13];
        _giftNameLabel.textAlignment = NSTextAlignmentCenter;
        [_giftNameLabel debug];
    }
    return _giftNameLabel;
}

- (UIImageView *)giftImageView {
    if (!_giftImageView) {
        _giftImageView = [[UIImageView alloc] init];
        _giftImageView.contentMode = UIViewContentModeScaleAspectFit;
        _giftImageView.clipsToBounds = YES;
        _giftImageView.image = kDefaultImageAvatar;
        [_giftImageView debug];
    }
    return _giftImageView;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont boldSystemFontOfSize:24];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _numberLabel;
}

- (NSMutableArray *)numberStringArray {
    if (!_numberStringArray) {
        _numberStringArray = [NSMutableArray array];
    }
    return _numberStringArray;
}

- (void)setGift:(FBGiftModel *)gift {
    _gift = gift;
    [self.avatarImageView fb_setImageWithName:self.gift.fromUser.portrait size:CGSizeMake(120, 120) placeholderImage:kDefaultImageAvatar completed:nil];
    self.nickNameLabel.text = self.gift.fromUser.nick;
    self.giftNameLabel.text = [NSString stringWithFormat:@"%@ %@", kLocalizationSendGift, self.gift.name];
    [self.giftImageView fb_setGiftImageWithName:_gift.image placeholderImage:nil completed:nil];
    
    if (self.gift.toUser.isVerifiedBroadcastor) {
        [_VIPView setImage:[UIImage imageNamed:@"public_icon_VIP"]];
    } else {
        [_VIPView setImage:nil];
    }
    
    if (self.gift.fromUser.isVerifiedBroadcastor) {
        [_VIPView setImage:[UIImage imageNamed:@"public_icon_VIP"]];
    } else {
        [_VIPView setImage:nil];
    }
    
    //【礼物动画关键业务逻辑】加载礼物动画
    // 先检查对应的礼物动画包是否已经下载到本地，如果有，则加载动画，否则，不加载
    NSString *bagName = _gift.imageZip;
    if ([bagName isValid]) {
        if ([FBGiftAnimationHelper existsZipWithGift:_gift]) {
            NSArray *imageFiles = [FBGiftAnimationHelper animationImagesWithGift:_gift];
            FBGiftAnimationInfoModel *info = [FBGiftAnimationHelper animationInfoWithGift:_gift];
            [self.giftImageView fb_startAnimatingWithImageFiles:imageFiles duration:[info.time doubleValue]/1000 repeatCount:1000 completed:^{
                //
            }];
        }
// 旧的业务逻辑
//        __weak typeof(self) wself = self;
//        [FBGiftAnimationHelper downloadZipFileForGift:_gift
//                                    completionHandler:^(NSArray *imageFiles, NSInteger animationType, NSTimeInterval duration) {
//                                        [wself.giftImageView fb_startAnimatingWithImageFiles:imageFiles
//                                                                                   duration:duration
//                                                                                repeatCount:10
//                                                                                  completed:^{
//                                                                                      //
//                                                                                  }];
//                                    }];
    }
}

- (void)setSum:(NSInteger)sum {
    _sum = sum;
    [self.numberStringArray addObject:[NSString stringWithFormat:@"%ld", self.sum]];
}

- (void)animateNumber {
    if ([self.numberStringArray count] > 0) {
        NSString *obj = [self.numberStringArray firstObject];
        self.numberLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"x %@", obj]
                                                                          attributes:@{NSStrokeColorAttributeName : [UIColor whiteColor],
                                                                                       NSForegroundColorAttributeName : COLOR_MAIN,
                                                                                       NSStrokeWidthAttributeName : @(-3.0)}];
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:5];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1];
        scaleAnimation.autoreverses = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.duration = 0.2;
        scaleAnimation.delegate = self;
        [self.numberLabel.layer addAnimation:scaleAnimation forKey:nil];
        
        if (self.doAddingNumberCallback) {
            self.doAddingNumberCallback(self.gift);
        }
        
        [self.numberStringArray removeObject:obj];
    }
    
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    // 继续播放下一个数字
    if ([self.numberStringArray count] > 0) {
        [self animateNumber];
    } else {
        // 2秒内没有新的礼物则消失，有新礼物则继续
        [self bk_performBlock:^(id obj) {
            if ([self.numberStringArray count] > 0) {
                [self animateNumber];
            } else {
                [self removeFromSuperview];
                if (self.doCompleteAction) {
                    self.doCompleteAction();
                }
            }
        } afterDelay:2];
    }
}

@end
