#import "ZWMenuModel.h"

@implementation ZWMenuModel

- (instancetype)initWithName:(NSString *)name
                       title:(NSString *)title
                    subtitle:(NSString *)subtitle
                        icon:(NSString *)icon
                  cornerMark:(NSString *)cornerMark
          nextViewController:(NSString *)nextViewController
                    showMenu:(BOOL)showMenu
              showCornerMark:(BOOL)showCornerMark {
    
    if (self = [super init]) {
        self.name              = name;
        self.title             = title;
        self.subtitle          = subtitle;
        self.icon              = icon;
        self.cornerMark        = cornerMark;
        self.nexViewController = nextViewController;
        self.showMenu          = showMenu;
        self.showCornerMark    = showCornerMark;
    }
    return self;
}


@end
