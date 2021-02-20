#import "ZWUserMaterialVC.h"
#import "ZWMoneyNetworkManager.h"

@interface ZWUserMaterialVC ()<UITextFieldDelegate>
@property (nonatomic,strong)UITextField *userInfoField;
@end

@implementation ZWUserMaterialVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor=COLOR_F8F8F8;
    self.title = @"填写资料";
    [self addModuleView];

}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [UIViewController pushLoginViewControllerIfNeededFromViewController:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark 界面ui元素
/**
 
 
 添加ui元素
 */
-(void)addModuleView
{
    
    UILabel *topPromptLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 0 , SCREEN_WIDTH-15, 40)];
    [topPromptLabel setBackgroundColor:[UIColor clearColor]];
    [topPromptLabel setFont:[UIFont systemFontOfSize:12]];
    [topPromptLabel setTextAlignment:NSTextAlignmentLeft];
    [topPromptLabel setText:@"*请写下您在这个应用商店的用户名,以便审核:"];
    [topPromptLabel setTextColor:COLOR_848484];
    [self.view addSubview:topPromptLabel];
    UITextField *userInfoField= [[UITextField alloc]initWithFrame:CGRectMake(15, topPromptLabel.frame.size.height+topPromptLabel.frame.origin.y+10, SCREEN_WIDTH-15*2, 40)];
    userInfoField.borderStyle=UITextBorderStyleNone;
    userInfoField.textColor=COLOR_A4A4A4;
    userInfoField.font=[UIFont systemFontOfSize:15];
    userInfoField.placeholder=@"请输入";
    userInfoField.delegate=self;
    userInfoField.layer.borderColor=[[UIColor grayColor] CGColor];
    [self.view addSubview:userInfoField];
    self.userInfoField=userInfoField;
    UIButton *submitButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submitButton addTarget:self action:@selector(submitSure) forControlEvents:UIControlEventTouchUpInside];
    [submitButton.layer setCornerRadius:5.0f];
    [submitButton setTitle:@"确认提交" forState:UIControlStateNormal];
    [submitButton setFrame:CGRectMake(20, userInfoField.frame.size.height+userInfoField.frame.origin.y+20, SCREEN_WIDTH-20*2, 50)];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setBackgroundColor:COLOR_MAIN];
    [self.view addSubview:submitButton];
    
}
#pragma mark 提交信息的逻辑
/**
 
 
 提交信息
 */
-(void)submitSure
{
    if (self.userInfoField.text.length!=0) {
        //提交后台接口 参数：并读用户名 应用商店 用户名称 当前时间
        [[ZWMoneyNetworkManager sharedInstance] postUserHighOpinionInfo:self.activityId
                                              userId:[ZWUserInfoModel userID]
                                                name:self.userInfoField.text
                                              succed:^(id result) {
                                                  occasionalHint(@"提交成功");
                                                  [self.navigationController popViewControllerAnimated:YES];
                                              } failed:^(NSString *errorString) {
                                                  occasionalHint(errorString);
                                                  [self.navigationController popViewControllerAnimated:YES];
                                              }];
    }else
        occasionalHint(@"请准确填写您在这个应用商店的用户名");
}

#pragma mark UITextField代理
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

@end
