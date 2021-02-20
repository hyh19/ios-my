#import "UIViewController+XX.h"

@implementation UIViewController (XX)

+ (UIViewController *)viewControllerWithStoryboardName:(NSString *)storyboardName
                                          storyboardID:(NSString *)storyboardID {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:storyboardID];
    return viewController;
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
    space.width = -3;
    
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
