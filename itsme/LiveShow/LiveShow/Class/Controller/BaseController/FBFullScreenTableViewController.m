#import "FBFullScreenTableViewController.h"

@interface FBFullScreenTableViewController ()

@property (nonatomic) NJKScrollFullScreen *scrollProxy;

@end

@implementation FBFullScreenTableViewController

- (void)dealloc
{
    // If tableView is scrolling as this VC is being dealloc'd
    // it continues to send messages (scrollViewDidScroll:) to its delegate.
    // This is fine if the delegate will outlive tableView (e.g. this VC would.)
    // However, if the delegate is an instance that may be dealloc'd
    // before the tableView
    // (i.e. _scrollProxy may be dealloc'd prior to tableView being dealloc'd)
    // the tableView will send messages to its delegate,
    // which is defined with an "assign" (i.e. unsafe_unretained) property.
    // This is a msgSend to non-nil'ed, invalid memory leading to a crash.
    // If or when UIScrollView's delegate is referred to with "weak" rather
    // than "assign", this can and should be removed.
    self.tableView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configScrollFullScreen];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_scrollProxy reset];
    [self showNavigationBar:animated];
    [self showTabBar:animated];
}

- (void)configScrollFullScreen {
    _scrollProxy = [[NJKScrollFullScreen alloc] initWithForwardTarget:self];
    self.tableView.delegate = (id)_scrollProxy;
    _scrollProxy.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetBars) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)resetBars {
    [_scrollProxy reset];
    [self showNavigationBar:NO];
    [self showTabBar:NO];
}

#pragma mark - NJKScrollFullScreenDelegate -
- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollUp:(CGFloat)deltaY {
    if (![self isContentHeightTooShortToLayoutUIBars]) {
        [self moveNavigationBar:deltaY animated:YES];
        [self moveTabBar:-deltaY animated:YES];
    }
}

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollDown:(CGFloat)deltaY {
    if (![self isContentHeightTooShortToLayoutUIBars]) {
        [self moveNavigationBar:deltaY animated:YES];
        [self moveTabBar:-deltaY animated:YES];
    }
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp:(NJKScrollFullScreen *)proxy {
    if (![self isContentHeightTooShortToLayoutUIBars]) {
        [self hideNavigationBar:YES];
        [self hideTabBar:YES];
    }
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown:(NJKScrollFullScreen *)proxy {
    if (![self isContentHeightTooShortToLayoutUIBars]) {
        [self showNavigationBar:YES];
        [self showTabBar:YES];
    }
}

#pragma mark - Helper -
- (BOOL)isContentHeightTooShortToLayoutUIBars {
    BOOL isContentHeightTooShortToLayoutUIBars = (self.tableView.contentSize.height+self.tableView.contentInset.bottom < self.tableView.frame.size.height);
    return isContentHeightTooShortToLayoutUIBars;
}

@end
