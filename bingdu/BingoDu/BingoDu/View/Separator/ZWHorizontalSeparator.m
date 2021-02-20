#import "ZWHorizontalSeparator.h"

@implementation ZWHorizontalSeparator

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 231/255.0, 231/255.0, 231/255.0, 1.0);
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0.0);
    CGContextStrokePath(context);
}

@end
