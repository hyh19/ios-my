#import "FBGiftKeyboard.h"
#import "FBGiftPageView.h"

/** 礼物键盘的高度 */
#define kGiftKeyboardHeight 250

@interface FBGiftKeyboard ()

/** 礼物列表 */
@property (nonatomic, strong) FBGiftPageView *contentView;

@end

@implementation FBGiftKeyboard

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UIView *superView = self;
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(superView);
            make.height.equalTo(kGiftKeyboardHeight);
        }];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    CGPoint hitPoint = [self.contentView convertPoint:point fromView:self];
    if (![self.contentView pointInside:hitPoint withEvent:event]) {
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCloseGiftKeyboard object:nil];
    }
    return hitView;
}

- (FBGiftPageView *)contentView {
    if (!_contentView) {
        _contentView = [[FBGiftPageView alloc] init];
        _contentView.backgroundColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.75];
        __weak typeof(self) wself = self;
        _contentView.doSendGiftAction = ^ (FBGiftModel *gift) {
            wself.doSendGiftAction(gift);
        };
        _contentView.doPurchaseAction = ^ () {
            wself.doPurchaseAction();
        };
    }
    return _contentView;
}

- (void)deductBalance:(NSInteger)count {
    [self.contentView deductBalance:count];
}

@end
