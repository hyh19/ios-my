#import "ZWChannelDataSource.h"

#define ITEM_COLOR [UIColor whiteColor]

@implementation ZWChannelDataSource

#pragma mark GMGridViewDataSource     //创建元素

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.dataSource count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(SCREEN_WIDTH * 0.29, 34);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //创建元素
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonOffset = CGPointMake(SCREEN_WIDTH * 0.29 - 80, -5);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = ITEM_COLOR;
        if(index == 0)
            view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.];
        view.layer.masksToBounds = NO;
        view.tag = index;
        view.layer.cornerRadius = 3;
        view.layer.borderColor = [UIColor colorWithHexString:@"d5d5d5"].CGColor;
        view.layer.borderWidth = 0.3;
        
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //元素字面值
    UILabel *itemlabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    itemlabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    itemlabel.text = (NSString *)[self.dataSource objectAtIndex:index];
    itemlabel.textAlignment = NSTextAlignmentCenter;
    itemlabel.backgroundColor = [UIColor clearColor];
    if(index == 0)
    {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.];
    }
    else
    {
        cell.contentView.backgroundColor = ITEM_COLOR;
    }
    itemlabel.textColor = COLOR_333333;
    itemlabel.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:itemlabel];
    
    return cell;
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    if(index == 0)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if([self.delegate respondsToSelector:@selector(dataSource:didTapOnItemTitle:)])
    {
        [self.delegate dataSource:self didTapOnItemTitle:self.dataSource[position]];
    }
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView{
}

//处理删除行为
- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index{
    [self.dataSource removeObjectAtIndex:index];
    [gridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
}

#pragma mark GMGridViewSortingDelegate
- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor orangeColor];
                         cell.contentView.layer.shadowOpacity = 0.2;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = ITEM_COLOR;
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:^(BOOL finished) {
                         // 新闻列表页：调整频道顺序
                         [MobClick event:@"adjust_channel_list"];
                     }
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return NO;
}
//排序逻辑
- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSObject *object = [self.dataSource objectAtIndex:oldIndex];
    [self.dataSource removeObject:object];
    [self.dataSource insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [self.dataSource exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

@end
