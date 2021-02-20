#import "FBBaseTableViewController.h"

@interface FBBaseTableViewController ()

@end

@implementation FBBaseTableViewController

- (void)dealloc {
    self.tableView.delegate = nil;
}

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

@end
