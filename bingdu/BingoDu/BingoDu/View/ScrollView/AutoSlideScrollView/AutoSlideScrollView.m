//
//  AutoSlideScrollView.m
//  AutoSlideScrollViewDemo
//
//  Created by Mike Chen on 14-1-23.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import "AutoSlideScrollView.h"
#import "UIImageView+WebCache.h"
#import "ZWLoopADCell.h"

@interface AutoSlideScrollView () <UIScrollViewDelegate>
{
    CGFloat scrollViewStartContentOffsetX;
}
@property (nonatomic , assign) NSInteger currentPageIndex;
@property (nonatomic , assign) NSInteger totalPageCount;
@property (nonatomic , strong) NSMutableArray *contentViews;
@property (nonatomic , strong) UIScrollView *scrollView;

@end

@implementation AutoSlideScrollView

- (void)setTotalPagesCount:(NSInteger (^)(void))totalPagesCount
{
    self.totalPageCount = totalPagesCount();
    if (self.totalPageCount > 0) {
        if (self.totalPageCount > 1) {
            self.scrollView.scrollEnabled = YES;
            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
            self.currentPageIndex = self.totalPageCount/2;
        } else {
            self.scrollView.scrollEnabled = NO;
        }
        [self configContentViews];
    }
}

- (void)setFetchContentViewAtIndex:(UIView *(^)(NSInteger index))fetchContentViewAtIndex
{
    _fetchContentViewAtIndex = fetchContentViewAtIndex;
    //加入第一页
    [self configContentViews];
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
}

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    self = [self initWithFrame:frame];
    if (animationDuration > 0.0) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.autoresizesSubviews = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.clipsToBounds = NO;
        self.currentPageIndex = 0;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.clipsToBounds = NO;
        [self addSubview:self.scrollView];
        self.currentPageIndex = 0;
    }
    return self;
}

#pragma mark -
#pragma mark - 私有函数

- (void)configContentViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
        contentView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
    }
    if (self.totalPageCount > 1) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger ppreviousPageIndex = [self getValidNextPageIndexWithPageIndex:previousPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    NSInteger rrearPageIndex = [self getValidNextPageIndexWithPageIndex:rearPageIndex + 1];
    
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }
    
    [self.contentViews removeAllObjects];
    
    if (self.fetchContentViewAtIndex) {
        id set = (self.totalPageCount == 1)?[NSSet setWithObjects:@(previousPageIndex),@(_currentPageIndex),@(rearPageIndex), nil]:@[@(previousPageIndex),@(_currentPageIndex),@(rearPageIndex)];
        
        {
            UIView *previousView = self.fetchContentViewAtIndex(previousPageIndex);
            ZWLoopADView *ppreviousView = (ZWLoopADView *)self.fetchContentViewAtIndex(ppreviousPageIndex);
            
            for (UIView *view in previousView.subviews) {
                if ([view isKindOfClass:[ZWLoopADView class]]) {
                    [view removeFromSuperview];
                }
            }
            
            ZWLoopADView *view = [[ZWLoopADView alloc] initWithFrame:CGRectMake(-ppreviousView.frame.size.width, 0, ppreviousView.frame.size.width, 95)];
            view.label.text = [NSString stringWithFormat:@"%ld", (long)ppreviousPageIndex+1];
            view.imageView.image = ppreviousView.imageView.image;
            [previousView addSubview:view];
        }
        
        {
            UIView *rearView = self.fetchContentViewAtIndex(rearPageIndex);
            ZWLoopADView *rrearView = (ZWLoopADView *)self.fetchContentViewAtIndex(rrearPageIndex);
            
            for (UIView *view in rearView.subviews) {
                if ([view isKindOfClass:[ZWLoopADView class]]) {
                    [view removeFromSuperview];
                }
            }
            
            ZWLoopADView *view = [[ZWLoopADView alloc] initWithFrame:CGRectMake(rrearView.frame.size.width, 0, rrearView.frame.size.width, rrearView.frame.size.height)];
            view.imageView.image = rrearView.imageView.image;
             view.label.text = [NSString stringWithFormat:@"%ld", (long)rrearPageIndex+1];
            [rearView addSubview:view];
        }
        
        for (NSNumber *tempNumber in set) {
            NSInteger tempIndex = [tempNumber integerValue];
            if ([self isValidArrayIndex:tempIndex]) {
                [self.contentViews addObject:self.fetchContentViewAtIndex(tempIndex)];
            }
        }
    }
}

- (BOOL)isValidArrayIndex:(NSInteger)index
{
    if (index >= 0 && index <= self.totalPageCount - 1) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalPageCount/2;
    } else if (currentPageIndex == self.totalPageCount) {
        return self.totalPageCount/2;;
    } else {
        return currentPageIndex;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollViewStartContentOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    if (self.totalPageCount == 2) {
        if (scrollViewStartContentOffsetX < contentOffsetX) {
            UIView *tempView = (UIView *)[self.contentViews lastObject];
            tempView.frame = (CGRect){{2 * CGRectGetWidth(scrollView.frame),0},tempView.frame.size};
        } else if (scrollViewStartContentOffsetX > contentOffsetX) {
            UIView *tempView = (UIView *)[self.contentViews firstObject];
            tempView.frame = (CGRect){{0,0},tempView.frame.size};
        }
    }
    
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
        //        NSLog(@"next，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
    if(contentOffsetX <= 0) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
        //        NSLog(@"previous，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
    if (self.TapActionBlock) {
        self.TapActionBlock(self.currentPageIndex);
    }
}

@end
