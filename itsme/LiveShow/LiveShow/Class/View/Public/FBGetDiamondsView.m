//
//  FBGetDiamondsView.m
//  LiveShow
//
//  Created by chenfanshun on 30/08/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBGetDiamondsView.h"

@interface FBGetDiamondsView()

@property(nonatomic, strong)UIView      *infoView;
@property(nonatomic, assign)NSInteger   diamondCount;

@end

@implementation FBGetDiamondsView

-(id)initWithFrame:(CGRect)frame andCount:(NSInteger)count
{
    if(self = [super initWithFrame:frame]) {
        self.diamondCount = count;
        self.backgroundColor = [UIColor clearColor];

        __weak typeof(self) wself = self;
        
        UIView *touchView = [[UIView alloc] init];
        [self addSubview:touchView];
        [touchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(wself);
        }];
        [touchView bk_whenTapped:^{
            [wself hide];
        }];
        
        [self addSubview:self.infoView];
        [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(300, 250));
            make.centerX.equalTo(wself.mas_centerX);
            make.centerY.equalTo(wself.mas_centerY).offset(-30);
        }];
    }
    return self;
}

#pragma mark - Setter & Getter -
-(UIView*)infoView
{
    if(nil == _infoView) {
        _infoView = [[UIView alloc] init];
        _infoView.backgroundColor = [UIColor whiteColor];
        _infoView.layer.cornerRadius = 5;
        _infoView.layer.masksToBounds = YES;
        
        //title
        UILabel *labelTitle = [[UILabel alloc] init];
        labelTitle.font = [UIFont boldSystemFontOfSize:20];
        labelTitle.textColor = [UIColor hx_colorWithHexString:@"#444444"];
        labelTitle.textAlignment = NSTextAlignmentCenter;
        labelTitle.text = kLocalizationReward;
        
        [_infoView addSubview:labelTitle];
        [labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(22);
            make.centerX.equalTo(_infoView.mas_centerX);
            make.top.equalTo(_infoView.mas_top).offset(30);
        }];
        
        //descript
        UILabel *labelDescript = [[UILabel alloc] init];
        labelDescript.font = [UIFont systemFontOfSize:15];
        labelDescript.textColor = [UIColor hx_colorWithHexString:@"#444444"];
        labelDescript.textAlignment = NSTextAlignmentCenter;
        labelDescript.numberOfLines = 2;
        
        NSString *descript = [NSString stringWithFormat:kLocalizationGetDiamonds, self.diamondCount];
        labelDescript.text = descript;
        
        [_infoView addSubview:labelDescript];
        [labelDescript mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(40);
            make.top.equalTo(labelTitle.mas_bottom).offset(10);
            make.left.equalTo(_infoView.mas_left).offset(15);
            make.right.equalTo(_infoView.mas_right).offset(-15);
        }];
        
        //diamonds
        CGFloat iconW = 46;
        CGFloat padding = 10;
        CGFloat textW = 45;
        CGFloat margin = (300 - iconW - padding - textW)/2.0;
        
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.image = [UIImage imageNamed:@"share_icon_diamond"];
        [_infoView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(iconW, 46));
            make.left.equalTo(_infoView.mas_left).offset(margin);
            make.top.equalTo(labelDescript.mas_bottom).offset(20);
        }];
        
        UILabel *labelPlus = [[UILabel alloc] init];
        labelPlus.font = [UIFont systemFontOfSize:23];
        labelPlus.textColor = [UIColor hx_colorWithHexString:@"#50e3ce"];
        labelPlus.text = @"+";
        [labelPlus sizeToFit];
        [_infoView addSubview:labelPlus];
        [labelPlus mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(iconView.mas_top).offset(5);
            make.left.equalTo(iconView.mas_right).offset(padding);
        }];
        
        UILabel *labelCount = [[UILabel alloc] init];
        labelCount.font = [UIFont systemFontOfSize:45];
        labelCount.textColor = [UIColor hx_colorWithHexString:@"#50e3ce"];
        labelCount.text = [NSString stringWithFormat:@"%zd", self.diamondCount];
        [labelCount sizeToFit];
        [_infoView addSubview:labelCount];
        [labelCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(labelPlus.mas_right).offset(3);
            make.top.equalTo(iconView.mas_top).offset(-8);
        }];
        
        //spliter
        UIView *spliterView = [[UIView alloc] init];
        spliterView.backgroundColor = [UIColor hx_colorWithHexString:@"#e3e3e3"];
        [_infoView addSubview:spliterView];
        [spliterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(0.5);
            make.left.equalTo(_infoView.mas_left);
            make.right.equalTo(_infoView.mas_right);
            make.top.equalTo(iconView.mas_bottom).offset(30);
        }];
        
        //button
        UIButton *btnConfirm = [[UIButton alloc] init];
        [btnConfirm setTitleColor:[UIColor hx_colorWithHexString:@"#0d84e9"] forState:UIControlStateNormal];
        btnConfirm.titleLabel.font = [UIFont systemFontOfSize:15];
        [btnConfirm setTitle:kLocalizationPublicConfirm forState:UIControlStateNormal];

        [btnConfirm addTarget:self action:@selector(onBtnConfirm) forControlEvents:UIControlEventTouchUpInside];
        [_infoView addSubview:btnConfirm];
        [btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(100, 40));
            make.centerX.equalTo(_infoView.mas_centerX);
            make.top.equalTo(spliterView.mas_bottom).offset(5);
        }];
        
    }
    return _infoView;
}

+(void)showInView:(UIView*)superView withDaimonds:(NSInteger)count
{
    for (UIView *subview in superView.subviews) {
        if ([subview isKindOfClass:[FBGetDiamondsView class]]) {
            return;
        }
    }
    FBGetDiamondsView *diamondView = [[FBGetDiamondsView alloc] initWithFrame:CGRectMake(0, superView.dop_height, superView.dop_width, superView.dop_height) andCount:count];

    [superView addSubview:diamondView];
    [UIView animateWithDuration:0.25 animations:^{
        diamondView.dop_y = 0;
    }];
}

-(void)hide
{
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.25 animations:^{
        wself.dop_y = wself.superview.dop_height;
    } completion:^(BOOL finished) {
        [wself removeFromSuperview];
    }];
}

-(void)onBtnConfirm
{
    [self hide];
}

@end
