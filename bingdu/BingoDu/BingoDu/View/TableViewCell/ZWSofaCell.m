#import "ZWSofaCell.h"
@interface ZWSofaCell()

@end
@implementation ZWSofaCell
/**初始化*/
- (void)awakeFromNib {
    
    @try {
        [self setBackgroundColor:COLOR_F8F8F8];
        [self.promptLabel setText:@"快来抢沙发、赢积分!"];
        [self.promptLabel setTextColor:COLOR_848484];
        [self.promptLabel setFont:[UIFont systemFontOfSize:12]];
        [self.promptLabel setFrame:self.contentView.bounds];
        self.promptLabel.textAlignment=NSTextAlignmentCenter;
    }
    @catch (NSException *exception) {
        NSLog(@"ZWSofaCell awakeFromNib error:%@",exception.reason);
    }
    @finally {
       
    }

}
@end
