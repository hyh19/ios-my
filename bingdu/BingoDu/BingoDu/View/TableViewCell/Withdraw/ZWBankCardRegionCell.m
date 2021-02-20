#import "ZWBankCardRegionCell.h"

@interface ZWBankCardRegionCell()

/** 银行卡归属地区名称 */
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;

@end

@implementation ZWBankCardRegionCell

- (void)setData:(ZWBankCardRegionModel *)data {
    _data = data;
    if (_data) {
        self.regionLabel.text = _data.regionName;
    }
    
}

@end
