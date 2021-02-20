#import "FBLikeEmitter.h"
#import "PocketSVG.h"

@interface FBLikeEmitter ()

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation FBLikeEmitter

- (NSMutableArray *)array {
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}

- (void)receiveLikeWithColor:(UIColor *)color {
    [self.array addObject:color];
    if (!self.timer) {
        self.timer = [NSTimer bk_scheduledTimerWithTimeInterval:0.22 block:^(NSTimer *timer) {
            UIColor *color = [self.array firstObject];
            [self emitLikeWithColor:color];
            [self.array removeObject:color];
            if (self.array.count <= 0) {
                [self.timer invalidate];
                self.timer = nil;
            }
        } repeats:YES];
    }
}

- (void)emitLikeWithColor:(UIColor *)color {
    CGPoint pointA = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    NSInteger randomOffsetX = [self randomNumberBetweenMin:-10 Max:10];
    NSInteger randomOffsetY = [self randomNumberBetweenMin:60 Max:80];
    CGPoint pointB = CGPointMake(pointA.x+randomOffsetX, pointA.y-randomOffsetY);
    randomOffsetX = [self randomNumberBetweenMin:-15 Max:15];
    randomOffsetY = [self randomNumberBetweenMin:80 Max:100];
    CGPoint pointC = CGPointMake(pointB.x+randomOffsetX, pointB.y-randomOffsetY);
    randomOffsetX = [self randomNumberBetweenMin:-20 Max:-20];
    randomOffsetY = [self randomNumberBetweenMin:100 Max:120];
    CGPoint pointD = CGPointMake(pointC.x+randomOffsetX, pointC.y-randomOffsetY);
    
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:pointA];
    [bezierPath addQuadCurveToPoint:pointB
                       controlPoint:CGPointMake(pointB.x, (pointA.y+pointB.y)/2)];
    [bezierPath addQuadCurveToPoint:pointC
                       controlPoint:CGPointMake(pointC.x, (pointB.y+pointC.y)/2)];
    [bezierPath addQuadCurveToPoint:pointD
                       controlPoint:CGPointMake(pointC.x, (pointC.y+pointD.y)/2)];
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.path = bezierPath.CGPath;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.strokeColor = [UIColor clearColor].CGColor;
    pathLayer.lineWidth = 3.0f;
    [self.layer addSublayer:pathLayer];
    
    CAShapeLayer *contentLayer = [CAShapeLayer layer];
    contentLayer.path = [FBUtility likeLHeartPath].CGPath;
    contentLayer.position = CGPointMake(SCREEN_WIDTH, SCREEN_HEIGH);
    contentLayer.fillColor = color.CGColor;
    contentLayer.strokeColor = [UIColor whiteColor].CGColor;
    contentLayer.lineWidth = 1;
    
    [self.layer addSublayer:contentLayer];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animation];
    positionAnimation.keyPath = @"position";
    positionAnimation.path = bezierPath.CGPath;
    positionAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animation];
    scaleAnimation.keyPath = @"transform.scale";
    scaleAnimation.duration = 0.5;
    scaleAnimation.fromValue = @0;
    scaleAnimation.toValue = @1;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animation];
    opacityAnimation.keyPath = @"opacity";
    opacityAnimation.fromValue = @0.7;
    opacityAnimation.toValue = @0;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[positionAnimation, scaleAnimation, opacityAnimation];
    groupAnimation.duration = [self randomNumberBetweenMin:2 Max:5];
    groupAnimation.delegate = self;
    [groupAnimation setValue:contentLayer forKey:@"layer"];
    
    [contentLayer addAnimation:groupAnimation forKey:nil];
}

#pragma mark - Animation Progress -
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    CALayer *layer = [theAnimation valueForKey:@"layer"];
    [layer removeFromSuperlayer];
}

#pragma mark - Help -
- (int)randomNumberBetweenMin:(int)min Max:(int)max {
    return min + arc4random() % (max - min + 1);
}

@end
