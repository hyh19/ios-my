#import "ZWVerticalSeparator.h"

@implementation ZWVerticalSeparator

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 231/255.0, 231/255.0, 231/255.0, 1.0);
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, self.bounds.size.width, 0.0);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextStrokePath(context);
}

@end
