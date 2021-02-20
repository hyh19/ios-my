#import "FBBaseNavigationController.h"
#import "UINavigationBar+Addition.h"
#import "UINavigationBar+Awesome.h"
#import "UIImage+FB.h"

@interface FBBaseNavigationController ()

@end

@implementation FBBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏的背景
    UIImage *image = [UIImage imageFromGradientColors:@[COLOR_MAIN, COLOR_MAIN_GRADIENT] withSize:CGSizeMake(SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT)];
    UIColor *color = [UIColor colorWithPatternImage:image];
    [self.navigationBar lt_setBackgroundColor:color];
    
    // 设置导航栏的字体
    NSDictionary *barButtonTitleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f],
                                                   NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationBar setTitleTextAttributes:barButtonTitleTextAttributes];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
    // 隐藏导航栏的分割线
    [self.navigationBar hideBottomHairline];
}

@end
