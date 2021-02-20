#import "FBBaseViewController.h"

@interface FBBaseViewController ()

/** 消息通知 */
@property (nonatomic, strong, readwrite) CWStatusBarNotification *notification;

@end

@implementation FBBaseViewController

#pragma mark - Getter & Setter -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeBackBarButtonItemStyle];
}

//自定义返回按钮图片
- (void)changeBackBarButtonItemStyle {
    UIImage *image = [UIImage imageNamed:@"back_nor"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
