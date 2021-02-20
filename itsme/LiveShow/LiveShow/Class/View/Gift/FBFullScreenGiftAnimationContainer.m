#import "FBFullScreenGiftAnimationContainer.h"
#import "FBGiftAnimationHelper.h"

@interface FBFullScreenGiftAnimationContainer ()

/** 等待播放的礼物队列 */
@property (nonatomic, strong) NSMutableArray *giftWaitingQueue;

/** 正在播放的礼物队列 */
@property (nonatomic, strong) NSMutableArray *giftPlayingQueue;

@end

@implementation FBFullScreenGiftAnimationContainer

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

- (void)receiveGift:(FBGiftModel *)gift {
    [self.giftWaitingQueue safe_addObject:gift];
    // 播放通道可用时，马上播放礼物动画
    if (0 == [self.giftPlayingQueue count]) {
        [self playAnimation];
    }
}

/** 播放礼物动画 */
- (void)playAnimation {
    FBGiftModel *gift = [self.giftWaitingQueue firstObject];
    // 播放动画
    NSString *bagName = gift.imageZip;
    if ([bagName isValid]) {
        if ([FBGiftAnimationHelper existsZipWithGift:gift]) {
            NSArray *imageFiles = [FBGiftAnimationHelper animationImagesWithGift:gift];
            FBGiftAnimationInfoModel *info = [FBGiftAnimationHelper animationInfoWithGift:gift];
            // 添加全屏礼物动画控件
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH);
            [self addSubview:imageView];
            __weak UIImageView *weakImageView = imageView;
            __weak typeof(self) wself = self;
            // 主播收到的钻石数在本地增加的业务逻辑
            // 动画播放完，执行回调动作，如左上角钻石数增加
            if (self.doFinishAnimationCallback) {
                self.doFinishAnimationCallback(gift);
            }
            // 开始动画
            [imageView fb_startAnimatingWithImageFiles:imageFiles
                                              duration:[info.time doubleValue]/1000
                                           repeatCount:1
                                             completed:^{
                                                 weakImageView.image = nil;
                                                 [weakImageView removeFromSuperview];
                                                 // 动画播放完毕播放队列中移除
                                                 [wself.giftPlayingQueue safe_removeObject:gift];
                                                 // 如果等待队列中仍有礼物，继续播放下一个动画
                                                 if ([wself.giftWaitingQueue count] > 0) {
                                                     [wself playAnimation];
                                                 }
                                             }];
            
            // 加入正在播放队列并从等待队列中移除
            [self.giftPlayingQueue safe_addObject:gift];
            [self.giftWaitingQueue safe_removeObject:gift];
        }
        
//        [FBGiftAnimationHelper downloadZipFileForGift:gift
//                                    completionHandler:^(NSArray *imageFiles, NSInteger animationType, NSTimeInterval duration) {
//                                        UIImageView *imageView = [[UIImageView alloc] init];
//                                        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH);
//                                        [self addSubview:imageView];
//                                        __weak UIImageView *weakImageView = imageView;
//                                        __weak typeof(self) wself = self;
//                                        [imageView fb_startAnimatingWithImageFiles:imageFiles
//                                                                          duration:duration
//                                                                       repeatCount:1
//                                                                         completed:^{
//                                                                             weakImageView.image = nil;
//                                                                             [weakImageView removeFromSuperview];
//                                                                             // 动画播放完毕播放队列中移除
//                                                                             [wself.giftPlayingQueue safe_removeObject:gift];
//                                                                             // 如果等待队列中仍有礼物，继续播放下一个动画
//                                                                             if ([wself.giftWaitingQueue count] > 0) {
//                                                                                 [wself playAnimation];
//                                                                             }
//                                                                         }];
//                                        
//                                        // 加入正在播放队列并从等待队列中移除
//                                        [self.giftPlayingQueue safe_addObject:gift];
//                                        [self.giftWaitingQueue safe_removeObject:gift];
//                                    }];
// 旧的业务逻辑
//        [FBGiftAnimationHelper downloadZipFileForGift:gift
//                                    completionHandler:^(NSArray *imageFiles, NSInteger animationType, NSTimeInterval duration) {
//                                        UIImageView *imageView = [[UIImageView alloc] init];
//                                        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH);
//                                        [self addSubview:imageView];
//                                        __weak UIImageView *weakImageView = imageView;
//                                        __weak typeof(self) wself = self;
//                                        [imageView fb_startAnimatingWithImageFiles:imageFiles
//                                                                          duration:duration
//                                                                       repeatCount:1
//                                                                         completed:^{
//                                                                             weakImageView.image = nil;
//                                                                             [weakImageView removeFromSuperview];
//                                                                             // 动画播放完毕播放队列中移除
//                                                                             [wself.giftPlayingQueue safe_removeObject:gift];
//                                                                             // 如果等待队列中仍有礼物，继续播放下一个动画
//                                                                             if ([wself.giftWaitingQueue count] > 0) {
//                                                                                 [wself playAnimation];
//                                                                             }
//                                                                         }];
//                                        
//                                        // 加入正在播放队列并从等待队列中移除
//                                        [self.giftPlayingQueue safe_addObject:gift];
//                                        [self.giftWaitingQueue safe_removeObject:gift];
//                                    }];
    }
}

@end
