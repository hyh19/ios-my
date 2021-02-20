#import "FBLiveGiftAnimationView.h"
#import "FBFlyingGiftView.h"

/** 礼物播放通道的Y坐标 */
#define kGiftAnimationPahtOriginY @"originY"

/** 礼物播放通道是否可用 */
#define kGiftAnimationPathEnable @"enable"

@interface FBLiveGiftAnimationView ()

/** 等待播放的礼物队列 */
@property (nonatomic, strong) NSMutableArray *giftWaitingQueue;

/** 正在播放的礼物队列 */
@property (nonatomic, strong) NSMutableArray *giftPlayingQueue;

/** 礼物播放的通道 */
@property (nonatomic, strong) NSMutableArray *giftAnimationPaths;

@end

@implementation FBLiveGiftAnimationView

- (NSMutableArray *)giftWaitingQueue {
    if (!_giftWaitingQueue) {
        _giftWaitingQueue = [NSMutableArray array];
    }
    return _giftWaitingQueue;
}

- (NSMutableArray *)giftPlayingQueue {
    if (!_giftPlayingQueue) {
        _giftPlayingQueue = [NSMutableArray array];
    }
    return _giftPlayingQueue;
}

- (NSMutableArray *)giftAnimationPaths {
    if (!_giftAnimationPaths) {
        _giftAnimationPaths = [NSMutableArray array];
        NSMutableDictionary *path1 = [NSMutableDictionary dictionary];
        path1[kGiftAnimationPahtOriginY] = @0;
        path1[kGiftAnimationPathEnable] = @YES;
        [_giftAnimationPaths addObject:path1];
        
        NSMutableDictionary *path2 = [NSMutableDictionary dictionary];
        path2[kGiftAnimationPahtOriginY] = @60;
        path2[kGiftAnimationPathEnable] = @YES;
        [_giftAnimationPaths addObject:path2];
    }
    return _giftAnimationPaths;
}

- (void)receiveGift:(FBGiftModel *)gift {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gift.giftID = %@ && gift.fromUser.userID = %@", gift.giftID, gift.fromUser.userID];
    NSArray *array = [self.giftPlayingQueue filteredArrayUsingPredicate:predicate];
    // 如果收到的礼物正在播放队列中，则播放队列中的礼物数加1
    if ([array count] > 0) {
        FBFlyingGiftView *view = [array firstObject];
        view.sum += 1;
    } else {
        // 如果收到的礼物不在播放队列中，则加入等待队列
        FBFlyingGiftView *view = [[FBFlyingGiftView alloc] initWithFrame:CGRectMake(-210, 0, 210, 50)];
        view.gift = gift;
        view.sum = 1;
        [self.giftWaitingQueue addObject:view];
    }
    // 播放通道可用时，马上播放礼物动画
    if ([self.giftPlayingQueue count] < 2) {
        [self playAnimation];
    }
}

/** 播放礼物动画 */
- (void)playAnimation {
    for (NSMutableDictionary *path in self.giftAnimationPaths) {
        // 检测可用的通道
        if ([path[kGiftAnimationPathEnable] boolValue]) {
            
            FBFlyingGiftView *flyingView = [self.giftWaitingQueue firstObject];
            if (flyingView) {
                __weak typeof(self) wself = self;
                __weak FBFlyingGiftView *weakview = flyingView;
                flyingView.doCompleteAction = ^ (void) {
                    // 动画播放完毕播放队列中移除
                    [wself.giftPlayingQueue removeObject:weakview];
                    // 重新将通道标记为可用
                    path[kGiftAnimationPathEnable] = @YES;
                    // 如果等待队列中仍有礼物，继续播放下一个动画
                    if ([wself.giftWaitingQueue count] > 0) {
                        [wself playAnimation];
                    }
                };
                // 礼物数字增加时，执行回调动作，如左上角钻石数增加
                flyingView.doAddingNumberCallback = ^ (FBGiftModel *gift) {
                    if (wself.doAddingNumberCallback) {
                        wself.doAddingNumberCallback(gift);
                    }
                };
                
                // 将可用通道标记为被占用
                path[kGiftAnimationPathEnable] = @NO;
                flyingView.dop_y = [path[kGiftAnimationPahtOriginY] floatValue];
                [self addSubview:flyingView];
                // 加入正在播放队列并从等待队列中移除
                [self.giftPlayingQueue addObject:flyingView];
                [self.giftWaitingQueue removeObject:flyingView];
                
                [UIView animateWithDuration:0.5 animations:^{
                    weakview.dop_x = 0;
                } completion:^(BOOL finished) {
                    // 礼物出现后，开始播放数字动画
                    [weakview animateNumber];
                }];
            }
            break;
        }
    }
}

- (BOOL)isAnimating {
    return ([self.giftPlayingQueue count] > 0);
}


@end
