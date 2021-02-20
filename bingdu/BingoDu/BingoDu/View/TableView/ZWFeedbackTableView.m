#import "ZWFeedbackTableView.h"
#import "ZWMessageModel.h"
#import "ZWMessageCell.h"

@implementation ZWFeedbackTableView
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate=self;
        
        self.dataSource=self;
        
        _pullTableIsLoadingMore=NO;
        
        _allMessagesFrame = [[NSMutableArray alloc] initWithObjects:[self systemMessage], nil];
    
        [self addSubview:[self loadMoreView]];
        
        self.feedback = [UMFeedback sharedInstance];
        
        self.feedback.delegate = self;
    }
    return self;
}

- (void)setAllMessagesFrame:(NSMutableArray *)allMessagesFrame
{
    if(_allMessagesFrame != allMessagesFrame)
    {
        _allMessagesFrame = allMessagesFrame;
        
        [self reloadData];

        if(self.contentSize.height > self.frame.size.height)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.contentOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
            }];
        }
    }
}

- (LoadMoreTableFooterView *)loadMoreView
{
    if(!_loadMoreView)
    {
        _loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
        
        _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        _loadMoreView.delegate = self;
    }
    return _loadMoreView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
    
    CGRect loadMoreFrame = [self loadMoreView].frame;
    
    loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
    
    [self loadMoreView].frame = loadMoreFrame;
}
- (void)setPullTableIsLoadingMore:(BOOL)isLoadingMore
{
    if(!_pullTableIsLoadingMore && isLoadingMore) {
        
        [[self loadMoreView] startAnimatingWithScrollView:self];
        _pullTableIsLoadingMore = YES;
        
    } else if(_pullTableIsLoadingMore && !isLoadingMore) {
        
        [[self loadMoreView] egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        _pullTableIsLoadingMore = NO;
    }
}

#pragma mark - LoadMoreTableViewDelegate

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view
{
    _pullTableIsLoadingMore = YES;
    [self.feedback get];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[self loadMoreView] egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [[self loadMoreView] egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allMessagesFrame.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    ZWMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ZWMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 设置数据
    cell.messageFrame = _allMessagesFrame[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [_allMessagesFrame[indexPath.row] cellHeight];
}

#pragma mark - UMFeedback Delegate

- (void)updateLoadMoreState
{
    [self setPullTableIsLoadingMore:NO];
}

- (void)getFinishedWithError:(NSError *)error {
    
    [self performSelector:@selector(updateLoadMoreState) withObject:nil afterDelay:0.5];
    
    if (error != nil) {
        ZWLog(@"%@", error);
    } else {
        NSString *previousTime = nil;
        
          NSMutableArray *messagesFrame = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (NSDictionary *dict in self.feedback.topicAndReplies) {
            
            ZWMessageFrame *messageFrame = [[ZWMessageFrame alloc] init];
            
            ZWMessageModel *message = [[ZWMessageModel alloc] init];
            message.dict = dict;
            
            messageFrame.showTime = ![previousTime isEqualToString:message.time];
            
            messageFrame.message = message;
            
            previousTime = message.time;
            
            [messagesFrame safe_addObject:messageFrame];
        }
        if(messagesFrame.count > 0)
        {
            [messagesFrame insertObject:[self systemMessage] atIndex:0];
        }
        else
        {
            [messagesFrame safe_addObject:[self systemMessage]];
        }
        [self setAllMessagesFrame:messagesFrame];
    }
    
    [[UMFeedback sharedInstance] updateUserInfo:@{@"contact": @{@"plain": [[ZWUserInfoModel sharedInstance] nickName] ? [[ZWUserInfoModel sharedInstance] nickName] : @""}}];
}

- (void)postFinishedWithError:(NSError *)error {
    if (error != nil) {
        ZWLog(@"%@", error);
    } else {
        
        NSMutableArray *messagesFrame = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSString *previousTime = nil;
        
        for (NSDictionary *dict in self.feedback.topicAndReplies) {
            
            ZWMessageFrame *messageFrame = [[ZWMessageFrame alloc] init];
            
            ZWMessageModel *message = [[ZWMessageModel alloc] init];
            message.dict = dict;
            
            messageFrame.showTime = ![previousTime isEqualToString:message.time];
            
            messageFrame.message = message;
            
            previousTime = message.time;
            
            [messagesFrame safe_addObject:messageFrame];
        }
        if(messagesFrame.count > 0)
        {
            [messagesFrame insertObject:[self systemMessage] atIndex:0];
        }
        else
        {
            [messagesFrame safe_addObject:[self systemMessage]];
        }
        [self setAllMessagesFrame:messagesFrame];
    }
}

- (ZWMessageFrame *)systemMessage
{
    ZWMessageFrame *messageFrame = [[ZWMessageFrame alloc] init];
    
    ZWMessageModel *message = [[ZWMessageModel alloc] init];
    
    message.dict = @{
                     @"age_group": @"",
                     @"content" : @"您好！我是并读的产品经理，欢迎您给我们反馈产品的使用感受和建议。如有紧急情况，请联系客服QQ：800104100。",
                     @"created_at" : @"",
                     @"gender" : @"female",
                     @"is_failed" : @"0",
                     @"reply_id" : @"CD2BB496A-71D6-450C-8AE3-17C87B8D4591",
                     @"type" : @"dev_reply"
                     };
    
    messageFrame.showTime = NO;
    
    messageFrame.message = message;
    
    return messageFrame;
}

@end
