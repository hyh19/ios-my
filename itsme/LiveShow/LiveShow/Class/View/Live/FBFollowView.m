//
//  FBFollowView.m
//  LiveShow
//
//  Created by chenfanshun on 10/11/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBFollowView.h"
#import "ColorButton.h"

@interface FBFollowView()

@property(nonatomic, strong)UIView *infoView;
@property(nonatomic, strong)UIButton *avatarButton;
@property(nonatomic, strong)UILabel *labelNick;
@property(nonatomic, strong)UILabel *labelDescription;

@property(nonatomic, strong)FBUserInfoModel *userInfo;

@property (nonatomic, copy) void (^onFollowAction)();

@end

@implementation FBFollowView

-(id)initWithFrame:(CGRect)frame andUserInfo:(FBUserInfoModel*)userInfo
{
    if(self = [super initWithFrame:frame]) {
        self.userInfo = userInfo;
        
        [self configUI];
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"dealloc FBFollowView");
}

-(void)configUI
{
    //holder
    [self addSubview:self.infoView];
    __weak typeof(self)weakSelf = self;
    CGFloat infoViewW = 300;
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(infoViewW, 280));
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.centerY.equalTo(weakSelf.mas_centerY).offset(-30);
    }];
    
    //close button
    UIButton *btnClose = [self closeButton];
    [self.infoView addSubview:btnClose];
    [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(22, 23));
        make.top.equalTo(10);
        make.right.equalTo(-10);
    }];
    
    //avatar
    CGFloat avatarW = 90;
    [self.infoView addSubview:self.avatarButton];
    [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(avatarW, avatarW));
        make.top.equalTo(weakSelf.infoView.mas_top).offset(25);
        make.centerX.equalTo(weakSelf.infoView.mas_centerX);
    }];
    self.avatarButton.layer.cornerRadius = avatarW/2.0;
    self.avatarButton.layer.masksToBounds = YES;
    if(self.userInfo.avatarImage) {
        [self.avatarButton setImage:self.userInfo.avatarImage forState:UIControlStateNormal];
    }
    
    //nick
    [self.infoView addSubview:self.labelNick];
    [self.labelNick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(20);
        make.top.equalTo(weakSelf.avatarButton.mas_bottom).offset(15);
        make.centerX.equalTo(weakSelf.infoView.mas_centerX);
    }];
    self.labelNick.text = self.userInfo.nick;
    
    //description
    [self.infoView addSubview:self.labelDescription];
    [self.labelDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelNick.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.infoView.mas_left).offset(30);
        make.right.equalTo(weakSelf.infoView.mas_right).offset(-30);
        make.centerX.equalTo(weakSelf.infoView.mas_centerX);
    }];
    
    CGFloat buttonW = 100;
    CGFloat buttonH = 35;
    CGFloat spacing = 15;
    CGFloat padding = (infoViewW - buttonW*2 - spacing)/2.0;
    //cancel button
    UIButton *cancelButton = [self cancelButton];
    [self.infoView addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(buttonW, buttonH));
        make.bottom.equalTo(weakSelf.infoView.mas_bottom).offset(-25);
        make.left.equalTo(weakSelf.infoView.mas_left).offset(padding);
    }];
    
    //follow button
    UIButton *followButton = [self followButtonWithFrame:CGRectMake(0, 0, buttonW, buttonH)];
    [self.infoView addSubview:followButton];
    [followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(buttonW, buttonH));
        make.bottom.equalTo(cancelButton.mas_bottom);
        make.left.equalTo(cancelButton.mas_right).offset(spacing);
    }];

}

#pragma mark - Setter & Getter -
-(UIView*)infoView
{
    if(nil == _infoView) {
        _infoView = [[UIView alloc] init];
        _infoView.backgroundColor = [UIColor whiteColor];
        _infoView.layer.cornerRadius = 5;
        _infoView.layer.masksToBounds = YES;
    }
    return _infoView;
}

-(UIButton*)closeButton
{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"replay_icon_close"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onBtnClose:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(UIButton*)avatarButton
{
    if(nil == _avatarButton) {
        _avatarButton = [[UIButton alloc] init];
        [_avatarButton addTarget:self action:@selector(onBtnAvatar:) forControlEvents:UIControlEventTouchUpInside];
        [_avatarButton setImage:kDefaultImageAvatar forState:UIControlStateNormal];
    }
    return _avatarButton;
}

-(UILabel*)labelNick
{
    if(nil == _labelNick) {
        _labelNick = [[UILabel alloc] init];
        _labelNick.font = [UIFont boldSystemFontOfSize:17];
        _labelNick.textColor = [UIColor hx_colorWithHexString:@"#444444"];
        [_labelNick sizeToFit];
    }
    return _labelNick;
}

-(UILabel*)labelDescription
{
    if(nil == _labelDescription) {
        _labelDescription = [[UILabel alloc] init];
        _labelDescription.font = [UIFont systemFontOfSize:15];
        _labelDescription.textColor = [UIColor hx_colorWithHexString:@"#444444"];
        _labelDescription.numberOfLines = 2;
        _labelDescription.textAlignment = NSTextAlignmentCenter;
        [_labelDescription sizeToFit];
        
        _labelDescription.text = kLocalizationFollowGuideTip;
    }
    return _labelDescription;
}

-(UIButton*)cancelButton
{
    UIButton *button = [[UIButton alloc] init];
    button.layer.cornerRadius = 17.5;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor hx_colorWithHexString:@"#ff4572"].CGColor;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor hx_colorWithHexString:@"#ff4572"] forState:UIControlStateNormal];
    [button setTitle:kLocalizationPublicCancel forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onBtnCancel:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(UIButton*)followButtonWithFrame:(CGRect)frame
{
    NSMutableArray *arrayColor = [[NSMutableArray alloc] init];
    [arrayColor addObject:[UIColor hx_colorWithHexString:@"ff4572"]];
    [arrayColor addObject:[UIColor hx_colorWithHexString:@"fd4cbe"]];
    
    UIButton *button = [[ColorButton alloc] initWithFrame:frame FromColorArray:arrayColor ByGradientType:leftToRight];
    button.layer.cornerRadius = 17.5;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:kLocalizationPublicConfirm forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onBtnFollow:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)onBtnClose:(UIButton*)sender
{
    [self doDismiss];
}

-(void)onBtnAvatar:(UIButton*)sender
{
    
}

-(void)onBtnCancel:(UIButton*)sender
{
    [self doDismiss];
}

-(void)onBtnFollow:(UIButton*)sender
{
    if(self.onFollowAction) {
        self.onFollowAction();
    }
    [self doDismiss];
//    __weak typeof(self)weakSelf = self;
//    [[FBProfileNetWorkManager sharedInstance] addToFollowingListWithUserID:self.userInfo.userID success:^(id result) {
//        // 关注成功
//        if(weakSelf) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFollowSomebody object:weakSelf.userInfo];
//            // 发送一条广播去刷新个人中心的关注粉丝数量
//            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:nil];
//            
//            if(weakSelf.onFollowAction) {
//                weakSelf.onFollowAction(YES);
//            }
//        }
//    } failure:^(NSString *errorString) {
//        //
//    } finally:^{
//        //
//        [weakSelf doDismiss];
//    }];
}

-(void)doDismiss
{
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.25 animations:^{
        wself.dop_y = wself.superview.dop_height;
    } completion:^(BOOL finished) {
        [wself removeFromSuperview];
    }];
}

+(void)showInView:(UIView*)superView withUser:(FBUserInfoModel*)user
     followAction:(void (^)())block
{
    for (UIView *subview in superView.subviews) {
        if ([subview isKindOfClass:[FBFollowView class]]) {
            return;
        }
    }
    

    FBFollowView *followView = [[FBFollowView alloc] initWithFrame:CGRectMake(0, superView.dop_height, superView.dop_width, superView.dop_height) andUserInfo:user];
    followView.onFollowAction = block;
    [superView addSubview:followView];
    
    [UIView animateWithDuration:0.25 animations:^{
        followView.dop_y = 0;
    }];
}

@end
