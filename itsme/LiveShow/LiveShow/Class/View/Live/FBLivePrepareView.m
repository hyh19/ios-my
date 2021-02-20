//
//  FBLivePrepareView.m
//  LiveShow
//
//  Created by chenfanshun on 02/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLivePrepareView.h"
#import "FBLocationManager.h"
#import "FBLoadingView.h"
#import "DAKeyboardControl.h"

#import "UIImage-Helpers.h"

#import "FBUtility.h"
#import "FBLoginInfoModel.h"
#import "FBHashTagView.h"
#import "FBHashTagManager.h"

#import "FBTagsModel.h"
#import "FBConnectedAccountModel.h"
#import "ColorButton.h"

#define MAX_WORD    40

#define kBottomViewH        140
#define kBottomViewOriginY (SCREEN_HEIGH - kBottomViewH)

#define TAG_FACEBOOKTIP     1
#define TAG_TWITTERTIP      2

@interface FBLivePrepareView()<UITextFieldDelegate>

@property(nonatomic, strong)UILabel         *labelTip;
@property(nonatomic, strong)UITextField     *textField;
@property(nonatomic, strong)UIButton        *beginButton;
@property(nonatomic, strong)UIButton        *locationButton;
@property(nonatomic, strong)UIButton        *facebookButton;
@property(nonatomic, strong)UIButton        *twitterButton;
@property(nonatomic, strong)UILabel         *locationLabel;

@property(nonatomic, strong)UILabel         *ruleLabelTip;
@property(nonatomic, strong)UIButton        *ruleButton;

@property(nonatomic, strong)UIView          *touchView;

@property(nonatomic, strong)FBLoadingView   *loadingView;

@property(nonatomic, strong)UIView          *facebookTipView;
@property(nonatomic, strong)UIView          *twitterTipView;

@property(nonatomic, strong)FBHashTagView   *hashTagView;

@property(nonatomic, strong)NSTimer         *timerFacebookTip;
@property(nonatomic, strong)NSTimer         *timertwitterTip;

@property(nonatomic, strong)NSArray         *tagsArray;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBLivePrepareView

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self configUI];
        [self configAutoShare];
        
        [self addKeyboardObserver];
        [self addLocationAuthorObserver];
        
        // 每进入直播编辑页面＋1（陈番顺）
        [self st_reportLivePrepareEventWithID:@"live_edict"];
        self.enterTime = [[NSDate date] timeIntervalSince1970];
    
        //点开播时弹过则不需要再弹
        if(![FBLocationManager locationAvailable]) {
            BOOL hasAlert = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsAlertLocationWhenOpenLive];
            if(!hasAlert) {
                [FBLocationManager alertToLocationSetting];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsAlertLocationWhenOpenLive];
            }
        }
    }
    return self;
}

-(void)dealloc
{
    [self removeKeyboardControl];
    [self removeLocationAuthorObserver];
    
    [self.timertwitterTip invalidate];
    self.timertwitterTip = nil;
    
    [self.timerFacebookTip invalidate];
    self.timerFacebookTip = nil;
}

-(void)configUI
{
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.touchView];
    [self.touchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    //camera
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setImage:[UIImage imageNamed:@"room_btn_camera_nor"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"room_btn_camera_hig"] forState:UIControlStateHighlighted];
    [cameraButton bk_addEventHandler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChangeCamera object:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    UIView *superView = self;
    [superView addSubview:cameraButton];
    [cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(38, 38));
        make.left.equalTo(superView).offset(12);
        make.top.equalTo(superView.mas_top).offset(22);
    }];
    
    //close
    UIButton* btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:[UIImage imageNamed:@"avatar_btn_close_nor"] forState:UIControlStateNormal];
    [btnClose setImage:[UIImage imageNamed:@"avatar_btn_close_hig"] forState:UIControlStateHighlighted];
    [btnClose addTarget:self action:@selector(onBtnClose) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnClose];
    
    [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(40, 40));
        make.right.equalTo(superView.mas_right).offset(-10);
        make.top.equalTo(superView.mas_top).offset(20);
    }];

    
    //6的标准
    CGFloat xScale = [UIScreen mainScreen].bounds.size.width/375.0;
    CGFloat infoW = 323*xScale;
    
    //infoview
    UIView* infoView = [[UIView alloc] init];
    
    __weak typeof(self)wself = self;
    [infoView bk_whenTapped:^{
        [wself hideKeyboard];
    }];
    
    [self addSubview:infoView];
    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(infoW, 1000));
        make.centerX.equalTo(self.mas_centerX);
        
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        if(480 == height) {
            make.top.equalTo(self.mas_top).offset(62);
        } else if(568 == height) {
            make.top.equalTo(self.mas_top).offset(62);
        } else {
          make.top.equalTo(self.mas_top).offset(130);
        }
    }];
    
    //label
    [infoView addSubview:self.labelTip];
    [self.labelTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(300, 30));
        make.centerX.equalTo(infoView.mas_centerX);
        make.top.equalTo(infoView.mas_top);
    }];
    
    //textfield
    [infoView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(infoW, 30));
        make.centerX.equalTo(infoView.mas_centerX);
        make.top.equalTo(infoView.mas_top).offset(3);
    }];
    
    //hspliter
    UIView *hSpliterView = [[UIView alloc] init];
    hSpliterView.backgroundColor = [UIColor whiteColor];
    [infoView addSubview:hSpliterView];
    [hSpliterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(infoW, 0.5));
        make.centerX.equalTo(infoView.mas_centerX);
        make.top.equalTo(infoView.mas_top).offset(40);
    }];
    
    
    //hashtagview
    [infoView addSubview:self.hashTagView];
    [self.hashTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(infoW);
        make.centerX.equalTo(infoView.mas_centerX);
        make.top.equalTo(hSpliterView.mas_top).offset(30);
        
        make.height.equalTo(self.hashTagView.fittedSize.height);
    }];
    
    //action
    UIView *actionView = [[UIView alloc] init];
    [infoView addSubview:actionView];
    [actionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(infoW, 30));
        make.centerX.equalTo(infoView.mas_centerX);
        make.top.equalTo(self.hashTagView.mas_bottom).offset(25);
    }];
    
    //share label
    UILabel *shareLabel = [[UILabel alloc] init];
    shareLabel.font = [UIFont systemFontOfSize:12];
    shareLabel.textColor = [UIColor whiteColor];
    shareLabel.shadowOffset = CGSizeMake(0, 1);
    shareLabel.shadowColor = [UIColor hx_colorWithHexString:@"#000000" alpha:0.2];
    shareLabel.text = kLocalizationLiveShareTo;
    [shareLabel sizeToFit];
    [actionView addSubview:shareLabel];
    [shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(actionView.mas_left);
        make.centerY.equalTo(actionView.mas_centerY).offset(2);
        make.height.equalTo(20);
    }];
    
    //facebook
    [actionView addSubview:self.facebookButton];
    [self.facebookButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(40, 34));
        make.top.equalTo(actionView.mas_top);
        make.left.equalTo(shareLabel.mas_right).offset(3);
    }];
    
    //twitter
    [actionView addSubview:self.twitterButton];
    [self.twitterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(40, 34));
        make.top.equalTo(actionView.mas_top);
        make.left.equalTo(self.facebookButton.mas_right).offset(3);
    }];
    
    //vspliter
    UIView *vSpliterView = [[UIView alloc] init];
    vSpliterView.backgroundColor = [UIColor whiteColor];
    [actionView addSubview:vSpliterView];
    [vSpliterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(0.5, 15));
        make.centerY.equalTo(actionView.mas_centerY);
        make.left.equalTo(self.twitterButton.mas_right).offset(32);
    }];
    
    //location
    [actionView addSubview:self.locationButton];
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(40, 34));
        make.top.equalTo(actionView.mas_top).offset(-2);
        make.left.equalTo(vSpliterView.mas_right).offset(32);
    }];
    
    [actionView addSubview:self.locationLabel];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(20);
        make.top.equalTo(self.locationButton.mas_top).offset(7);
        make.left.equalTo(self.locationButton.mas_right).offset(1);
    }];
    
    [self updateLocationTip];
    
    //btnbegin
    [infoView addSubview:self.beginButton];
    [self.beginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.size.equalTo(CGSizeMake(infoW, 45));
        make.top.equalTo(actionView.mas_bottom).offset(20);
    }];
    
    [self.beginButton addSubview:self.loadingView];
    
    NSString *observe = kLocalizationObserve;
    NSString *rule = kLocalizationItsMeRule;
    
    //tips
    self.ruleLabelTip.text = observe;
    [infoView addSubview:self.ruleLabelTip];
    
    NSRange range = NSMakeRange(0, rule.length);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:rule];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:range];
    [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR_MAIN range:range];
    [self.ruleButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    [infoView addSubview:self.ruleButton];
    
    CGFloat tipWidth = [observe sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12]}].width;
    CGFloat ruleWidth = [rule sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12]}].width;
    CGFloat offset = (infoW - tipWidth - ruleWidth)/2.0;
    [self.ruleLabelTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(15);
        make.top.equalTo(self.beginButton.mas_bottom).offset(22);
        make.left.equalTo(infoView.mas_left).offset(offset);
    }];
    
    [self.ruleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(20);
        make.top.equalTo(self.beginButton.mas_bottom).offset(20);
        make.left.equalTo(self.ruleLabelTip.mas_right);
    }];
    
    [self addSubview:self.facebookTipView];
    self.facebookTipView.hidden = YES;
    [self.facebookTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.facebookButton);
        make.bottom.equalTo(self.facebookButton.mas_top).offset(-10);
        make.height.equalTo(35);
    }];
    
    [self addSubview:self.twitterTipView];
    self.twitterTipView.hidden = YES;
    [self.twitterTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.twitterButton);
        make.bottom.equalTo(self.twitterButton.mas_top).offset(-10);
        make.height.equalTo(35);
    }];
}

-(void)configAutoShare
{
    if([[FBLoginInfoModel sharedInstance] connectedAcounts]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if([[FBLoginInfoModel sharedInstance] connectedPlatform:kPlatformFacebook]) {
            BOOL autoShareToFacebook = [[userDefaults objectForKey:kUserDefaultsAutoShareToFacebook] integerValue];
            [self.facebookButton setSelected:autoShareToFacebook];
            
            // 打开Facebook自动分享的按钮判断授权是否失效，是则重新绑定
            if (autoShareToFacebook == YES) {
                [FBUtility bindPlatformStatusWithPlatform:kPlatformFacebook confirmCompletionBlock:^{
                    if(self.doBindFacebook) {
                        self.doBindFacebook();
                    }
                } cancelCompletionBlock:^{
                    [self.facebookButton setSelected:NO];
                }];
            }
        }
    
        if([[FBLoginInfoModel sharedInstance] connectedPlatform:kPlatformTwitter]) {
            BOOL autoShareToTwitter = [[userDefaults objectForKey:kUserDefaultsAutoShareToTwitter] integerValue];
            [self.twitterButton setSelected:autoShareToTwitter];
            
            // 打开Twitter自动分享的按钮判断授权是否失效，是则重新绑定
            if (autoShareToTwitter == YES) {
                [FBUtility bindPlatformStatusWithPlatform:kPlatformTwitter confirmCompletionBlock:^{
                    if(self.doBindTwitter) {
                        self.doBindTwitter();
                    }
                } cancelCompletionBlock:^{
                    [self.twitterButton setSelected:NO];
                }];
            }
        }
    }
}

-(void)addKeyboardObserver
{
    [self addKeyboardNonpanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
    }];
}

#pragma mark - location author -
-(void)addLocationAuthorObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocationAuthorChange:) name:kNotificationLocationAuthorChange object:nil];
}

-(void)removeLocationAuthorObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLocationAuthorChange object:nil];
}

-(void)onLocationAuthorChange:(NSNotification*)notify
{
    [_locationButton setSelected:[FBLocationManager locationAvailable]];
}

#pragma mark - Getter & Setter -
-(UILabel*)labelTip
{
    if(nil == _labelTip) {
        _labelTip = [[UILabel alloc] init];
        _labelTip.font = [UIFont systemFontOfSize:20];
        _labelTip.textColor = [UIColor whiteColor];
        _labelTip.shadowOffset = CGSizeMake(0, 1);
        _labelTip.shadowColor = [UIColor hx_colorWithHexString:@"#000000" alpha:0.2];
        _labelTip.textAlignment = NSTextAlignmentCenter;
        _labelTip.text = kLocalizationLiveName;
    }
    return _labelTip;
}

-(UITextField*)textField
{
    if(nil == _textField) {
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor whiteColor];
        _textField.font = [UIFont systemFontOfSize:20];
        _textField.tintColor = [UIColor whiteColor];
        [_textField addTarget:self action:@selector(textViewDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textField.delegate = self;
    }
    return _textField;
}

-(UIButton*)beginButton
{
    if(nil == _beginButton) {
        
        NSMutableArray *arrayColor = [[NSMutableArray alloc] init];
        [arrayColor addObject:[UIColor hx_colorWithHexString:@"ff4572"]];
        [arrayColor addObject:[UIColor hx_colorWithHexString:@"fd4cbe"]];
        
        CGFloat xScale = [UIScreen mainScreen].bounds.size.width/375.0;
        CGFloat infoW = 323*xScale;
        _beginButton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, infoW, 45) FromColorArray:arrayColor ByGradientType:leftToRight];
        _beginButton.layer.cornerRadius = 22.5;
        _beginButton.layer.masksToBounds = YES;
        _beginButton.alpha = 0.8;
        [_beginButton setTitle:kLocalizationLiveStart forState:UIControlStateNormal];
        [_beginButton setTitle:kLocalizationLivePrepare forState:UIControlStateDisabled];
        
        [_beginButton addTarget:self action:@selector(onBtnBeginLive) forControlEvents:UIControlEventTouchUpInside];
        [_beginButton setEnabled:NO];
    }
    return _beginButton;
}

-(UIButton*)locationButton
{
    if(nil == _locationButton) {
        __weak typeof(self) weakSelf = self;
        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationButton setImage:[UIImage imageNamed:@"pub_btn_location_nor"] forState:UIControlStateNormal];
        [_locationButton setImage:[UIImage imageNamed:@"pub_btn_location_hig"] forState:UIControlStateSelected];
        
        [_locationButton bk_addEventHandler:^(id sender) {
            [weakSelf onLocationButton:sender];
        } forControlEvents:UIControlEventTouchUpInside];

        [_locationButton setSelected:[FBLocationManager locationAvailable]];
    }
    return _locationButton;
}

-(UIButton*)facebookButton
{
    if(nil == _facebookButton) {
        _facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_facebookButton setImage:[UIImage imageNamed:@"pub_btn_facebook_nor_2"] forState:UIControlStateNormal];
        [_facebookButton setImage:[UIImage imageNamed:@"pub_btn_facebook_hig_2"] forState:UIControlStateSelected];
        
        __weak typeof(self)weakSelf = self;
        [_facebookButton bk_addEventHandler:^(id sender) {
            [weakSelf onFacebookShare:sender];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _facebookButton;
}

-(UIButton*)twitterButton
{
    if(nil == _twitterButton) {
        _twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_twitterButton setImage:[UIImage imageNamed:@"pub_btn_twitter_nor_2"] forState:UIControlStateNormal];
        [_twitterButton setImage:[UIImage imageNamed:@"pub_btn_twitter_hig_2"] forState:UIControlStateSelected];
        
        __weak typeof(self)weakSelf = self;
        [_twitterButton bk_addEventHandler:^(id sender) {
            [weakSelf onTwitterShare:sender];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _twitterButton;
}

-(UILabel*)locationLabel
{
    if(nil == _locationLabel) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.font = [UIFont systemFontOfSize:12];
        _locationLabel.textColor = [UIColor whiteColor];
        _locationLabel.shadowOffset = CGSizeMake(0, 1);
        _locationLabel.shadowColor = [UIColor hx_colorWithHexString:@"#000000" alpha:0.2];
        [_locationLabel sizeToFit];
    }
    return _locationLabel;
}

-(UILabel*)ruleLabelTip
{
    if(nil == _ruleLabelTip) {
        _ruleLabelTip = [[UILabel alloc] init];
        _ruleLabelTip.font = [UIFont systemFontOfSize:12];
        _ruleLabelTip.textColor = [UIColor whiteColor];
        [_ruleLabelTip sizeToFit];
    }
    return _ruleLabelTip;
}

-(UIButton*)ruleButton
{
    if(nil == _ruleButton) {
        _ruleButton = [[UIButton alloc] init];
        _ruleButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_ruleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_ruleButton addTarget:self action:@selector(onRuleButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ruleButton;
}

- (UIView *)touchView {
    if (!_touchView) {
        _touchView = [[UIView alloc] init];
        _touchView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) wself = self;
        [_touchView bk_whenTapped:^{
            [wself hideKeyboard];
        }];
    }
    return _touchView;
}

- (FBLoadingView *)loadingView
{
    if(nil == _loadingView) {
        _loadingView = [[FBLoadingView alloc] initWithFrame:CGRectMake(20.0, (45 - 17.0)/2, 17.0, 17.0)];
    }
    return _loadingView;
}

- (UIView *)facebookTipView {
    if (!_facebookTipView) {
        _facebookTipView = [[UIView alloc] init];
        _facebookTipView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [[UIImage imageNamed:@"room_bg_danmu_tip"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 34, 12, 2)];
        [_facebookTipView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = TAG_FACEBOOKTIP;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        [_facebookTipView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_facebookTipView).offset(10);
            make.top.bottom.equalTo(_facebookTipView);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_facebookTipView);
            make.right.equalTo(label).offset(8);
            make.top.equalTo(_facebookTipView);
            make.bottom.equalTo(_facebookTipView).offset(5.5);
        }];
    }
    return _facebookTipView;
}

- (UIView *)twitterTipView {
    if (!_twitterTipView) {
        _twitterTipView = [[UIView alloc] init];
        _twitterTipView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [[UIImage imageNamed:@"room_bg_danmu_tip"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 34, 12, 2)];
        [_twitterTipView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = TAG_TWITTERTIP;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        [_twitterTipView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_twitterTipView).offset(8);
            make.top.bottom.equalTo(_twitterTipView);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_twitterTipView);
            make.right.equalTo(label).offset(8);
            make.top.equalTo(_twitterTipView);
            make.bottom.equalTo(_twitterTipView).offset(5.5);
        }];
    }
    return _twitterTipView;
}

-(FBHashTagView*)hashTagView
{
    if(nil == _hashTagView) {
        //6的标准
        CGFloat xScale = [UIScreen mainScreen].bounds.size.width/375.0;
        CGFloat infoW = 323*xScale;
        
        _hashTagView = [[FBHashTagView alloc] initWithFrame:CGRectMake(0, 0, infoW, 0)];
        NSArray *tags = [self getTags];
        [_hashTagView setHashTags:tags];
        
        __weak typeof(self)weakSelf = self;
        _hashTagView.onTagClick = ^(NSString *tagString, BOOL isSelected) {
            [weakSelf onTagClickWithTag:tagString isSelected:isSelected];
        };
    }
    return _hashTagView;
}

-(NSArray*)getTags
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    id result = [defaults objectForKey:kUserDefaultsHashTags];
    if(result) {
        NSArray* array = [FBTagsModel mj_objectArrayWithKeyValuesArray:result];
        
        NSMutableArray *tags = [[NSMutableArray alloc] init];
        for(FBTagsModel *model in array)
        {
            if([model.name length] && ![model.name isEqualToString:@"other"]) {
                [tags addObject:model.name];
            }
        }
        return tags;
    }
    
    return nil;
    
}

-(void)onTagClickWithTag:(NSString*)tagString isSelected:(BOOL)isSelected
{
    [self.labelTip removeFromSuperview];
    
    NSString *title = self.textField.text;
    //hashtag用空格隔开
    NSString *realTag = [NSString stringWithFormat:@"%@ ", tagString];
    if(isSelected) {
      title = [NSString stringWithFormat:@"%@%@", title, realTag];
    } else {
        title = [title stringByReplacingOccurrencesOfString:realTag withString:@""];
    }
    
    if([title length] > MAX_WORD) {
        [self showMaxTextLimitTip];
        
        [self.hashTagView updateStateWithText:self.textField.text];
    } else {
        self.textField.text = title;
    }
}

#pragma mark - actions -
-(void)onBtnClose
{
    // 每关闭直播编辑页面＋1（陈番顺）
    [self st_reportLivePrepareEventWithID:@"live_close"];
    
    [self hideKeyboard];
    
    if(self.doClose) {
        self.doClose();
    }
}

-(void)onBtnBeginLive
{
    [self hideKeyboard];
    
    if(self.doOpenLive) {
        // >= iPhone 6 的手机支持开启高清录制
        GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
        BOOL bHighQuality = (deviceInfo.family == GBDeviceFamilyiPhone &&
                             deviceInfo.deviceVersion.major > 6);
        
        self.doOpenLive(_locationButton.isSelected,
                        bHighQuality,
                        self.facebookButton.isSelected,
                        self.twitterButton.isSelected,
                        [self getCurrentTagsString]);
    }
}

-(void)onFacebookShare:(UIButton*)sender
{
    BOOL shareAutomatical = YES;
    if (shareAutomatical) {
        if([[FBLoginInfoModel sharedInstance] connectedAcounts]) {
            
            // 按钮是关的时候，打开的时候再次判断授权是否失效
            if([[FBLoginInfoModel sharedInstance] connectedPlatform:kPlatformFacebook]) {
                
                if (sender.isSelected == NO) {
                    // 打开Facebook自动分享的按钮判断授权是否失效，是则重新绑定
                    [FBUtility bindPlatformStatusWithPlatform:kPlatformFacebook confirmCompletionBlock:^{
                        if(self.doBindFacebook) {
                            self.doBindFacebook();
                        }
                    } cancelCompletionBlock:^{
                        [self.facebookButton setSelected:NO];
                    }];
                }
                
                [sender setSelected:!sender.isSelected];
            } else {
                if(self.doBindFacebook) {
                    self.doBindFacebook();
                }
                return;
            }
        } else {
            [FBUtility updateConnectedAccountsWithSuccessBlock:^{
                
            } failureBlock:^{
                
            }];
            [sender setSelected:!sender.isSelected];
        }
        
        [self showFacebookTipPostOn:sender.isSelected];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *share = sender.isSelected ? @"1" : @"0";
        [userDefaults setObject:share forKey:kUserDefaultsAutoShareToFacebook];
        [userDefaults synchronize];
    } else {
        if(self.doBindFacebook) {
            self.doBindFacebook();
        }
    }
}

-(void)onTwitterShare:(UIButton*)sender
{
    BOOL shareAutomatical = YES;
    
    if (shareAutomatical) {
        if([[FBLoginInfoModel sharedInstance] connectedAcounts]) {
            if([[FBLoginInfoModel sharedInstance] connectedPlatform:kPlatformTwitter]) {
                
                // 按钮是关的时候，打开的时候再次判断授权是否失效
                if (sender.isSelected == NO) {
                    // 打开Twitter自动分享的按钮判断授权是否失效，是则重新绑定
                    [FBUtility bindPlatformStatusWithPlatform:kPlatformTwitter confirmCompletionBlock:^{
                        if(self.doBindTwitter) {
                            self.doBindTwitter();
                        }
                    } cancelCompletionBlock:^{
                        [self.twitterButton setSelected:NO];
                    }];
                }
                
                [sender setSelected:!sender.isSelected];
            } else {
                if(self.doBindTwitter) {
                    self.doBindTwitter();
                }
                return;
            }
        } else {
            [FBUtility updateConnectedAccountsWithSuccessBlock:^{
                
            } failureBlock:^{
                
            }];
            [sender setSelected:!sender.isSelected];
        }
        
        [self showTwitterTipPostOn:sender.isSelected];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *share = sender.isSelected ? @"1" : @"0";
        [userDefaults setObject:share forKey:kUserDefaultsAutoShareToTwitter];
        [userDefaults synchronize];
    } else {
        if(self.doBindTwitter) {
            self.doBindTwitter();
        }
    }
}

-(void)showFacebookTipPostOn:(BOOL)isOn
{
    if(isOn) {
        [self setFacebookTip:kLocalizationFacebookPostOn];
    } else {
        [self setFacebookTip:kLocalizationFacebookPostOff];
    }
    
    self.twitterTipView.hidden = YES;
    self.facebookTipView.hidden = NO;
    
    [self.timerFacebookTip invalidate];
    __weak typeof(self)weakSelf = self;
    self.timerFacebookTip = [NSTimer bk_scheduledTimerWithTimeInterval:2.0 block:^(NSTimer *timer) {
        weakSelf.facebookTipView.hidden = YES;
    } repeats:NO];
}

-(void)showTwitterTipPostOn:(BOOL)isOn
{
    if(isOn) {
        [self setTwitterTip:kLocalizationTwitterPostOn];
    } else {
        [self setTwitterTip:kLocalizationTwitterPostOff];
    }
    
    self.facebookTipView.hidden = YES;
    self.twitterTipView.hidden = NO;
    
    [self.timertwitterTip invalidate];
    __weak typeof(self)weakSelf = self;
    self.timertwitterTip = [NSTimer bk_scheduledTimerWithTimeInterval:2.0 block:^(NSTimer *timer) {
        weakSelf.twitterTipView.hidden = YES;
    } repeats:NO];
}

-(void)setFacebookTip:(NSString*)tips
{
    UILabel *label = (UILabel*)[self.facebookTipView viewWithTag:TAG_FACEBOOKTIP];
    if([label isKindOfClass:[UILabel class]]) {
        label.text = tips;
    }
}

-(void)setTwitterTip:(NSString*)tips
{
    UILabel *label = (UILabel*)[self.twitterTipView viewWithTag:TAG_TWITTERTIP];
    if([label isKindOfClass:[UILabel class]]) {
        label.text = tips;
    }
}

-(void)onLocationButton:(UIButton*)sender
{
    if(!sender.isSelected) {
        if([FBLocationManager alertToLocationSetting]) {
            return;
        }
    }
    
    [sender setSelected:!sender.isSelected];
    
    [self updateLocationTip];
}

-(void)onRuleButton:(UIButton*)sender
{
    if(self.doShowRule) {
        self.doShowRule();
    }
}

-(void)updateLocationTip
{
    if(self.locationButton.isSelected) {
        self.locationLabel.text = @"on";
    } else {
        self.locationLabel.text = @"off";
    }
}

#pragma mark - textview delegate -
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.labelTip removeFromSuperview];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(!_beginButton.isEnabled) {
        [self onBtnBeginLive];
    } else {
        [self hideKeyboard];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.labelTip removeFromSuperview];
    
    NSInteger totalLength = [textField.text length];
    totalLength  = totalLength + [string length] - range.length;
    if(totalLength > MAX_WORD) {
        [self showMaxTextLimitTip];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextField *)textField
{
    [self.labelTip removeFromSuperview];
    
    NSString *text = textField.text;
    if([text length] > MAX_WORD) {
        //截断
        text = [text substringToIndex:MAX_WORD];
        self.textField.text = text;
        
        [self showMaxTextLimitTip];
    }
    
    [self.hashTagView updateStateWithText:self.textField.text];
}

-(NSString*)getLiveName
{
    return _textField.text;
}

-(NSString*)getCurrentTagsString
{
    NSMutableString *tagsString = [[NSMutableString alloc] initWithString:@""];
    NSArray *tags =[self.hashTagView getSelectTags];
    for(NSInteger i = 0; i < [tags count]; i++)
    {
        if(0 == i) {
            [tagsString appendString:tags[i]];
        } else {
            [tagsString appendString:@","];
            [tagsString appendString:tags[i]];
        }
    }
    return tagsString;
}

-(void)enableOpenLive:(BOOL)isEnable
{
    [_beginButton setEnabled:isEnable];
    
    [self.loadingView removeFromSuperview];
    
    if(!isEnable) {
        [self.beginButton addSubview:self.loadingView];
    }
}

-(void)notifyFacebookBookBindSuccess
{
    [self.facebookButton setSelected:YES];
}

-(void)notifyTwitterBookBindSuccess
{
    [self.twitterButton setSelected:YES];
}

#pragma mark - 提示语 -
- (void)showMaxTextLimitTip
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self];
    HUD.mode = MBProgressHUDModeText;
    
    NSString *tips = [NSString stringWithFormat:kLocalizationWordLessThan, MAX_WORD];
    HUD.labelText = tips;
    [self addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

#pragma mark - statistics 
/** 每进入直播编辑页面＋1、每关闭直播编辑页面＋1*/
- (void)st_reportLivePrepareEventWithID:(NSString *)ID {
    EventParameter *eventParmeter = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:ID eventParametersArray:@[eventParmeter]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
