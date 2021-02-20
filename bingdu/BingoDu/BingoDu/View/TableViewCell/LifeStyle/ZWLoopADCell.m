#import "ZWLoopADCell.h"
#import "ALView+PureLayout.h"
#import "UIImageView+WebCache.h"
#import "UIView+WhenTappedBlocks.h"
#import "AutoSlideScrollView.h"

@interface ZWLoopADCell ()

/** 轮播 */
@property (nonatomic, strong) UIScrollView *scrollView;

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic , strong) AutoSlideScrollView *mainScorllView;

@end

@implementation ZWLoopADCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CGFloat imageInset = 2;
        CGFloat imageWidth = 303;
        CGFloat imageHeight = 95;
        CGFloat scrollWidth = imageWidth + 2*imageInset;
        
        NSMutableArray *viewsArray = [@[] mutableCopy];
        for (int i = 1; i <= 5; ++i) {
            ZWLoopADView *view = [[ZWLoopADView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, imageHeight)];
            NSURL *picurl = [NSURL URLWithString:@"http://image.bingodu.com/group1/M04/04/88/CgELI1bCyBuAFtXlAAOYWiJTOos94.jpeg"];
            [view.imageView sd_setImageWithURL:picurl placeholderImage:[UIImage imageNamed:@"icon_banner_ad"] options:SDWebImageRetryFailed];
            view.label.text = [NSString stringWithFormat:@"%ld", (long)i];
            [viewsArray addObject:view];
        }
        
        self.mainScorllView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-scrollWidth)/2, 10, scrollWidth, imageHeight) animationDuration:0];
        self.mainScorllView.backgroundColor = [UIColor clearColor];
        [self.mainScorllView debugWithBorderColor:[UIColor redColor] andBorderWidth:1];
        
        self.mainScorllView.totalPagesCount = ^NSInteger(void){
            return viewsArray.count;
        };
        self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            return viewsArray[pageIndex];
        };
        __weak typeof(self) weakSelf = self;
        self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
            if ([weakSelf.delegate respondsToSelector:@selector(tapBanner)]) {
                [weakSelf.delegate tapBanner];
            }
        };
        [self addSubview:self.mainScorllView];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    BOOL lock = ([hitView isKindOfClass:[UIScrollView class]] ||
                 [hitView isKindOfClass:[UIImageView class]]);
    NSNotification *notification = [NSNotification notificationWithName:kNotificationLockLifeStyleMainViewController object:@(!lock)];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    return hitView;
}

@end

@interface ZWLoopADView ()

@property (nonatomic , strong) AutoSlideScrollView *mainScorllView;

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;


@end

@implementation ZWLoopADView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        [self addSubview:self.label];
    }
    return self;
}


- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:4];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:4];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        
        [self.label autoSetDimensionsToSize:CGSizeMake(26, 14)];
        [self.label autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8];
        [self.label autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (UILabel *)label {
    if (!_label) {
        _label = [UILabel newAutoLayoutView];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = @"推广";
        _label.textColor = [UIColor whiteColor];
        _label.font = FONT_SIZE_SYSTEM(8);
        _label.backgroundColor = COLOR_MAIN;
        _label.numberOfLines = 1;
    }
    return _label;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView newAutoLayoutView];
    }
    return _imageView;
}

@end
