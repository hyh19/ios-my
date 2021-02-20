//
//  FBLiveEndView.m
//  LiveShow
//
//  Created by lgh on 16/3/22.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLiveEndView.h"
#import "FBLiveStreamNetworkManager.h"
#import "UIImage-Helpers.h"

#define FONT_LIVESTATUS [UIFont systemFontOfSize:30]

@interface FBLiveEndView ()
/** 头像 */
@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UIView    *avatarBorderView;

/** 背景图像 */
@property (nonatomic, strong) UIImageView *bkgImageView;

/** 背景用户大头像 */
@property (nonatomic, strong) UIImageView *avatarBkgImageView;
/** 结束图标 */
@property (nonatomic, strong) UIImageView *iconView;
/** 数字背景 */
@property (nonatomic, strong) UIImageView *numberBkgView;

/** 名字 */
@property (nonatomic, strong) UILabel *nameLabel;
/** 直播状态 */
@property (nonatomic, strong) UILabel *liveStatus;

/** 外部提示 */
@property (nonatomic, strong) UILabel *notifyLabel;

/** 开播时间 */
@property (nonatomic, strong) UIView *timeCountView;

@property (nonatomic, strong) UILabel *timeCountLabel;

/** 观看 */
@property (nonatomic, strong) UIView *viewerView;

/** 金币 */
@property (nonatomic, strong) UIView *coinsView;
/** 人数 */
@property (nonatomic, strong) UILabel *viewerCount;
/** 新增亲密度 */
@property (nonatomic, strong) UILabel *coinsCount;
/** 关注状态 */
@property (nonatomic, strong) UIButton *followButton;
/** 返回首页 */
@property (nonatomic, strong) UIButton *backbutton;
/** 保存提示 */
@property (nonatomic, strong) UILabel *saveTipLabel;

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *live_id;

@property (nonatomic, assign)FBLiveEndViewType type;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBLiveEndView


- (instancetype)initWithFrame:(CGRect)frame liveid:(NSString*)live_id type:(FBLiveEndViewType)type showNotSave:(BOOL)bShowSave  isNetworkError:(BOOL)bNetWorkError
{
    if (self = [super initWithFrame:frame]) {
        self.live_id = live_id;
        self.type = type;
        self.fromType = kLiveRoomFromTypeUnknown;
        
        NSAssert(type == 0 || type == 1, @"type出错");
        self.backgroundColor = [UIColor hx_colorWithHexString:@"#000000"];
        [self addSubview:self.avatarBkgImageView];
        [self addSubview:self.bkgImageView];
        [self addSubview:self.avatarBorderView];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.iconView];
        [self addSubview:self.timeCountView];
        [self addSubview:self.numberBkgView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.liveStatus];
        [self addSubview:self.notifyLabel];
        [self addSubview:self.backbutton];
        
        CGFloat xScale = [UIScreen mainScreen].bounds.size.width/375.0;
        CGFloat infoW = 323*xScale;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        [self.avatarBkgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.bounds.size);
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        [self.bkgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        NSString *statusString = bNetWorkError ? kLocalizationNetBroken : kLocalizationLiveEnd;
        self.liveStatus.text = statusString;
        
        CGFloat statusWidth = [self getStatusWidth:statusString];
        CGFloat iconX = (self.bounds.size.width - statusWidth - 28 - 10)/2.0;
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(28, 30));
            make.left.equalTo(iconX);
            if(480 == screenHeight) {
                make.top.equalTo(30);
            } else if(568 == screenHeight) {
                make.top.equalTo(50);
            } else {
                make.top.equalTo(85);
            }
            
        }];
        
        [self.liveStatus mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(25);
            make.left.equalTo(self.iconView.mas_right).offset(10);
            make.top.equalTo(self.iconView.mas_top).offset(5);
        }];
        
        [self.notifyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(infoW);
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.iconView.mas_bottom).offset(12);
        }];
        
        [self.timeCountView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(SCREEN_WIDTH);
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.iconView.mas_bottom).offset(12);
        }];
        
        [self.avatarBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(110, 110));
            make.centerX.equalTo(self.mas_centerX);
            
            
            if(480 == screenHeight) {
                make.top.equalTo(self.iconView.mas_bottom).offset(30);
            } else if(568 == screenHeight) {
                make.top.equalTo(self.iconView.mas_bottom).offset(50);
            } else {
                make.top.equalTo(self.iconView.mas_bottom).offset(80);
            }
        }];
        
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(100, 100));
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.avatarBorderView.mas_top).offset(5);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarBorderView.mas_bottom).offset(20);
            make.centerX.equalTo(self.mas_centerX);
        }];
        
        [self.numberBkgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(300, 72));
            make.top.equalTo(self.nameLabel.mas_bottom).offset(35);
            make.centerX.equalTo(self.mas_centerX);
        }];
        self.numberBkgView.hidden = YES;
        
        if (type == FBLiveEndViewTypeMine) {
            
            [self.numberBkgView addSubview:self.viewerView];
            [self.viewerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(100, 72));
                make.top.equalTo(self.numberBkgView.mas_top);
                make.right.equalTo(self.numberBkgView.mas_centerX);
            }];
            
            [self.numberBkgView addSubview:self.coinsView];
            [self.coinsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(100, 72));
                make.top.equalTo(self.numberBkgView.mas_top);
                make.left.equalTo(self.viewerView.mas_right);
            }];
            
            //spliter
            UIView *vSpliter = [[UIView alloc] init];
            vSpliter.backgroundColor = [UIColor whiteColor];
            [self.numberBkgView addSubview:vSpliter];
            [vSpliter mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(0.5, 20));
                make.center.equalTo(self.numberBkgView);
            }];
            
            [self.backbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_centerX);
                make.size.equalTo(CGSizeMake(250, 45));
                if(480 == screenHeight) {
                    make.bottom.equalTo(self.numberBkgView.mas_bottom).offset(80);
                } else {
                    make.bottom.equalTo(self.numberBkgView.mas_bottom).offset(110);
                }
            }];

            if(bShowSave) {
                [self addSubview:self.saveTipLabel];
                
                [self.saveTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(20);
                    make.centerX.equalTo(self.mas_centerX);
                    make.top.equalTo(self.backbutton.mas_bottom).offset(30);
                }];
            }

        } else {
            
            [self.numberBkgView addSubview:self.viewerView];
            [self.viewerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(100, 72));
                make.center.equalTo(self.viewerView.center);
            }];
            
            [self addSubview:self.followButton];
            [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_centerX);
                make.size.equalTo(CGSizeMake(250, 45));
                if(480 == screenHeight ||
                   568 == screenHeight) {
                    make.top.equalTo(self.numberBkgView.mas_bottom).offset(20);
                } else {
                    make.top.equalTo(self.numberBkgView.mas_bottom).offset(45);
                }
            }];
            
            [self.backbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_centerX);
                make.size.equalTo(CGSizeMake(250, 45));
                make.top.equalTo(self.followButton.mas_bottom).offset(20);
            }];
        }
        
        [self fetchData:live_id];
        
        self.enterTime = [[NSDate date] timeIntervalSince1970];
    }

 
    return self;
}

-(void)fetchData:(NSString*)live_id
{
    __weak typeof(self)wSelf = self;
    [[FBLiveStreamNetworkManager sharedInstance] getLiveEndData:live_id success:^(id result) {
        [wSelf onResultData:result];
    } failure:^(NSString *errorString) {
        NSLog(@"fetch live end data failure");
    } finally:^{
        
    }];
}

-(void)onResultData:(NSDictionary*)result
{
    @try {
        self.numberBkgView.hidden = NO;
        
        NSInteger viewNum = [result[@"viewd_num"] integerValue];
        NSInteger goldNum = [result[@"gold_num"] integerValue];
        
        NSString* strViewNum = [NSString stringWithFormat:@"%ld", (long)viewNum];
        ;
        _viewerCount.text = strViewNum;
        

        NSString* strGoldNum = [NSString stringWithFormat:@"%ld", (long)goldNum];
        _coinsCount.text = strGoldNum;
        
        //开播结束，累计观看人数满100人则标记达到开播条件
        if(FBLiveEndViewTypeMine == self.type && viewNum >= 100) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:@"1" forKey:kUserDefaultsEnableScoringGuide];
            [defaults synchronize];
        }
    }
    @catch (NSException *exception) {
        
    }
}

- (void)update:(FBUserInfoModel*)model bkgImage:(UIImage*)bkgImage
{
    self.uid = model.userID;
    
    [self.avatarImageView fb_setImageWithName:model.portrait size:CGSizeMake(250, 250) placeholderImage:kDefaultImageAvatar completed:nil];
    
    if(nil == bkgImage) {
        if(model.avatarImage) {
            self.avatarBkgImageView.image = model.avatarImage;
        } else {
            [self.avatarBkgImageView fb_setImageWithName:model.portrait size:[UIScreen mainScreen].bounds.size placeholderImage:nil completed:^{
                
            }];
        }
    } else {
        self.avatarBkgImageView.image = bkgImage;
    }
    
    NSString* nick = model.nick;
    if(0 == [nick length]) {
        nick = kDefaultNickname;
    }
    self.nameLabel.text = nick;
    
    __weak typeof(self)wSelf = self;
    [[FBProfileNetWorkManager sharedInstance] getRelationWithUserID:self.uid success:^(id result) {
        NSString *relation = result[@"relation"];
        if ([relation isKindOfClass:[NSString class]] && [relation isValid]) {
            // 已关注
            if ([relation isEqualToString:@"following"]) {
                [wSelf updateFollowButtonWithFollowed:YES];
                // 相互关注
            } else if ([relation isEqualToString:@"friend"]) {
                [wSelf updateFollowButtonWithFollowed:YES];
            } else {
                // 未关注
                [wSelf updateFollowButtonWithFollowed:NO];
            }
        } else {
            // 未知状态
            [wSelf updateFollowButtonWithFollowed:NO];
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

- (void)updateTimeString:(NSString*)timeString
{
    if([timeString length]) {
        self.timeCountView.hidden = NO;
        self.timeCountLabel.text = timeString;
    }
}

- (void)updateALertTips:(NSString*)tips
{
    self.notifyLabel.text = tips;
}

- (UILabel *)coinsCount {
    if (!_coinsCount) {
        _coinsCount = [[UILabel alloc] init];
        [_coinsCount sizeToFit];
        _coinsCount.textColor = [UIColor hx_colorWithHexString:@"#50e3ce"];
        _coinsCount.font = [UIFont systemFontOfSize:30];
        _coinsCount.textAlignment = NSTextAlignmentCenter;
    }
    return _coinsCount;
}

-(UIView*)viewerView
{
    if(!_viewerView) {
        _viewerView = [[UIView alloc] init];
        
        [_viewerView addSubview:self.viewerCount];
        [self.viewerCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(32);
            make.centerX.equalTo(_viewerView.mas_centerX);
            make.top.equalTo(_viewerView.mas_top).offset(12);
        }];
        
        //labelpeople
        UILabel *peopleLabel = [[UILabel alloc] init];
        peopleLabel.text = kLocalizationLabelWatching;
        peopleLabel.textColor = [UIColor hx_colorWithHexString:@"#FFFFFF" alpha:0.8];
        peopleLabel.font = [UIFont systemFontOfSize:15];
        [peopleLabel sizeToFit];
        peopleLabel.textAlignment = NSTextAlignmentCenter;
        [_viewerView addSubview:peopleLabel];
        [peopleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(16);
            make.centerX.equalTo(_viewerView.mas_centerX);
            make.bottom.equalTo(_viewerView.mas_bottom).offset(-12);
        }];
    }
    return _viewerView;
}

-(UIView*)coinsView
{
    if(!_coinsView) {
        _coinsView = [[UIView alloc] init];
        
        [_coinsView addSubview:self.coinsCount];
        [self.coinsCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(32);
            make.centerX.equalTo(_coinsView.mas_centerX);
            make.top.equalTo(_coinsView.mas_top).offset(12);
        }];
        
        //diamondLabel
        UILabel *diamondLabel = [[UILabel alloc] init];
        diamondLabel.text = kLocalizationRecieved;
        diamondLabel.textColor = [UIColor hx_colorWithHexString:@"#FFFFFF" alpha:0.8];
        diamondLabel.font = [UIFont systemFontOfSize:15];
        [diamondLabel sizeToFit];
        diamondLabel.textAlignment = NSTextAlignmentCenter;
        [_coinsView addSubview:diamondLabel];
        [diamondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(16);
            make.centerX.equalTo(_coinsView.mas_centerX);
            make.bottom.equalTo(_coinsView.mas_bottom).offset(-12);
        }];
    }
    return _coinsView;
}

- (UILabel *)viewerCount {
    if (!_viewerCount) {
        _viewerCount = [[UILabel alloc] init];
        [_viewerCount sizeToFit];
        _viewerCount.textColor = [UIColor hx_colorWithHexString:@"#50e3ce"];
        _viewerCount.font = [UIFont systemFontOfSize:30];
        _viewerCount.textAlignment = NSTextAlignmentCenter;
    }
    return _viewerCount;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [[UIButton alloc] init];
        _followButton.layer.cornerRadius = 22.5;
        _followButton.layer.masksToBounds = YES;
        [_followButton addTarget:self action:@selector(followStatus:) forControlEvents:UIControlEventTouchUpInside];
        [_followButton setTitle:kLocalizationButtonFollow forState:UIControlStateNormal];
        [_followButton setTitle:kLocalizationButtonFollowing forState:UIControlStateSelected];
        [_followButton setTitleColor:[UIColor hx_colorWithHexString:@"#444444"] forState:UIControlStateNormal];
        [_followButton setTitleColor:[UIColor hx_colorWithHexString:@"#cccccc"] forState:UIControlStateSelected];
        [_followButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
  
        [_followButton setBackgroundImage:[UIImage imageWithColor:[UIColor hx_colorWithHexString:@"#ffffff"]] forState:UIControlStateNormal];
        _followButton.tintColor = [UIColor clearColor];
        _followButton.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _followButton;
}

- (UIButton *)backbutton {
    if (!_backbutton) {
        _backbutton = [[UIButton alloc] init];
        _backbutton.layer.cornerRadius = 22.5;
        _backbutton.layer.masksToBounds = YES;
        _backbutton.layer.borderWidth = 1.0;
        _backbutton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_backbutton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [_backbutton setTitle: NSLocalizedString(@"room_live_finish_backtoindex", @"返回首页")forState:UIControlStateNormal];
        [_backbutton setBackgroundColor:[UIColor clearColor]];
        [_backbutton setTitleColor:[UIColor hx_colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        _backbutton.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _backbutton;
}

-(UILabel*)saveTipLabel
{
    if(nil == _saveTipLabel) {
        _saveTipLabel = [[UILabel alloc] init];
        _saveTipLabel.font = [UIFont systemFontOfSize:12];
        _saveTipLabel.textColor = [UIColor whiteColor];
        _saveTipLabel.textAlignment = NSTextAlignmentCenter;
        _saveTipLabel.text = kLocalizationReplayTip;
        [_saveTipLabel sizeToFit];
    }
    return _saveTipLabel;
}

- (UILabel *)liveStatus {
    if (!_liveStatus) {
        _liveStatus = [[UILabel alloc] init];
        [_liveStatus sizeToFit];
        _liveStatus.font = FONT_LIVESTATUS;
        _liveStatus.textColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.9];
    }
    return _liveStatus;
}

-(UIView*)timeCountView
{
    if(nil == _timeCountView) {
        _timeCountView = [[UIView alloc] init];
        
        CGFloat iconW = 18;
        CGFloat labelW = 70;
        CGFloat spacing = 10;
        CGFloat offset = (SCREEN_WIDTH - iconW - labelW - spacing)/2.0;
        
        UIImageView *iconView =[[UIImageView alloc] init];
        iconView.image = [UIImage imageNamed:@"icon_time"];
        [_timeCountView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(iconW, iconW));
            make.left.equalTo(_timeCountView.mas_left).offset(offset);
            make.top.equalTo(_timeCountView.mas_top);
        }];
        
        [_timeCountView addSubview:self.timeCountLabel];
        [self.timeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(labelW, 14));
            make.left.equalTo(iconView.mas_right).offset(spacing);
            make.top.equalTo(_timeCountView.mas_top).offset(2);
        }];
        
        _timeCountView.hidden = YES;
        
    }
    return _timeCountView;
}

-(UILabel*)timeCountLabel
{
    if(nil == _timeCountLabel) {
        _timeCountLabel = [[UILabel alloc] init];
        _timeCountLabel.font = [UIFont systemFontOfSize:12];
        _timeCountLabel.textColor = [UIColor whiteColor];
    }
    return _timeCountLabel;
}

- (UILabel*)notifyLabel
{
    if(nil == _notifyLabel) {
        _notifyLabel = [[UILabel alloc] init];
        _notifyLabel.numberOfLines = 0;
        _notifyLabel.font = [UIFont systemFontOfSize:14];
        _notifyLabel.textAlignment = NSTextAlignmentCenter;
        _notifyLabel.textColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.9];
        [_notifyLabel sizeToFit];
    }
    return _notifyLabel;
}

-(CGFloat)getStatusWidth:(NSString*)tips
{
    CGSize size = [tips sizeWithAttributes:@{ NSFontAttributeName : FONT_LIVESTATUS}];
    return size.width;
}

-(CGFloat)getDeleteTipWidth
{
    NSString *tips = kLocalizationDeleteTip;
    CGSize size = [tips sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12]}];
    return size.width;
}

-(CGFloat)getDeleteStringWidth
{
    NSString *tips = kLocalizationDeleteTip2;
    CGSize size = [tips sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:13]}];
    return size.width;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel sizeToFit];
        _nameLabel.textColor = [UIColor hx_colorWithHexString:@"#ffffff"];
        _nameLabel.font = [UIFont systemFontOfSize:17];
    }
    return _nameLabel;
}

- (UIImageView *)bkgImageView
{
    if(!_bkgImageView) {
        _bkgImageView = [[UIImageView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"liveend_background" ofType:@"png"];
        _bkgImageView.image = [[UIImage alloc] initWithContentsOfFile:path];
        _bkgImageView.alpha = 1.0;
    }
    return _bkgImageView;
}

- (UIImageView *)avatarBkgImageView
{
    if(!_avatarBkgImageView) {
        _avatarBkgImageView = [[UIImageView alloc] init];
        _avatarBkgImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarBkgImageView;
}

-(UIImageView*)iconView
{
    if(!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [UIImage imageNamed:@"live_end_icon"];
    }
    return _iconView;
}

-(UIImageView*)numberBkgView
{
    if(!_numberBkgView) {
        _numberBkgView = [[UIImageView alloc] init];
    }
    return _numberBkgView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 50;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.image = kDefaultImageAvatar;
    }
    return _avatarImageView;
}

-(UIView*)avatarBorderView
{
    if(!_avatarBorderView) {
        _avatarBorderView = [[UIView alloc] init];
        _avatarBorderView.layer.cornerRadius = 55;
        _avatarBorderView.layer.borderColor = [UIColor hx_colorWithHexString:@"#ffffff" alpha:0.5].CGColor;
        _avatarBorderView.layer.borderWidth = 5;
    }
    return _avatarBorderView;
}

- (void)back{
    //这里要改为非UIViewContentModeScaleAspectFill模式，否则popViewControllerAnimated时会卡一下，有点恶心
    _avatarBkgImageView.contentMode = UIViewContentModeScaleToFill;
    
    //返回首页
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFinishLive object:nil];
}

-(void)onDeletePlayback
{
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] deleteReplayLiveID:self.live_id success:^(id result) {
        [MBProgressHUD hideAllHUDsForView:self animated:YES];
        [weakSelf showHUDWithTip:kLocalizationSuccessfully delay:2 autoHide:YES];
    } failure:^(NSString *errorString) {
        [weakSelf showHUDWithTip:kLocalizationError delay:2 autoHide:YES];
    } finally:^{
        
    }];
}

- (void)showHUDWithTip:(NSString *)tip delay:(NSTimeInterval)delay autoHide:(BOOL)isAutoHide{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tip;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    if (isAutoHide) {
        [hud hide:YES afterDelay:delay];
    }
}

- (void)followStatus:(UIButton *)button {
    __weak typeof(self)wSelf = self;
    if(wSelf.followButton.isSelected) {
        [[FBProfileNetWorkManager sharedInstance] removeFromFollowingListWithUserID:self.uid success:^(id result) {
            //取消关注成功
            [wSelf updateFollowButtonWithFollowed:NO];
            //发一条广播去刷新个人中心的关注粉丝数量
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:nil];
        } failure:^(NSString *errorString) {
            //失败则重置回去
            [wSelf updateFollowButtonWithFollowed:YES];
        } finally:^{
            //
        }];
    } else {
        [[FBProfileNetWorkManager sharedInstance] addToFollowingListWithUserID:self.uid success:^(id result) {
            // 关注成功
            [wSelf updateFollowButtonWithFollowed:YES];
            // 发送一条广播去刷新个人中心的关注粉丝数量
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:nil];
        } failure:^(NSString *errorString) {
            //失败则重置回去
            [wSelf updateFollowButtonWithFollowed:NO];
        } finally:^{
            //
        }];
        // 每点击直播结束页面关注按钮＋1（陈番顺）
        [wSelf st_reportClickLiveEndFollowButtonEvent];
    }
    
    //先在UI上更新，等网络回来再更新真实状态
    [self updateFollowButtonWithFollowed:!button.isSelected];
}

-(void)updateFollowButtonWithFollowed:(BOOL)bFollowed
{
    if(bFollowed) {
        _followButton.selected = YES;
        [_followButton setImage:nil forState:UIControlStateNormal];
    } else {
        _followButton.selected = NO;
        [_followButton setImage:[UIImage imageNamed:@"live_end_add_icon"] forState:UIControlStateNormal];
    }
}

#pragma mark - Statistics -
/** 每点击直播结束页面关注按钮＋1 */
- (void)st_reportClickLiveEndFollowButtonEvent {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"from" value:[NSString stringWithFormat:@"%zd",self.fromType]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:self.live_id];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"1"];
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:self.uid];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"broadcast_end_follow"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3,eventParmeter4,eventParmeter5]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}
@end
