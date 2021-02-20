#import "FBLiveDiamondView.h"
#import "UIImage-Helpers.h"

#import "FBLoginInfoModel.h"

@interface FBLiveDiamondView ()

/** 收到的钻石总数 */
@property (nonatomic, strong) UILabel *diamondValueLabel;

/** 收到的钻石总数 */
@property (nonatomic) NSInteger diamondCount;

/** 进房间失败显示 */
@property (nonatomic, strong) UIView *erroSocketFlagView;

/** 是否已经第一次赋过值，用于当主播收到的钻石从零开始增加时弹出感谢用户的引导提示 */
@property (nonatomic) BOOL assignedValue;

@end

@implementation FBLiveDiamondView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 11;
        self.clipsToBounds = YES;
        
        UIView *superview = self;
        __weak typeof(self) weakself = self;
        
        UIImageView *redDiamond = [[UIImageView alloc] init];
        redDiamond.image = [UIImage imageNamed:@"pub_icon_giftStar"];
        [superview addSubview:redDiamond];
        [redDiamond mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(20, 20));
            make.left.equalTo(superview).offset(13);
            make.centerY.equalTo(superview);
        }];
        
        [superview addSubview:self.diamondValueLabel];
        [self.diamondValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(superview);
            make.left.equalTo(redDiamond.mas_right).offset(8);
        }];
        
        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.image = [UIImage imageNamed:@"live_icon_starArrow"];
        [superview addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(5, 10));
            make.left.equalTo(self.diamondValueLabel.mas_right).offset(8);
            make.centerY.equalTo(superview);
        }];
        
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.3];
        backgroundView.layer.cornerRadius = 11;
        [superview insertSubview:backgroundView belowSubview:redDiamond];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(superview);
            make.left.equalTo(superview).offset(-11);
            make.right.equalTo(arrow.mas_right).offset(8);
        }];
        
        //错误标识
        [superview addSubview:self.erroSocketFlagView];
        [self.erroSocketFlagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(6, 6));
            make.left.equalTo(arrow.mas_right).offset(10);
            make.centerY.equalTo(arrow.mas_centerY);
        }];
        
        // 可点击区域
        UIButton *touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [touchButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        touchButton.layer.cornerRadius = 11;
        touchButton.clipsToBounds = YES;
        [touchButton bk_addEventHandler:^(id sender) {
            if (weakself.doTapViewAction) {
                weakself.doTapViewAction();

                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                     action:@"super fans"
                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                      value:@(1)];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [superview addSubview:touchButton];
        [touchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(backgroundView);
        }];
    }
    return self;
}

- (UILabel *)diamondValueLabel {
    if (!_diamondValueLabel) {
        _diamondValueLabel = [[UILabel alloc] init];
        _diamondValueLabel.textColor = [UIColor whiteColor];
        _diamondValueLabel.font = FONT_SIZE_16;
        _diamondValueLabel.text = @"0";
        _diamondValueLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.6];
        _diamondValueLabel.shadowOffset = CGSizeMake(0, 1);
    }
    return _diamondValueLabel;
}

-(UIView*)erroSocketFlagView
{
    if(nil == _erroSocketFlagView) {
        _erroSocketFlagView = [[UIView alloc] init];
        _erroSocketFlagView.backgroundColor = [UIColor yellowColor];
        _erroSocketFlagView.layer.cornerRadius = 3;
        _erroSocketFlagView.layer.masksToBounds = YES;
        _erroSocketFlagView.hidden = YES;
    }
    return _erroSocketFlagView;
}

- (void)setDiamondCount:(NSInteger)diamondCount {
    if (self.assignedValue) {
        // 当主播收到的钻石从0开始增加时显示感谢用户的引导
        if (0 == _diamondCount && diamondCount > _diamondCount) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReceiveGiftFirstTime object:nil];
        }
    }
    
    if (!self.assignedValue) {
        self.assignedValue = YES;
    }
    
    if (diamondCount > _diamondCount) {
        _diamondCount = diamondCount;
        self.diamondValueLabel.text = [NSString stringWithFormat:@"%ld", (long)_diamondCount];
    }
}

- (void)updateDiamondCount:(NSInteger)count {
    self.diamondCount = count;
}

- (void)addDiamondCount:(NSInteger)count {
    self.diamondCount += count;
}

- (void)showSocketErrorView:(BOOL)bShow
{
    self.erroSocketFlagView.hidden = !bShow;
}

@end
