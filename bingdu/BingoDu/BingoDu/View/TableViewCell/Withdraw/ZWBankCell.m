#import "ZWBankCell.h"
#import "UIImageView+WebCache.h"

@interface ZWBankCell ()

/** 银行卡图标 */
@property (weak, nonatomic) IBOutlet UIImageView *logo;

/** 银行名称 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ZWBankCell

- (void)setData:(ZWBankModel *)data {
    _data = data;
    if (_data) {
        self.nameLabel.text = _data.name;
        [self.logo sd_setImageWithURL:[NSURL URLWithString:_data.logoURL]];
    }
}

@end
