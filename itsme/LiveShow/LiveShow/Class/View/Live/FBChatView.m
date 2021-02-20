#import "FBChatView.h"
#import "FBChatCell.h"
#import "M80AttributedLabel.h"
#import "FBLevelView.h"
#import "UIImage-Helpers.h"

@interface FBChatView () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

/** 消息数据 */
@property (nonatomic, strong) NSMutableArray *data;

/** 消息列表 */
@property (nonatomic, strong) UITableView *tableView;

/** Cell的高度 */
@property (nonatomic, strong) NSMutableDictionary *cellHeights;

/** 用户手动浏览消息后，恢复自动滚动的计时器 */
@property (nonatomic, strong) NSTimer *resumeAutoScrollTimer;

@end

@implementation FBChatView

- (void)dealloc {
    self.tableView.delegate = nil;
    [self removeTimers];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoScroll = YES;
        UIView *superView = self;
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superView);
        }];
        // 每个聊天列表第一条都显示系统提示
        FBMessageModel *message = [FBMessageModel systemMessageWithContent:kLocalizationRoomWarning];
        [self receiveMessage:message];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[FBChatCell class] forCellReuseIdentifier:NSStringFromClass([FBChatCell class])];
        [_tableView debug];
    }
    return _tableView;
}

- (NSMutableDictionary *)cellHeights {
    if (!_cellHeights) {
        _cellHeights = [NSMutableDictionary dictionary];
    }
    return _cellHeights;
}

#pragma mark - Event Handler -
- (void)receiveMessage:(FBMessageModel *)model {
    [self.data addObject:model];
    [self.tableView reloadData];
    // 用户手动滚动的时候不要自动滚动到最新消息
    if (self.tableView.isTracking ||
        self.tableView.isDragging ||
        self.tableView.isDecelerating) {
        //
    } else {
        if (self.autoScroll) {
            [self scrollToBottom];
        }
    }
}

/** 滚动到消息列表的底部 */
- (void)scrollToBottom {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBChatCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBChatCell class]) forIndexPath:indexPath];
    cell.message = self.data[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FBChatCell *chatCell = (FBChatCell *)cell;
    FBMessageModel *message = self.data[indexPath.row];
    // 判断是单行还是多行文本，单行文本的宽度要自动适配
    if ([FBChatCell labelHeightForMessage:message] > [FBChatCell singleLineLabelHeightForMessage:message]) {
        [chatCell.labelContainer setFrame:CGRectMake(kLabelContainerInset.left, kLabelContainerInset.top, cell.bounds.size.width, cell.bounds.size.height-(kLabelContainerInset.top+kLabelContainerInset.bottom))];
    } else {
        [chatCell.labelContainer setFrame:CGRectMake(kLabelContainerInset.left, kLabelContainerInset.top, [FBChatCell singleLineLabelWidthForMessage:message] + 20, cell.bounds.size.height-(kLabelContainerInset.top+kLabelContainerInset.bottom))];
    }
    
    [chatCell.label setFrame:CGRectMake(kLabelInset.left, kLabelInset.top, CGRectGetWidth(chatCell.labelContainer.bounds)-(kLabelInset.left+kLabelInset.right), CGRectGetHeight(chatCell.labelContainer.bounds)-(kLabelInset.top+kLabelInset.bottom))];
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBMessageModel *message = [self.data objectAtIndex:[indexPath row]];
    return [self cellHeight:message];
}

#pragma mark - Helper -
- (CGFloat)cellHeight:(FBMessageModel *)message {
    NSString *messageID = message.messageID;
    CGFloat height = [[self.cellHeights objectForKey:messageID] floatValue];
    if (height == 0) {
        height = [FBChatCell labelHeightForMessage:message] + (kLabelContainerInset.top+kLabelContainerInset.bottom) + (kLabelInset.top+kLabelInset.bottom);
        [self.cellHeights setObject:@(height)
                             forKey:messageID];
    }
    return height;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollVie {
    self.autoScroll = NO;
    [self removeTimers];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self resumeAutoScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resumeAutoScroll];
}

- (void)resumeAutoScroll {
    [self addTimers];
}

- (void)removeTimers {
    if (self.resumeAutoScrollTimer) {
        [self.resumeAutoScrollTimer invalidate];
        self.resumeAutoScrollTimer = nil;
    }
}

- (void)addTimers {
    [self removeTimers];
    __weak typeof(self) wself = self;
    self.resumeAutoScrollTimer = [NSTimer bk_scheduledTimerWithTimeInterval:10 block:^(NSTimer *timer) {
        [wself scrollToBottom];
        wself.autoScroll = YES;
    } repeats:NO];
}

@end
