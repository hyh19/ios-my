#import "FBDisguiseView.h"
#import "FBFastStatementView.h"
#import "FBServerSettingsModel.h"

#define kPointY 50

@interface FBDisguiseView () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) FBFastStatementView *statementList;

@property (nonatomic , assign) NSInteger row;

@property (strong, nonatomic) NSString *identityCategory;

@end

@implementation FBDisguiseView

#pragma mark - init -
- (instancetype)initWithFrame:(CGRect)frame andIdentityCategory:(NSString *)identityCategory {
    if (self = [super initWithFrame:frame]) {
        self.identityCategory = identityCategory;
        [self addSubview:self.statementList];
        [self configureonLongPressedHandle];
        [self configureonTapPressedHandle];
    }
    return self;
}

- (FBFastStatementView *)statementList {
    if (!_statementList) {
        _statementList = [[FBFastStatementView alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGH - kPointY, 0, 0) andIdentityCategory:self.identityCategory];
        _statementList.layer.cornerRadius = 5;
        _statementList.clipsToBounds = YES;
        _statementList.alpha = 0.0;
    }
    return _statementList;
}

/** 长按手势 */
- (void)configureonLongPressedHandle {
    
    //创建长按手势监听
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(onLongPressedHandleState:)];
    
    //手势代理
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.5;
    //将长按手势添加到需要实现长按操作的视图里
    [self addGestureRecognizer:longPress];

}

- (void)configureonTapPressedHandle {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(onTapPressedHandleState:)];
    
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)onLongPressedHandleState:(UILongPressGestureRecognizer *)gestureRecognizer  {
    // 手势的位置
    CGPoint location = [gestureRecognizer locationInView:self];
    // 发言列表的数量
    NSUInteger countH = self.statementList.statementArray.count;
    // 手势的Y轴位置
    CGFloat pointY = (SCREEN_HEIGH - kPointY - 40*countH - location.y);
    
    NSIndexPath *indexPath = nil;
    
    CGFloat offsetX = self.statementList.x - self.frame.size.width / 3;
    CGFloat offsetY = self.statementList.y + self.frame.size.width / 5;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH);
        self.statementList.frame = CGRectMake(10, SCREEN_HEIGH-kPointY-40*countH , 160, 40*countH);
        
        if (self.statementList.alpha == 0.0f) {
            // 动画由小变大
            self.statementList.transform = CGAffineTransformMake(0.01, 0, 0, 0.01, offsetX, offsetY);
            
            [UIView animateWithDuration:0.3f animations:^{
                self.statementList.alpha = 1.0f;
                self.statementList.transform = CGAffineTransformMake(1.0f, 0, 0, 1.0f, 0, 0);
                
            } completion:^(BOOL finished) {
                //
            }];
        }

    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        if (location.x > 10 &&
            location.x < 160 &&
            location.y > (SCREEN_HEIGH - kPointY - 40*countH) &&
            location.y < (SCREEN_HEIGH - kPointY)) {
            
            self.row = (NSInteger)fabs(pointY)/40;
            indexPath = [NSIndexPath indexPathForRow:self.row inSection:0];
            
            [self.statementList.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        } else {
            indexPath = [NSIndexPath indexPathForRow:self.row inSection:0];
            
            [self.statementList.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        
        if (location.x > 10 &&
            location.x < 160 &&
            location.y > (SCREEN_HEIGH - kPointY - 40*countH) &&
            location.y < (SCREEN_HEIGH - kPointY)) {
            
            self.row = (NSInteger)fabs(pointY)/40;
            indexPath = [NSIndexPath indexPathForRow:self.row inSection:0];
            
            FBPresetDialogModel *model = self.statementList.statementArray[indexPath.row];
            
            if (self.doFastStatementAction) {
                self.doFastStatementAction(model.dialog);
            }
        }
        
        if (indexPath) {
            [self.statementList.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        // 动画由大变小
        self.statementList.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        [UIView animateWithDuration:0.2 animations:^{
            self.statementList.transform = CGAffineTransformMake(0.01, 0, 0, 0.01, offsetX, offsetY);
        } completion:^(BOOL finished) {
            self.statementList.transform = CGAffineTransformIdentity;
            self.statementList.alpha = 0.0f;
            self.frame = CGRectMake(10, SCREEN_HEIGH - 45, SCREEN_WIDTH - 116, 35);
        }];

    }
}

- (void)onTapPressedHandleState:(UILongPressGestureRecognizer *)gestureRecognizer  {
    if (self.doOpenChatKeyboardAction) {
        self.doOpenChatKeyboardAction();
    }
}

@end
