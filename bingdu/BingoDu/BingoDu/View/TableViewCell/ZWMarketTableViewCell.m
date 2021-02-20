#import "ZWMarketTableViewCell.h"
#import "ZWActivityMenuModel.h"
#import "UIImageView+WebCache.h"
#import "UIView+DOPExtension.h"

@interface ZWMarketTableViewCell ()

/** 菜单图标 */
@property (strong, nonatomic) IBOutlet UIImageView *icon;

/** 菜单角标 */
@property (strong, nonatomic) IBOutlet UIImageView *cornerMark;

/** 菜单标题 */
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

/** 菜单副标题 */
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;

/** 广告按钮 */
@property (strong, nonatomic) IBOutlet UIButton *advertiseButton;

@end

@implementation ZWMarketTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

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
            
            // 点击红点显示过的礼品商城之后，红点角标不再显示
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"GoodsMall"]) {
                
                NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"GoodsMall"];
                
                if ([[dic objectForKey:@"menu"] isEqualToString:_data.name]) {
                    self.cornerMark.hidden = YES;
                }
            }
            
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

/** 显示广告的button */
- (IBAction)onTouchButtonAdvertise:(id)sender {
    if([[self delegate] respondsToSelector:@selector(clickAdvertisementWithMarketTableViewCell:)]) {
        [[self delegate] clickAdvertisementWithMarketTableViewCell:self];
    }
}

/** 删除广告的button */
- (IBAction)onTouchButtonDelete:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(closeAdvertisementWithMarketTableViewCell:)]) {
        [self.advertiseButton removeFromSuperview];
        [[self delegate] closeAdvertisementWithMarketTableViewCell:self];
    }
}

@end
