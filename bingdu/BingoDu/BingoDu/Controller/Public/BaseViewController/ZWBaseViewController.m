#import "ZWBaseViewController.h"
#import "UIButton+Block.h"

@interface ZWBaseViewController ()


@end

@implementation ZWBaseViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 解决底部出现白条的问题
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    self.backIsshow = YES;
    self.view.backgroundColor = COLOR_F8F8F8;
    __weak typeof(self) weakSelf = self;
    [self setupBackButtonWithActionBlock:^{
        [weakSelf onTouchButtonBack];
    }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onTouchButtonBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
