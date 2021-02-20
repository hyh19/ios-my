#import "FBVIPEnterAnimationContainer.h"
#import "FBVIPEnterAnimationCell.h"

/** 播放动画通道的Y坐标 */
#define kVIPAnimationPahtOriginY @"originY"

/** 播放动画通道是否可用 */
#define kVIPAnimationPathEnable @"enable"

@interface FBVIPEnterAnimationContainer ()

/** 等待播放的队列 */
@property (nonatomic, strong) NSMutableArray *waitingQueue;

/** 正在播放的队列 */
@property (nonatomic, strong) NSMutableArray *playingQueue;

/** 播放动画的通道 */
@property (nonatomic, strong) NSMutableArray *animationPaths;

@end

@implementation FBVIPEnterAnimationContainer

#pragma mark - Getter & Setter -
- (NSMutableArray *)waitingQueue {
    if (!_waitingQueue) {
        _waitingQueue = [NSMutableArray array];
    }
    return _waitingQueue;
}

- (NSMutableArray *)playingQueue {
    if (!_playingQueue) {
        _playingQueue = [NSMutableArray array];
    }
    return _playingQueue;
}

- (NSMutableArray *)animationPaths {
    if (!_animationPaths) {
        _animationPaths = [NSMutableArray array];
        NSMutableDictionary *path = [NSMutableDictionary dictionary];
        path[kVIPAnimationPahtOriginY] = @0;
        path[kVIPAnimationPathEnable] = @YES;
        [_animationPaths addObject:path];
    }
    return _animationPaths;
}

#pragma mark - Event Handler -
- (void)enterUser:(FBUserInfoModel *)user {
    // 添加到等待队列
    FBVIPEnterAnimationCell *cell = [[FBVIPEnterAnimationCell alloc] initWithFrame:CGRectMake(-325, 0, 325, 30)];
    cell.user = user;
    [self.waitingQueue safe_addObject:cell];
    // 播放通道可用时，马上播放动画
    if ([self.playingQueue count] < 1) {
        [self playAnimation];
    }
}

/** 播放礼物动画 */
- (void)playAnimation {
    for (NSMutableDictionary *path in self.animationPaths) {
        // 检测可用的通道
        if ([path[kVIPAnimationPathEnable] boolValue]) {
            
            FBVIPEnterAnimationCell *cell = [self.waitingQueue firstObject];
            if (cell) {
                __weak typeof(self) wself = self;
                __weak FBVIPEnterAnimationCell *wcell = cell;
                cell.doCompleteCallback = ^ (void) {
                    // 动画播放完毕后从播放队列中移除
                    [wself.playingQueue removeObject:wcell];
                    // 重新将通道标记为可用
                    path[kVIPAnimationPathEnable] = @YES;
                    // 如果等待队列中仍有礼物，继续播放下一个动画
                    if ([wself.waitingQueue count] > 0) {
                        [wself playAnimation];
                    }
                };
                
                // 将可用通道标记为被占用
                path[kVIPAnimationPathEnable] = @NO;
                cell.dop_y = [path[kVIPAnimationPahtOriginY] floatValue];
                [self addSubview:cell];
                // 加入正在播放队列并从等待队列中移除
                [self.playingQueue addObject:cell];
                [self.waitingQueue removeObject:cell];
                
                [UIView animateWithDuration:0.5 animations:^{
                    wcell.dop_x = 0;
                } completion:^(BOOL finished) {
                    [wcell playAnimation];
                }];
            }
            break;
        }
    }
}

@end
