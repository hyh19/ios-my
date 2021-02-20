#import "FBBaseStoreViewController.h"

@interface FBBaseStoreViewController ()

@end

@implementation FBBaseStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    self.tableView.scrollEnabled = NO;
}

@end
