//
//  PullTableView.h
//  TableViewPull
//
//  Created by Emre Ergenekon on 2011-07-30.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageInterceptor.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"

@class PullTableView;
@protocol PullTableViewDelegate <NSObject>

/* After one of the delegate methods is invoked a loading animation is started, to end it use the respective status update property */
@optional
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView;
//  下拉刷新开始网络请求数据暂停交互
//  1:请求完成回调 dataSourceDidLoad
//  2:请求失败回调 dataSourceDidError
- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView;
//  上拉加载更多开始网络请求数据暂停交互
//  1:请求完成回调 dataSourceDidLoad
//  2:请求失败回调 dataSourceDidError

@end


@interface PullTableView : UITableView <EGORefreshTableHeaderDelegate, LoadMoreTableFooterDelegate>
{
    
    
    EGORefreshTableHeaderView *refreshView;
    LoadMoreTableFooterView *loadMoreView;
    
    // Since we use the contentInsets to manipulate the view we need to store the the content insets originally specified.
    UIEdgeInsets realContentInsets;
    
    // For intercepting the scrollView delegate messages.
    MessageInterceptor * delegateInterceptor;
    
    // Config
    UIImage *pullArrowImage;
    UIColor *pullBackgroundColor;
    UIColor *pullTextColor;
    UIColor *pullRefreshTextColor;
    UIColor *pullLoadMoreTextColor;
    NSDate *pullLastRefreshDate;
    
    // Status
    BOOL pullTableIsRefreshing;
    BOOL pullTableIsLoadingMore;
    
    // Delegate
    id<PullTableViewDelegate> pullDelegate;
    
}

/* The configurable display properties of PullTableView. Set to nil for default values */
@property (nonatomic, retain) UIImage *pullArrowImage;
@property (nonatomic, retain) UIColor *pullBackgroundColor;
@property (nonatomic, retain) UIColor *pullTextColor;
@property (nonatomic, retain) UIColor *pullRefreshTextColor;
@property (nonatomic, retain) UIColor *pullLoadMoreTextColor;

/* Set to nil to hide last modified text */
@property (nonatomic, retain) NSDate *pullLastRefreshDate;

/* Properties to set the status of the refresh/loadMore operations. */
/* After the delegate methods are triggered the respective properties are automatically set to YES. After a refresh/reload is done it is necessary to set the respective property to NO, otherwise the animation won't disappear. You can also set the properties manually to YES to show the animations. */
@property (nonatomic, assign) BOOL pullTableIsRefreshing;
@property (nonatomic, assign) BOOL pullTableIsLoadingMore;
@property (nonatomic, assign) BOOL hideActivity;

/* Delegate */
//@property (nonatomic, assign) IBOutlet id<PullTableViewDelegate> pullDelegate;
@property (nonatomic, assign)  id<PullTableViewDelegate> pullDelegate;
@property (nonatomic, assign) CGSize ParentVCcontentsize;


-(void)hidesLoadMoreView:(BOOL)hide;
-(void)hidesRefreshView:(BOOL)hide;

@end
