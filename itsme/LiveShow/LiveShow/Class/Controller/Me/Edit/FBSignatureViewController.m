//
//  XXSignatureViewController.m
//  LiveShow
//
//  Created by lgh on 16/2/5.
//  Copyright © 2016年 XX. All rights reserved.
//

#import "FBSignatureViewController.h"

#define kMaxLength 80
@interface FBSignatureViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *signatureTextView;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@end

@implementation FBSignatureViewController

+ (instancetype)signatureViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FBEditProfileViewController" bundle:nil];
    
    FBSignatureViewController *signatureViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    
    signatureViewController.hidesBottomBarWhenPushed = YES;
    
    return signatureViewController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _signatureTextView.text = self.Description;
    _signatureTextView.delegate = self;
    [_signatureTextView becomeFirstResponder];
    self.numberLabel.text = [NSString stringWithFormat:@"%zd",kMaxLength - self.signatureTextView.text.length];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = kLocalizationSignature;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizationSave style:UIBarButtonItemStylePlain target:self action:@selector(save)];
}

- (void)editSignature {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] updateUserInfoWithNick:nil description:self.signatureTextView.text portrait:nil gender:nil success:^(id result) {
        if ([result[@"dm_error"] intValue] == 0) {
            [weakSelf showHUDWithTip:kLocalizationSuccessfully delay:2];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateProfile object:self];
        }
    } failure:^(NSString *errorString) {
        [weakSelf showHUDWithTip:kLocalizationError delay:2];
    } finally:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)save {
    [self editSignature];
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length > kMaxLength) {
        return NO;
    }
    
    char delete = [text UTF8String][0];
    if (delete == '\000') {
        self.numberLabel.text = [NSString stringWithFormat:@"%zd",kMaxLength - textView.text.length + 1];
        return YES;
    }
    
    if(textView.text.length == kMaxLength) {
        if(![text isEqualToString:@"\b"]) return NO;
    }
    
    self.numberLabel.text = [NSString stringWithFormat:@"%zd",kMaxLength-textView.text.length - text.length];
    
    return YES;
    
}

//该判断用于联想输入
-(void)textViewDidChange:(UITextView *)textView{

    if (textView.text.length > kMaxLength)
    {
        textView.text = [textView.text substringToIndex:kMaxLength];
    }
    
    self.numberLabel.text = [NSString stringWithFormat:@"%zd",kMaxLength-textView.text.length];
}

- (void)showHUDWithTip:(NSString *)tip delay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tip;
    hud.margin = 10.f;
    hud.yOffset = -150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delay];
}


@end
