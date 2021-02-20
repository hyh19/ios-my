//
//  FBEditGenderViewController.m
//  LiveShow
//
//  Created by tak on 11/21/16.
//  Copyright © 2016 FB. All rights reserved.
//

#import "FBEditGenderViewController.h"

@interface FBEditGenderViewController ()

@property (nonatomic, strong) UIImageView *background;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIButton *maleButton;

@property (nonatomic, strong) UIButton *femaleButton;

@end

@implementation FBEditGenderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupData];
}

- (void)setupData {
    BOOL male = [self.gender isEqualToNumber:@1];
    self.maleButton.selected = male;
    self.femaleButton.selected = !male;
}

#pragma mark - action - 
- (void)onClickMale {
    self.maleButton.selected = YES;
    self.femaleButton.selected = NO;
    self.gender = @1;
}

- (void)onClickFemale {
    self.maleButton.selected = NO;
    self.femaleButton.selected = YES;
    self.gender = @0;
}

- (void)save{
    [self requestForEditGender];
}

#pragma mark - Network -
- (void)requestForEditGender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FBProfileNetWorkManager sharedInstance] updateUserInfoWithNick:nil description:nil portrait:nil gender:self.gender success:^(id result) {
        if ([result[@"dm_error"] intValue] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateProfile object:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } failure:nil finally:^(){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}


#pragma mark - UI -
- (void)setupUI {
    [self.view addSubview:self.background];
    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH));
    }];
    
    [self.view addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.background).offset(25);
        make.right.equalTo(self.background).offset(-10);
    }];
    
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-40);
        make.size.equalTo(CGSizeMake(250, 45));
    }];
    
    [self.view addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.saveButton);
        make.bottom.equalTo(self.saveButton.mas_top).offset(-50);
        make.size.equalTo(CGSizeMake(1, 75));
    }];
    
    [self.view addSubview:self.maleButton];
    [self.maleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).multipliedBy(0.5);
        make.centerY.equalTo(self.lineView).offset(-10);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH * 0.5, 75));
    }];
    
    [self.view addSubview:self.femaleButton];
    [self.femaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).multipliedBy(1.5);
        make.centerY.equalTo(self.maleButton);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH * 0.5, 75));
    }];
}

- (UIImageView *)background {
    if (!_background) {
        _background = [[UIImageView alloc] init];
        _background.image = [UIImage imageNamed:@"me_icon_gender_backgroud"];
        UIImageView *icon = [[UIImageView alloc] init];
        icon.image = [UIImage imageNamed:@"me_icon_backgroundIcon"];
        [_background addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(150, 111));
            make.centerX.equalTo(_background);
            make.top.equalTo(_background).offset(85);
        }];
        
        UILabel *gender = [[UILabel alloc] init];
        gender.text = kLocalizationUpdateGender;
        gender.font = [UIFont boldSystemFontOfSize:25];
        gender.textColor = [UIColor whiteColor];
        [gender sizeToFit];
        [_background addSubview:gender];
        [gender mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(icon);
            make.top.equalTo(icon.mas_bottom).offset(30);
        }];
        
//        UILabel *desc = [[UILabel alloc] init];
//        desc.text = @"Select your gender";
//        desc.textAlignment = NSTextAlignmentCenter;
//        desc.font = [UIFont systemFontOfSize:15];
//        [desc sizeToFit];
//        desc.textColor = [UIColor whiteColor];
//        [_background addSubview:desc];
//        [desc mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(_background);
//            make.top.equalTo(gender.mas_bottom).offset(20);
//        }];
    }
    return _background;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"avatar_btn_close_nor"] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage imageNamed:@"avatar_btn_close_hig"] forState:UIControlStateHighlighted];
        [_closeButton sizeToFit];
        [_closeButton bk_whenTapped:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _closeButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] init];
        [_saveButton setTitle:kLocalizationSave forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor hx_colorWithHexString:@"ff4572"] forState:UIControlStateNormal];
        _saveButton.backgroundColor = [UIColor whiteColor];
        _saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _saveButton.layer.cornerRadius = 22.5;
        _saveButton.layer.borderWidth = 1;
        _saveButton.layer.borderColor = [UIColor hx_colorWithHexString:@"ff4572"].CGColor;
        _saveButton.layer.masksToBounds = YES;
        [_saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchDown];
    }
    return _saveButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor hx_colorWithHexString:@"e3e3e3"];
    }
    return _lineView;
}

- (UIButton *)maleButton {
    if (!_maleButton) {
        _maleButton = [[UIButton alloc] init];
        [_maleButton setImage:[UIImage imageNamed:@"me_btn_male_nor"] forState:UIControlStateNormal];
        [_maleButton setImage:[UIImage imageNamed:@"me_btn_male_hig"] forState:UIControlStateSelected];
        [_maleButton setTitle:kLocalizationMale forState:UIControlStateNormal];
        [_maleButton setTitleColor:[UIColor hx_colorWithHexString:@"CCCCCC"] forState:UIControlStateNormal];
        [_maleButton setTitleColor:[UIColor hx_colorWithHexString:@"0084ff"] forState:UIControlStateSelected];
        _maleButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_maleButton sizeToFit];
        [self verticalButton:_maleButton];
        [_maleButton addTarget:self action:@selector(onClickMale) forControlEvents:UIControlEventTouchDown];
    }
    return _maleButton;
}

- (UIButton *)femaleButton {
    if (!_femaleButton) {
        _femaleButton = [[UIButton alloc] init];
        [_femaleButton setImage:[UIImage imageNamed:@"me_btn_female_nor"] forState:UIControlStateNormal];
        [_femaleButton setImage:[UIImage imageNamed:@"me_btn_female_hig"] forState:UIControlStateSelected];
        [_femaleButton setTitle:kLocalizationFemale forState:UIControlStateNormal];
        [_femaleButton setTitleColor:[UIColor hx_colorWithHexString:@"CCCCCC"] forState:UIControlStateNormal];
        [_femaleButton setTitleColor:[UIColor hx_colorWithHexString:@"FC2DAF"] forState:UIControlStateSelected];
        _femaleButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_femaleButton sizeToFit];
        [self verticalButton:_femaleButton];
        [_femaleButton addTarget:self action:@selector(onClickFemale) forControlEvents:UIControlEventTouchDown];
    }
    return _femaleButton;
}

- (void)verticalButton:(UIButton *)btn {
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height + 20 ,-btn.imageView.frame.size.width, 0,0)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -btn.titleLabel.bounds.size.width)];
}

@end
