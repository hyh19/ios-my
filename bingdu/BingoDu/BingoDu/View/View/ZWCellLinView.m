#import "ZWCellLinView.h"

@implementation ZWCellLinView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef cont = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(cont, COLOR_E7E7E7.CGColor);
    CGContextSetLineWidth(cont, 0.5);
//    CGFloat lengths[] = {2,2};
//    CGContextSetLineDash(cont, 0, lengths, 2);//画虚线
    CGContextBeginPath(cont);
    CGContextMoveToPoint(cont, 0.0, rect.size.height - 1);
    CGContextAddLineToPoint(cont, SCREEN_WIDTH, rect.size.height - 1);
    CGContextStrokePath(cont);
}

@end
