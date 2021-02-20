//
//  SCNavTabBar.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCNavTabBar.h"

@interface SCNavTabBar ()
{
    UIScrollView    *_navgationTabBar;      // all items on this scroll view
    UIImageView     *_arrowButton;          // arrow button
    
    UIView          *_line;                 // underscore show which item selected
    UIView       *_popView;              // when item menu, will show this view
    
    NSMutableArray  *_items;                // SCNavTabBar pressed item
    NSArray         *_itemsWidth;           // an array of items' width
    BOOL            _showArrowButton;       // is showed arrow button
    BOOL            _popItemMenu;           // is needed pop item menu
    
}
@property (nonatomic,assign) NSInteger lastIndex;
@end

@implementation SCNavTabBar
//ARROW_BUTTON_WIDTH 35.0f
#define MARGIN_WIDTH 28.0f

- (id)initWithFrame:(CGRect)frame showArrowButton:(BOOL)show
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _showArrowButton = show;
        [self initConfig];
    }
    return self;
}

#pragma mark -
#pragma mark - Private Methods

- (void)initConfig
{
    _items = [@[] mutableCopy];
    [self viewConfig];
}

- (void)viewConfig{
    CGFloat functionButtonX = SCREEN_WIDTH - ARROW_BUTTON_WIDTH;
    if (_showArrowButton)
    {
        _arrowButton = [[UIImageView alloc] initWithFrame:CGRectMake(functionButtonX, DOT_COORDINATE, ARROW_BUTTON_WIDTH, ARROW_BUTTON_WIDTH)];
        _arrowButton.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        _arrowButton.image = _arrowImage;
        _arrowButton.userInteractionEnabled = YES;
        [self addSubview:_arrowButton];
    }
    _navgationTabBar = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, functionButtonX, NAV_TAB_BAR_HEIGHT)];
    _navgationTabBar.showsHorizontalScrollIndicator = NO;
    _navgationTabBar.scrollsToTop=NO;
    [self addSubview:_navgationTabBar];
}

- (void)showLineWithButtonWidth:(CGFloat)width
{
    _line = [[UIView alloc] initWithFrame:CGRectMake(2.0f, NAV_TAB_BAR_HEIGHT - 3.0f, width - 4.0f, 3.0f)];
    _line.backgroundColor =self.lineColor;
    [_navgationTabBar addSubview:_line];
}

- (CGFloat)contentWidthAndAddNavTabBarItemsWithButtonsWidth:(NSArray *)widths
{
    CGFloat buttonX = DOT_COORDINATE;
    NSArray *views =  [[NSArray alloc]initWithArray:[_navgationTabBar subviews]];
    for(UIButton *view in views)
        [view removeFromSuperview];
    [_items removeAllObjects];
    for (NSInteger index = 0; index < [_itemTitles count]; index++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:self.itemColor];
        button.frame = CGRectMake(buttonX, DOT_COORDINATE, [widths[index] floatValue], NAV_TAB_BAR_HEIGHT);

        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitle:_itemTitles[index] forState:UIControlStateNormal];
        
        button.titleLabel.font = [UIFont systemFontOfSize:([[UIScreen mainScreen] isFiveFivePhone]?15:14)];
        [button addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_navgationTabBar addSubview:button];
        
        [_items addObject:button];
        buttonX += [widths[index] floatValue];
    }
    if(widths.count)
        [self showLineWithButtonWidth:[widths[0] floatValue]];
    return buttonX;
}

- (void)itemPressed:(UIButton *)button{
    UIButton *b=[_items objectAtIndex:self.lastIndex];
    [b setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    NSInteger index = [_items indexOfObject:button];
    [_delegate itemDidSelectedWithIndex:index];
    [button setTitleColor:self.selectedColor forState:UIControlStateNormal];
     self.lastIndex=index;
}
-(void)changeItemUserInteractionEnabled:(int)info
{
    for (UIButton *item in _items) {
        item.enabled=(info==1?NO:YES);
    }
}

- (NSArray *)getButtonsWidthWithTitles:(NSArray *)titles;
{
    NSMutableArray *widths = [@[] mutableCopy];
    
    for (NSString *title in titles)
    {
        CGSize size = [title sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0] }];
        NSNumber *width = [NSNumber numberWithFloat:size.width + MARGIN_WIDTH];
        [widths addObject:width];
    }
    
    return widths;
}

- (void)viewShowShadow:(UIView *)view shadowRadius:(CGFloat)shadowRadius shadowOpacity:(CGFloat)shadowOpacity
{
    view.layer.shadowRadius = shadowRadius;
    view.layer.shadowOpacity = shadowOpacity;
}

#pragma mark -
#pragma mark - Public Methods
- (void)setArrowImage:(UIImage *)arrowImage
{
    _arrowImage = arrowImage ? arrowImage : _arrowImage;
    _arrowButton.image = _arrowImage;
}

- (void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    _currentItemIndex = currentItemIndex;
    UIButton *button = _items[currentItemIndex];
    CGFloat flag = _showArrowButton ? (SCREEN_WIDTH - ARROW_BUTTON_WIDTH) : SCREEN_WIDTH;
    
    if (button.frame.origin.x + button.frame.size.width > flag/2+20 && _navgationTabBar.contentSize.width > _navgationTabBar.frame.size.width)
    {
        if(_navgationTabBar.contentSize.width-button.frame.origin.x - button.frame.size.width<=(flag-40)/2)
        {
            [_navgationTabBar setContentOffset:CGPointMake(_navgationTabBar.contentSize.width-flag+40, DOT_COORDINATE) animated:YES];
        }
        else
        {
            CGFloat offsetX = button.frame.origin.x + button.frame.size.width - flag+40;
            [_navgationTabBar setContentOffset:CGPointMake(offsetX+(flag-120)/2, DOT_COORDINATE) animated:YES];
        }
    }
    else
    {
        [_navgationTabBar setContentOffset:CGPointMake(DOT_COORDINATE, DOT_COORDINATE) animated:YES];
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        _line.frame = CGRectMake(button.frame.origin.x + 2.0f, _line.frame.origin.y, [_itemsWidth[currentItemIndex] floatValue] - 4.0f, _line.frame.size.height);
    }];
}

- (void)updateData
{
    self.lastIndex=0;
    _arrowButton.backgroundColor = self.backgroundColor;
    _itemsWidth = [self getButtonsWidthWithTitles:_itemTitles];
    //if (_itemsWidth.count)
    {
        CGFloat contentWidth = [self contentWidthAndAddNavTabBarItemsWithButtonsWidth:_itemsWidth];
        _navgationTabBar.contentSize = CGSizeMake(contentWidth, DOT_COORDINATE);
    }
}

- (void)updateData:(NSMutableArray *)title{
//    self.lastIndex=0;
    _itemsWidth = [self getButtonsWidthWithTitles:title];
    if (_itemsWidth.count)
    {
        CGFloat contentWidth = [self contentWidthAndAddNavTabBarItemsWithButtonsWidth:_itemsWidth];
        _navgationTabBar.contentSize = CGSizeMake(contentWidth, DOT_COORDINATE);
    }
}

#pragma mark - SCFunctionView Delegate Methods
- (void)itemPressedWithIndex:(NSInteger)index
{
    if (index < [_items count]) {
        UIButton *b=[_items objectAtIndex:index];
        [self itemPressed:b];
    }
}

@end

