#import "FBBroadcastInfoContainerView.h"
#import "FBBroadcastInfoView.h"
#import "FBSlideScrollView.h"

@interface FBBroadcastInfoContainerView ()

@property (nonatomic, strong) FBSlideScrollView *slideView;

/** 直播类型 */
@property (nonatomic, assign) FBLiveType type;

@end

@implementation FBBroadcastInfoContainerView

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame type:(FBLiveType)type {
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        
        [self addSubview:self.slideView];
        __weak typeof(self) wself = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationRoomScrollEnabled
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          wself.slideView.scrollView.scrollEnabled = [note.object boolValue];
                                                      }];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (FBBroadcastInfoView *)contentView {
    if (!_contentView) {
        _contentView = [[FBBroadcastInfoView alloc] initWithFrame:self.bounds liveType:self.type];
    }
    return _contentView;
}

- (FBSlideScrollView *)slideView {
    
    if (!_slideView) {
        
        NSMutableArray *viewsArray = [NSMutableArray array];
        
        [viewsArray addObject:self.contentView];
        
        // 空白层，信息层滑出界面时显示的是空白层
        UIView *clearView = [[UIView alloc] initWithFrame:self.bounds];
        clearView.backgroundColor = [UIColor clearColor];
        [viewsArray addObject:clearView];
        
        _slideView = [[FBSlideScrollView alloc] initWithFrame:self.bounds];
        _slideView.backgroundColor = [UIColor clearColor];
        _slideView.totalPagesCount = ^NSInteger(void){
            return viewsArray.count;
        };
        _slideView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            return viewsArray[pageIndex];
        };
        
        __weak typeof(_slideView) wSlideView = _slideView;
        [clearView bk_whenTapped:^{
            if (wSlideView.latestSlideDirection == kSlideDirectionLeft) {
                [wSlideView.scrollView setContentOffset:CGPointZero animated:YES];
            } else {
                [wSlideView.scrollView setContentOffset:CGPointMake(2 * CGRectGetWidth(wSlideView.bounds), 0) animated:YES];
            }
        }];
    }
    return _slideView;
}

@end
