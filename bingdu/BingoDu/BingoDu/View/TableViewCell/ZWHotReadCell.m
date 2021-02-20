#import "ZWHotReadCell.h"

@interface ZWHotReadCell ()

@property (strong, nonatomic) UIView *underLine;

@end

@implementation ZWHotReadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSeparator];
    }
    return self;
}

- (void)initSeparator {
    _underLine = [[UIView alloc] initWithFrame:CGRectZero];
    [_underLine setBackgroundColor:COLOR_E7E7E7];
    [self addSubview:_underLine];
    [self setBackgroundColor:COLOR_F8F8F8];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _underLine.frame = CGRectMake(10, self.frame.size.height - 0.5, self.frame.size.width - 20, 0.5);
    
    if (_isLifeStyleCell)
    {
        
        self.imageView.frame =CGRectMake(12,(70-40)/2,40,40);
        CGRect rect=self.textLabel.frame;
        rect.origin.x=64;
        rect.size.width=SCREEN_WIDTH-64-12;
        self.textLabel.frame=rect;
    }
    else
    {
        self.imageView.frame =CGRectMake(12,(self.bounds.size.height-49)/2,70,49);
        
        CGRect rect=self.textLabel.frame;
        rect.origin.x=92;
        rect.size.width=SCREEN_WIDTH-105;
        self.textLabel.frame=rect;
    }

    
    self.imageView.contentMode=UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds=YES;
}



@end
