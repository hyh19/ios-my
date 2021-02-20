#import "UIViewController+NHZW.h"
#import "ZWBindViewController.h"
#import "AppDelegate.h"
#import "UIButton+Block.h"

@implementation UIViewController (NHZW)

+ (UIViewController *)currentViewController {
    
    UIViewController *result;
    
    // Try to find the root view controller programmically
    
    // Find the top window (that is not an alert view or other window)
    
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        for (topWindow in windows) {
            if (topWindow.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        
        result = nextResponder;
        
    } else if ([topWindow respondsToSelector:@selector(rootViewController)] &&
               topWindow.rootViewController != nil) {
        
        result = topWindow.rootViewController;
        
    } else {
        
        NSAssert(NO, @"Could not find a root view controller.");
    }
    
    return result;
}

+ (UIViewController *)viewControllerWithStoryboardName:(NSString *)storyboardName
                                          storyboardID:(NSString *)storyboardID {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:storyboardID];
    return viewController;
}

@end

@implementation UIViewController (Navigation)

+ (void)pushLinkMobileViewControllerIfNeededFromViewController:(UIViewController *)controller {
    
    __weak UIViewController *weakInstance = controller;
    
    [self hint:@"您还没有绑定手机号码，无法接收验证码"
     trueTitle:@"立即绑定"
     trueBlock:^{
         ZWBindViewController *viewController = [ZWBindViewController viewController];
         [weakInstance.navigationController pushViewController:viewController animated:YES];
         
     } cancelTitle:@"暂不" cancelBlock:^{}];
}

+ (void)pushLoginViewControllerIfNeededFromViewController:(UIViewController *)controller {
    
    __weak UIViewController *weakInstance = controller;
    
    if(![ZWUserInfoModel login]) {
        [weakInstance.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end

@implementation UIViewController (Appearance)

- (void)setupTitleViewWithText:(NSString *)text color:(UIColor *)color size:(CGFloat)size {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:size];
    titleLabel.textColor = color;
    titleLabel.text = text;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

@end

@implementation UIViewController (barButtonItem)

- (void)setupBackButtonWithActionBlock:(void(^)())actionBlock {
    UIImage *image = [UIImage imageNamed:@"btn_back_nav"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [button addAction:^(UIButton *btn) {
        if (actionBlock) {
            actionBlock();
        }
    }];
    [self setupLeftBarButtonItem:button];
}

- (void)setupLeftBarButtonItem:(UIButton *)leftButton {
    [self setupLeftBarButtonItem:leftButton rightBarButtonItem:nil];
}

- (void)setupRightBarButtonItem:(UIButton *)rightButton {
    [self setupLeftBarButtonItem:nil rightBarButtonItem:rightButton];
}

- (void)setupLeftBarButtonItem:(UIButton *)leftButton rightBarButtonItem:(UIButton *)rightButton {
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                              target:nil
                              action:nil];
    space.width = -14;
    
    UIBarButtonItem *leftItem = nil;
    UIBarButtonItem *rightItem = nil;
    if (leftButton) { leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton]; }
    if (rightButton) { rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton]; }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        // 解决位置偏移和触摸范围太大的问题
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:nil
                                                                     action:nil];
        if (leftItem) {
            self.navigationItem.leftBarButtonItems = @[space, leftItem, spaceItem];
        }
        
        if (rightItem) {
            self.navigationItem.rightBarButtonItems = @[space, rightItem, spaceItem];
        }
        
    } else {
        
        if (leftItem) {
            self.navigationItem.leftBarButtonItems = @[space, leftItem];
        }
        
        if (rightItem) {
            self.navigationItem.rightBarButtonItems = @[space, rightItem];
        }
    }
}

@end
