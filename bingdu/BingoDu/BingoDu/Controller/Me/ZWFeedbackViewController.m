#import "ZWFeedbackViewController.h"
#import "UMFeedback.h"
#import "ZWFeedbackTableView.h"
#import "DAKeyboardControl.h"
#import "ZWMessageModel.h"

@interface ZWFeedbackViewController ()<UITextFieldDelegate>

/**消息列表*/
@property (nonatomic, strong)ZWFeedbackTableView *messageTableView;

/**反馈意见输入框*/
@property (nonatomic, strong)UITextField *sendTextField;

/**发送工具条*/
@property (nonatomic, strong)UIToolbar *sendToolBar;

/**输入框背景图*/
@property (nonatomic, strong)UIImageView *textFieldBGImageView;
/**键盘控制器*/
@property (nonatomic, strong)ZWKeyBoardManager *keyBoardManager;
@end

@implementation ZWFeedbackViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"意见反馈";

    [MobClick event:@"feedback_page_show"];//友盟统计
    
    [self.view addSubview:[self messageTableView]];
    
    [self.view addSubview:[self sendToolBar]];
    
    [[self sendToolBar] addSubview:[self sendTextField]];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:@"发 送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:113./255 green:113./255 blue:113./255 alpha:1.] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.frame = CGRectMake([self sendToolBar].bounds.size.width - 68.0f,6.0f,58.0f,29.0f);
    [[self sendToolBar] addSubview:[self textFieldBGImageView]];
    [[self sendToolBar] addSubview:sendButton];
    //self.keyBoardManager.keyboardTriggerOffset = [self sendToolBar].bounds.size.height;
    __weak typeof(self) weakSelf=self;
    CGRect frame = [self sendToolBar].frame;
    [[self keyBoardManager] addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        
        CGRect toolBarFrame = frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        [weakSelf sendToolBar].frame = toolBarFrame;
        
        CGRect tableViewFrame = [weakSelf messageTableView].frame;
        tableViewFrame.size.height = toolBarFrame.origin.y;
        [weakSelf messageTableView].frame = tableViewFrame;

        if(weakSelf.messageTableView.contentSize.height > weakSelf.messageTableView.frame.size.height)
        {
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.messageTableView.contentOffset = CGPointMake(0, weakSelf.messageTableView.contentSize.height - weakSelf.messageTableView.frame.size.height);
            }];
            
        }
    } view:self.view];
    


}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[self keyBoardManager] removeKeyboardControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Getter & Setter

-(ZWKeyBoardManager*)keyBoardManager
{
    if (!_keyBoardManager)
    {
        _keyBoardManager=[[ZWKeyBoardManager alloc] init];
    }
    return _keyBoardManager;
}
- (UIToolbar *)sendToolBar
{
    if(!_sendToolBar)
    {
        _sendToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                         self.view.frame.size.height - 40.0f,
                                                                         self.view.bounds.size.width,
                                                                         40.0f)];
        _sendToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }
    return _sendToolBar;
}

- (ZWFeedbackTableView *)messageTableView
{
    if(!_messageTableView)
    {
        _messageTableView = [[ZWFeedbackTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40-22-44) style:UITableViewStylePlain];
        _messageTableView.backgroundColor = [UIColor clearColor];
        _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _messageTableView;
}

- (UITextField *)sendTextField
{
    if(!_sendTextField)
    {
        _sendTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f,6.0f,[self sendToolBar].bounds.size.width - 20.0f - 68.0f,30.0f)];
        _sendTextField.borderStyle = UITextBorderStyleNone;
        _sendTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _sendTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _sendTextField.delegate = self;
        
        _sendTextField.returnKeyType = UIReturnKeySend;
    }
    return _sendTextField;
}

- (UIImageView *)textFieldBGImageView
{
    if(!_textFieldBGImageView)
    {
        _textFieldBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 34, [self sendToolBar].bounds.size.width - 20.0f - 70.0f, 2)];
        _textFieldBGImageView.image = [[UIImage imageNamed:@"textfield_g"] stretchableImageWithLeftCapWidth:2 topCapHeight:1];
    }
    return _textFieldBGImageView;
}

#pragma mark - UI EventHandler
- (void)sendFeedback:(UIButton *)sender
{
    if([self sendTextField].text.length > 0)
    {
        NSDictionary *postContent = @{@"content":[self sendTextField].text,
                                      @"gender":@"",
                                      @"age_group":@"",
                                      @"type": @"user_reply"
                                      };
        [MobClick event:@"send_feedback"];//友盟统计
        [[self messageTableView].feedback post:postContent];
    }
    [self sendTextField].text = @"";
}

#pragma mark -UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self textFieldBGImageView].image = [[UIImage imageNamed:@"textfield_l"] stretchableImageWithLeftCapWidth:2 topCapHeight:1];

    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self textFieldBGImageView].image = [[UIImage imageNamed:@"textfield_g"] stretchableImageWithLeftCapWidth:2 topCapHeight:1];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self sendFeedback:nil];
    return YES;
}

@end
