#import "ZWMenuCell.h"
#import "UIImageView+WebCache.h"
#import "ZWActivityMenuModel.h"
#import "UIView+DOPExtension.h"

@interface ZWMenuCell ()

/** 菜单图标 */
@property (weak, nonatomic) IBOutlet UIImageView *icon;

/** 菜单角标 */
@property (weak, nonatomic) IBOutlet UIImageView *cornerMark;

/** 菜单标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/** 菜单副标题 */
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation ZWMenuCell

- (void)layoutSubviews {
    [super layoutSubviews];
    // 解决在iOS 9下控件位置错误的问题
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        self.titleLabel.dop_width = CGRectGetWidth(self.frame);
        self.subtitleLabel.dop_width = CGRectGetWidth(self.frame);
        CGPoint newCenter = CGPointMake(CGRectGetWidth(self.frame)/2, self.icon.center.y);
        self.icon.center = newCenter;
    }
}

- (void)setData:(ZWMenuModel *)data {
    
    _data = data;
    
    if (_data) {
        // 主标题
        self.titleLabel.text = _data.title;
        
        // 副标题
        self.subtitleLabel.text = _data.subtitle;
        
        // 普通菜单的图标显示本地图片，活动菜单的图标显示后端图片
        if ([_data isKindOfClass:[ZWActivityMenuModel class]]) {
            [self.icon sd_setImageWithURL:[NSURL URLWithString:_data.icon] placeholderImage:[UIImage imageNamed:@"icon_activity-menu"]];
        } else {
            [self.icon sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:_data.icon]];
        }
        
        if (_data.showCornerMark) {
            
            self.cornerMark.hidden = NO;
            
            // 普通菜单的角标显示本地图片，活动菜单的角标显示后端图片
            if ([_data isKindOfClass:[ZWActivityMenuModel class]]) {
                [self.cornerMark sd_setImageWithURL:[NSURL URLWithString:_data.cornerMark]];
            } else {
                [self.cornerMark sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:_data.cornerMark]];
            }
        } else {
            self.cornerMark.hidden = YES;
            self.cornerMark.image = nil;
        }
    } else {

        self.titleLabel.text = nil;
        
        self.subtitleLabel.text = nil;
        
        self.icon.image = nil;
        
        self.cornerMark.image = nil;
    }
}

@end
