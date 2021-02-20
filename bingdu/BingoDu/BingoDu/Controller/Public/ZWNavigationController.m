#import "ZWNavigationController.h"

@interface ZWNavigationController ()

@end

@implementation ZWNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *navigationBar = self.navigationBar;
    navigationBar.tintColor = [UIColor whiteColor];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        navigationBar.translucent = NO;
    }
}

@end
