//
//  XXNameViewController.m
//  LiveShow
//
//  Created by lgh on 16/2/5.
//  Copyright © 2016年 XX. All rights reserved.
//
#import "FBProfileNetWorkManager.h"
#import "FBNameViewController.h"
#import "FBUserInfoModel.h"

#define kMaxLength 16

@interface FBNameViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nickTextField;


@end

@implementation FBNameViewController

- (UITextField *)nickTextField {
    if (!_nickTextField) {
        CGFloat textFieldX = 20;
        CGFloat textFieldY = 64;
        CGFloat textFieldH = 50;
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, textFieldY, SCREEN_WIDTH, textFieldH)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:backgroundView];
        _nickTextField = [[UITextField alloc] initWithFrame:CGRectMake(textFieldX, textFieldY, SCREEN_WIDTH-15, textFieldH)];
        _nickTextField.font = [UIFont systemFontOfSize:17];
        _nickTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nickTextField.delegate = self;
        [_nickTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_nickTextField becomeFirstResponder];
    }
    return _nickTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = kLocalizationNick;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizationSave style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    [self.view addSubview:self.nickTextField];
    self.nickTextField.text = self.nick;
    self.view.backgroundColor = COLOR_BACKGROUND_APP;

}

- (void)requestForEditName{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FBProfileNetWorkManager sharedInstance] updateUserInfoWithNick:_nickTextField.text description:nil portrait:nil gender:nil success:^(id result) {
        if ([result[@"dm_error"] intValue] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateProfile object:nil];
            [self showHUDWithTip:kLocalizationSuccessfully delay:2];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *errorString) {
         [self showHUDWithTip:kLocalizationError delay:2];
    } finally:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}



- (void)save {
    _nickTextField.text = [_nickTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_nickTextField.text.length != 0) {
        [self requestForEditName];
    } else {
        [self showHUDWithTip:kLocalizationCanNotNil delay:2];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.nickTextField) {
        if (string.length == 0) return YES;
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > kMaxLength) {
            return NO;
        }
    }
    
    return YES;
}


- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.nickTextField) {
        if (textField.text.length > kMaxLength) {
            textField.text = [textField.text substringToIndex:kMaxLength];
        }
    }
}


- (void)showHUDWithTip:(NSString *)tip delay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tip;
    hud.margin = 10.f;
    hud.yOffset = -150.f;
    [hud hide:YES afterDelay:delay];
}

@end
