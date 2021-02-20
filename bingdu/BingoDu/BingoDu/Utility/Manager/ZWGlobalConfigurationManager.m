#import "ZWGlobalConfigurationManager.h"
#import "AppDelegate.h"

@implementation ZWGlobalConfigurationManager

+ (void)configureNavigationBar {
    
    UINavigationBar* navigationBarAppearance = [UINavigationBar appearance];
    
    // change the tint color of everything in a navigation bar
    navigationBarAppearance.barTintColor = COLOR_MAIN;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        navigationBarAppearance.translucent = NO;
    }
    
    // change the font in all toolbar buttons
    NSDictionary *barButtonTitleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f],
                                                   NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [navigationBarAppearance setTitleTextAttributes:barButtonTitleTextAttributes];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleTextAttributes forState:UIControlStateNormal];
}

@end
