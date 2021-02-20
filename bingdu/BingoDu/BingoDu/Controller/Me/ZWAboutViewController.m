#import "ZWAboutViewController.h"
#import "ZWVersionManager.h"
#import "UIDevice+HardwareName.h"

@interface ZWAboutViewController ()
@property (strong, nonatomic) UIButton *updataButton;
@property (strong, nonatomic) UILabel *versionLabel;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@end

@implementation ZWAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于并读";
    [MobClick event:@"about_page_show"];//友盟统计
    [self.view addSubview:[self iconImageView]];
    [self.view addSubview:[self titleLabel]];
    [self.view addSubview:self.versionLabel];
    [self.view addSubview:[self companyLabel]];
    [self.view addSubview:[self updataButton]];
    
    // 判断是否有版本更新，有则显示版本更新的按钮，否则隐藏起来
    if([ZWVersionManager hasNewVersion])
    {
        [[self updataButton] setHidden:NO];
    }
    else
        [[self updataButton] setHidden:YES];
    
    [self showSimpleVersion];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (UIButton *)updataButton
{
    if(!_updataButton)
    {
        _updataButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _updataButton.frame = CGRectMake(0, 80+92+40+30+50, 210, 44);
        _updataButton.center = CGPointMake(self.view.center.x, _updataButton.center.y);
        [_updataButton setTitle:@"检测到新版本" forState:UIControlStateNormal];
        [_updataButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_updataButton setBackgroundColor:COLOR_MAIN];
        _updataButton.layer.cornerRadius = 5;
        [_updataButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_updataButton addTarget:self action:@selector(onTouchButtonCheckVersion) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updataButton;
}

- (UIImageView *)iconImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, 92, 92)];
    imageView.center = CGPointMake(self.view.center.x, imageView.center.y);
    imageView.image = [UIImage imageNamed:@"icon_logo"];
    
    return imageView;
}

- (UILabel *)titleLabel
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80+92+13, self.view.frame.size.width, 26)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:23];
    titleLabel.textColor = COLOR_333333;
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.text = @"我的精致生活";
    
    return titleLabel;
}

- (UILabel *)companyLabel
{
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 25)];
    companyLabel.textAlignment = NSTextAlignmentCenter;
    companyLabel.font = [UIFont systemFontOfSize:13];
    companyLabel.textColor = COLOR_848484;
    companyLabel.backgroundColor =[UIColor clearColor];
    companyLabel.text = @"Copyright ©2016.Southzw.com";
    
    return companyLabel;
}

- (UILongPressGestureRecognizer *)longPressRecognizer {
    if (!_longPressRecognizer) {
        _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showFullVersion)];
    }
    return _longPressRecognizer;
}

- (UILabel *)versionLabel {
    
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80+92+23 + 23, SCREEN_WIDTH, 20)];
        _versionLabel.backgroundColor = [UIColor clearColor];
        _versionLabel.textAlignment = NSTextAlignmentCenter;
        _versionLabel.numberOfLines = 3;
        _versionLabel.font = [UIFont systemFontOfSize:15];
        _versionLabel.textColor = COLOR_333333;
    }
    
    return _versionLabel;
}

/** 显示简单版本信息 */
- (void)showSimpleVersion {
    
    NSString *version = [NSString stringWithFormat:@"V%@", [ZWUtility versionCode]];
    self.versionLabel.text = version;
    self.versionLabel.frame = CGRectMake(0, 80+92+23 + 23, SCREEN_WIDTH, 20);
    [self.view addGestureRecognizer:self.longPressRecognizer];
}

/** 显示完整版本信息，包括App版本、设备型号、系统版本、运营商、网络环境、编译时间 */
- (void)showFullVersion {
    
    NSString *versionCode = [ZWUtility versionCode];
    NSString *buildCode = [ZWUtility buildCode];
    NSString *platform = [[UIDevice currentDevice] platformString];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *carrier = [ZWUtility carrierName];
    NSString *environment = [ZWUtility environment];
    
    // 获取Build时间
    // 添加BuildDateString到info.plist文件的方法：添加Run Script到相应Target的Build Phases
    NSString *buildDateString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BuildDateString"];
    
    NSString *versionText = [NSString stringWithFormat:@"V%@ (Build %@)\n%@, iOS %@, %@, %@\n%@",versionCode,buildCode,platform,systemVersion,carrier,environment, buildDateString];
    
    self.versionLabel.text = versionText;
    self.versionLabel.frame = CGRectMake(0, 80+92+23 + 23, SCREEN_WIDTH, 60);
    
    [self.view removeGestureRecognizer:self.longPressRecognizer];
    [self performSelector:@selector(showSimpleVersion) withObject:nil afterDelay:5];
}

#pragma mark - Event handler -
- (void)onTouchButtonCheckVersion {
    [ZWVersionManager checkVersionWithType:kVersionCheckTypeMannual
                               finishBlock:^(BOOL hasNewVersion, id versionData) {
                                   //
                               }];
}

@end
