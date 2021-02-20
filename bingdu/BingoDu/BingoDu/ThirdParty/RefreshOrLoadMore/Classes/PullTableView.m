//
//  PullTableView.m
//  TableViewPull
//
//  Created by Emre Ergenekon on 2011-07-30.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "PullTableView.h"

@interface PullTableView (Private) <UIScrollViewDelegate>
- (void) config;
- (void) configDisplayProperties;
@end

@implementation PullTableView

# pragma mark - Initialization / Deallocation

@synthesize pullDelegate;
@synthesize hideActivity = _hideActivity;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self config];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self config];
}


- (void)dealloc {
    [pullArrowImage release];
    [pullBackgroundColor release];
    [pullTextColor release];
    [pullRefreshTextColor release];
    [pullLoadMoreTextColor release];
    [pullLastRefreshDate release];
    
    [refreshView release];
    [loadMoreView release];
    [delegateInterceptor release];
    [super dealloc];
}

# pragma mark - Custom view configuration

- (void) config
{
    /* Message interceptor to intercept scrollView delegate messages */
    delegateInterceptor = [[MessageInterceptor alloc] init];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = self.delegate;
    super.delegate = (id)delegateInterceptor;
    
    /* Status Properties */
    pullTableIsRefreshing = NO;
    pullTableIsLoadingMore = NO;
    
    /* Refresh View */
    refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    refreshView.delegate = self;
    refreshView.hideActivity = self.hideActivity;
    [self addSubview:refreshView];
    
    /* Load more view init */
    loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    loadMoreView.delegate = self;
    [self addSubview:loadMoreView];
}


# pragma mark - View changes

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
    
    CGRect loadMoreFrame = loadMoreView.frame;
    loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
    loadMoreView.frame = loadMoreFrame;
    
}

#pragma mark - Preserving the original behaviour

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if(delegateInterceptor && delegate) {
        super.delegate = nil;
        delegateInterceptor.receiver = delegate;
        super.delegate = (id)delegateInterceptor;
    } else {
        super.delegate = delegate;
    }
}

- (void)reloadData
{
    [super reloadData];
    // Give the footers a chance to fix it self.
    [loadMoreView egoRefreshScrollViewDidScroll:self];
}

#pragma mark - Status Propreties

@synthesize pullTableIsRefreshing;
@synthesize pullTableIsLoadingMore;

- (void)setPullTableIsRefreshing:(BOOL)isRefreshing
{
    if(!pullTableIsRefreshing && isRefreshing) {
        // If not allready refreshing start refreshing
        [refreshView startAnimatingWithScrollView:self];
        pullTableIsRefreshing = YES;
    } else if(pullTableIsRefreshing && !isRefreshing) {
        [refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        pullTableIsRefreshing = NO;
    }
}

- (void)setPullTableIsLoadingMore:(BOOL)isLoadingMore
{
    if(!pullTableIsLoadingMore && isLoadingMore) {
        // If not allready loading more start refreshing
        [loadMoreView startAnimatingWithScrollView:self];
        pullTableIsLoadingMore = YES;
    } else if(pullTableIsLoadingMore && !isLoadingMore) {
        [loadMoreView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        pullTableIsLoadingMore = NO;
    }
}

- (void)setHideActivity:(BOOL)hideActivity {
    _hideActivity = hideActivity;
    refreshView.hideActivity = _hideActivity;
}

#pragma mark - Display properties

@synthesize pullArrowImage;
@synthesize pullBackgroundColor;
@synthesize pullTextColor;
@synthesize pullRefreshTextColor;
@synthesize pullLoadMoreTextColor;
@synthesize pullLastRefreshDate;

- (void)configDisplayProperties
{
    if (self.pullRefreshTextColor) {
        [refreshView setBackgroundColor:self.pullBackgroundColor textColor:self.pullRefreshTextColor arrowImage:self.pullArrowImage];
    } else {
        [refreshView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
    }
    
    if (self.pullLoadMoreTextColor) {
        [loadMoreView setBackgroundColor:self.pullBackgroundColor textColor:self.pullLoadMoreTextColor arrowImage:self.pullArrowImage];
    } else {
        [loadMoreView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
    }
}

- (void)setPullArrowImage:(UIImage *)aPullArrowImage
{
    if(aPullArrowImage != pullArrowImage) {
        [pullArrowImage release];
        pullArrowImage = [aPullArrowImage retain];
        [self configDisplayProperties];
    }
}

- (void)setPullBackgroundColor:(UIColor *)aColor
{
    if(aColor != pullBackgroundColor) {
        [pullBackgroundColor release];
        pullBackgroundColor = [aColor retain];
        [self configDisplayProperties];
    } 
}

- (void)setPullTextColor:(UIColor *)aColor
{
    if(aColor != pullTextColor) {
        [pullTextColor release];
        pullTextColor = [aColor retain];
        [self configDisplayProperties];
    } 
}

- (void)setPullRefreshTextColor:(UIColor *)aColor
{
    if(aColor != pullRefreshTextColor) {
        [pullRefreshTextColor release];
        pullRefreshTextColor = [aColor retain];
        [self configDisplayProperties];
    }
}

- (void)setPullLoadMoreTextColor:(UIColor *)aColor
{
    if(aColor != pullLoadMoreTextColor) {
        [pullLoadMoreTextColor release];
        pullLoadMoreTextColor = [aColor retain];
        [self configDisplayProperties];
    }
}

- (void)setPullLastRefreshDate:(NSDate *)aDate
{
    if(aDate != pullLastRefreshDate) {
        [pullLastRefreshDate release];
        pullLastRefreshDate = [aDate retain];
        [refreshView refreshLastUpdatedDate];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [refreshView egoRefreshScrollViewDidScroll:scrollView];
    if (!loadMoreView.hidden)
    {
       [loadMoreView egoRefreshScrollViewDidScroll:scrollView];
    }
   
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (!refreshView.hidden)
        [refreshView egoRefreshScrollViewDidEndDragging:scrollView];
    if (!loadMoreView.hidden)
        [loadMoreView egoRefreshScrollViewDidEndDragging:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [delegateInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if ([[[self nextResponder] nextResponder] isMemberOfClass:[UIScrollView class]]) {
        UIScrollView *sv = (UIScrollView *)[[self nextResponder] nextResponder];
//        UIViewController *infoview = (UIViewController *)[self nextResponder];
//        sv.contentSize = self.ParentVCcontentsize;
//        sv.contentOffset = CGPointMake(infoview.view.tag * SCREEN_WIDTH, 0);
        sv.scrollEnabled = YES;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    if ([[[self nextResponder] nextResponder] isMemberOfClass:[UIScrollView class]]) {
        UIScrollView *sv = (UIScrollView *)[[self nextResponder] nextResponder];
        //        UIViewController *infoview = (UIViewController *)[self nextResponder];
        //        sv.contentSize = self.ParentVCcontentsize;
        //        sv.contentOffset = CGPointMake(infoview.view.tag * SCREEN_WIDTH, 0);
        sv.scrollEnabled = YES;
    }
}
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [refreshView egoRefreshScrollViewWillBeginDragging:scrollView];
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [delegateInterceptor.receiver scrollViewWillBeginDragging:scrollView];
    }
    
    
    
    if ([[[self nextResponder] nextResponder] isMemberOfClass:[UIScrollView class]]) {
        UIScrollView *sv = (UIScrollView *)[[self nextResponder] nextResponder];
//        UIViewController *infoview = (UIViewController *)[self nextResponder];
        sv.scrollEnabled = NO;
//        self.ParentVCcontentsize = sv.contentSize;
//        sv.contentSize = CGSizeMake(SCREEN_WIDTH, 0);
//        sv.directionalLockEnabled = YES;
//        sv.alwaysBounceVertical = YES;
//        sv.contentOffset = CGPointMake(infoview.view.tag * SCREEN_WIDTH, 0);
    }
}



#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    pullTableIsRefreshing = YES;
    [pullDelegate pullTableViewDidTriggerRefresh:self];    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return self.pullLastRefreshDate;
}

#pragma mark - LoadMoreTableViewDelegate

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view
{

    pullTableIsLoadingMore = YES;
    [pullDelegate pullTableViewDidTriggerLoadMore:self];
}
#pragma mark -show or hide loadmoreview
-(void)hidesLoadMoreView:(BOOL)hide
{
    loadMoreView.hidden = hide;
}

-(void)hidesRefreshView:(BOOL)hide
{
    refreshView.hidden = hide;
}

@end
