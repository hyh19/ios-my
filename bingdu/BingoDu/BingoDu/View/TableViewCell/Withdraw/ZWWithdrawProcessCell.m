#import "ZWWithdrawProcessCell.h"

@implementation ZWWithdrawProcessCell

- (void)setData:(ZWWithdrawProcessModel *)model {
    
    _data = model;
    
    if (_data) {
        
        self.statusLabel.text = _data.statusString;
        
        self.timeLabel.text = _data.time;
        
        if ([_data.remark isValid]) {
            UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 30, SCREEN_WIDTH-56-24, 15)];
            tipLabel.font = [UIFont systemFontOfSize:12];
            tipLabel.textColor = [UIColor colorWithHexString:@"#a9a9a9"];
            tipLabel.numberOfLines = 0;
            tipLabel.text = _data.remark;
            [tipLabel sizeToFit];
            [self.contentView addSubview:tipLabel];
        }
        
        if (0 == _data.status) {
            
            self.pointImage.hidden = NO;
            
            self.pointView.hidden = YES;
            
        } else {
            
            self.pointImage.hidden = YES;
            
            self.pointView.hidden = NO;
            
            self.pointView.backgroundColor = [UIColor colorWithHexString:_data.color];
        }
    }
}

@end
