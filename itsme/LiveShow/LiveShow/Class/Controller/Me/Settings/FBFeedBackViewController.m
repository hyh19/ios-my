#import "UIImage+ImageWithColor.h"
#import "FBFeedBackViewController.h"
#import "ColorButton.h"
// 输入框的最大字数限制
#define kMaxLength 5000

@interface FBFeedBackViewController ()<UITextViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *parameter;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *suggestTitleLabel;

@property (nonatomic, strong) UITextView *suggestTextView;

@property (nonatomic, strong) UILabel *suggsetPlaceHolderLabel;

@property (nonatomic, strong) UILabel *emailTitleLabel;

@property (nonatomic, strong) UITextField *emailTextField;

@property (nonatomic, strong) ColorButton *sendButton;
@end

@implementation FBFeedBackViewController
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = COLOR_F0F7F6;
        _scrollView.contentSize = CGSizeMake(0, 575);
        _scrollView.scrollEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UILabel *)suggestTitleLabel {
    if (!_suggestTitleLabel) {
        _suggestTitleLabel = [[UILabel alloc] init];
        _suggestTitleLabel.backgroundColor = [UIColor whiteColor];
        _suggestTitleLabel.text = [NSString stringWithFormat:@" %@",kLocalizationFeedbackContent];
        _suggestTitleLabel.textColor = COLOR_444444;
    }
    return _suggestTitleLabel;
}

- (UITextView *)suggestTextView {
    if (!_suggestTextView) {
        _suggestTextView = [[UITextView alloc] init];
        _suggestTextView.backgroundColor = [UIColor whiteColor];
        _suggestTextView.font = [UIFont systemFontOfSize:14];
        _suggestTextView.delegate = self;
        _suggestTextView.returnKeyType = UIReturnKeyDone;
    }
    return _suggestTextView;
}

- (UILabel *)suggsetPlaceHolderLabel {
    if (!_suggsetPlaceHolderLabel) {
        _suggsetPlaceHolderLabel = [[UILabel alloc] init];
        _suggsetPlaceHolderLabel.text = kLocalizationFeedbackContent;
        [_suggsetPlaceHolderLabel sizeToFit];
        _suggsetPlaceHolderLabel.textColor = COLOR_CCCCCC;
        _suggsetPlaceHolderLabel.font = [UIFont systemFontOfSize:14];
    }
    return _suggsetPlaceHolderLabel;
}

- (UILabel *)emailTitleLabel {
    if (!_emailTitleLabel) {
        _emailTitleLabel = [[UILabel alloc] init];
        _emailTitleLabel.text = [NSString stringWithFormat:@" %@",kLocalizationEmail];
        _emailTitleLabel.backgroundColor = [UIColor whiteColor];
    }
    return _emailTitleLabel;
}

- (UITextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[UITextField alloc] init];
        _emailTextField.placeholder = kLocalizationFeedbackEmail;
        _emailTextField.delegate = self;
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailTextField.font = [UIFont systemFontOfSize:14];
        _emailTextField.backgroundColor = [UIColor whiteColor];
        _emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _emailTextField;
}


- (ColorButton *)sendButton {
    if (!_sendButton) {
        NSMutableArray *colors = [NSMutableArray arrayWithObjects:[UIColor hx_colorWithHexString:@"ff4572"],
                                  [UIColor hx_colorWithHexString:@"fd4cbe"], nil];
        _sendButton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, 300, 45) FromColorArray:colors ByGradientType:leftToRight];
        _sendButton.enabled = NO;
        [_sendButton setTitle:kLocalizationButtonSend forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor hx_colorWithHexString:@"ffffff" alpha:0.5] forState:UIControlStateDisabled];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(onTouchSendButton) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.backgroundColor = COLOR_MAIN;
        _sendButton.layer.cornerRadius = 22.5;
        _sendButton.layer.masksToBounds = YES;
        
    }
    return _sendButton;
}

- (NSMutableDictionary *)parameter {
    if (!_parameter) {
        _parameter = [NSMutableDictionary dictionary];
        [_parameter setObject:self.suggestTextView.text forKey:@"content"];
        [_parameter setObject:self.emailTextField.text forKey:@"email"];
    }
    return _parameter;
}
#pragma mark - init -

+ (instancetype)feedBackViewController {
    FBFeedBackViewController *feedbackController = [[FBFeedBackViewController alloc] init];
    feedbackController.hidesBottomBarWhenPushed = YES;
    return feedbackController;
}

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = kLocalizationLabelFeedBack;
    
    [self configureUserInterface];
    [self.view bk_whenTapped:^{
        [self.emailTextField resignFirstResponder];
        [self.suggestTextView resignFirstResponder];
    }];
        [self.suggestTextView becomeFirstResponder];
}

#pragma mark - UI Management -
/** 配置反馈界面 */
- (void)configureUserInterface {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.suggestTitleLabel];
    [self.scrollView addSubview:self.suggestTextView];
    [self.scrollView addSubview:self.suggsetPlaceHolderLabel];
    [self.scrollView addSubview:self.emailTitleLabel];
    [self.scrollView addSubview:self.emailTextField];
    [self.scrollView addSubview:self.sendButton];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.view);
    }];
    
    [self.suggestTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.scrollView);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 40));
    }];
    
    [self.suggestTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.suggestTitleLabel.mas_bottom);
        make.left.equalTo(self.view);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 120));
    }];
    
    [self.suggsetPlaceHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.suggestTextView).offset(7);
        make.left.equalTo(self.suggestTextView).offset(5);
    }];
    
    [self.emailTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.suggestTextView.mas_bottom).offset(10);
        make.left.equalTo(self.view);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 40));
    }];
    
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailTitleLabel.mas_bottom);
        make.left.equalTo(self.view).offset(5);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH-5, 40));
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailTextField.mas_bottom).offset(20);
        make.centerX.equalTo(self.scrollView);
        make.size.equalTo(CGSizeMake(285, 45));
    }];
    
    
    UIView *emailTextFieldBackgroundView = [[UIView alloc] init];
    emailTextFieldBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.scrollView insertSubview:emailTextFieldBackgroundView belowSubview:self.emailTextField];
    [emailTextFieldBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailTitleLabel.mas_bottom);
        make.left.equalTo(self.scrollView);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 40));
    }];
    
}

#pragma mark - Network Management -
/** 上传发送信息的网络请求 */
- (void)requestForUploadSuggestion{
    NSString *suggestion = [self dictionaryToJson:self.parameter];
    [[FBProfileNetWorkManager sharedInstance] uploadFeedbackWithQuession:suggestion success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showProgressHUDWithTips:kLocalizationSuccessfully];
        [self performSelector:@selector(popViewController) withObject:nil afterDelay:3.0];
    } failure:^(NSString *errorString) {
        [self showProgressHUDWithTips:kLocalizationError];
    } finally:^{
    }];
}




#pragma mark - Event Handler -

- (void)onTouchSendButton {
    if ([self.emailTextField.text isValidEmail]) {
        [self showProgressHUDWithTips:kLocalizationLoading];
        [self.emailTextField resignFirstResponder];
        [self.suggestTextView resignFirstResponder];
        [self requestForUploadSuggestion];
    } else {
        [self showProgressHUDWithTips:kLocalizationEmailIncorrect];
    }

}

#pragma mark - UITextView Delegate -
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if (textView.text.length > kMaxLength) {
        return NO;
    }
    char delete = [text UTF8String][0];
    if (delete == '\000') {
        return YES;
    }
    if(textView.text.length == kMaxLength) {
        if(![text isEqualToString:@"\b"]) return NO;
    }
    

    return YES;
    
}


/** 该判断用于联想输入 */
-(void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text.length > kMaxLength)
    {
        textView.text = [textView.text substringToIndex:kMaxLength];
    }
    
    if (([textView.text isEqualToString:@"\n"])) {
        [textView resignFirstResponder];
    }
    
    if (textView.text.length > 0 ) {
        _suggsetPlaceHolderLabel.hidden = YES;
    } else {
        _suggsetPlaceHolderLabel.hidden = NO;
    }
}


#pragma mark - UITextField Delegate -
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.emailTextField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length > 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate - 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.emailTextField resignFirstResponder];
    [self.suggestTextView resignFirstResponder];
}

#pragma mark - Navigation -
- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper -
/** 显示的提示语 */
- (void)showProgressHUDWithTips:(NSString *)tips {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = tips;
    hud.margin = 10.f;
    hud.yOffset = 0.0f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:3];
}


- (NSString *)dictionaryToJson:(NSDictionary *)dic {
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

@end
