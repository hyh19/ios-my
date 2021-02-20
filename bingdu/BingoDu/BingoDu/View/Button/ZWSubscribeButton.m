#import "ZWSubscribeButton.h"
#import "ZWSubscribeNewsListViewController.h"
#import "ZWSubscriptionViewController.h"
#import "ZWSubscribeManager.h"
#import "ZWLoginViewController.h"

@implementation ZWSubscribeButton

- (void)dealloc {
    [self removeObservers];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addObservers];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addObservers];
    }
    return self;
}

/** 添加广播监听 */
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationStatusChange:) name:kNotificationSubscriptionStatusChange object:nil];
}

/** 移除广播监听 */
- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSubscriptionStatusChange object:nil];
}

- (void)setModel:(ZWSubscriptionModel *)model {
    _model = model;
    if (self.statusChangeBlock) { self.statusChangeBlock(self); }
}

- (void)postStatusChangeNotification {
    NSNotification *notification = [NSNotification notificationWithName:kNotificationSubscriptionStatusChange object:self.model];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

/** 响应订阅按钮状态变更通知 */
- (void)onNotificationStatusChange:(NSNotification *)notification {
    // 比较所引用的订阅号对象，判断是否需要响应广播通知，同一个订阅号对象可能被不同界面的订阅按钮引用，例如
    // 订阅号列表界面的订阅按钮和该订阅号新闻详情列表界面的订阅按钮引用的是同一个订阅号对象
    if (notification.object == self.model) {
        self.model = notification.object;
    }
}

@end
