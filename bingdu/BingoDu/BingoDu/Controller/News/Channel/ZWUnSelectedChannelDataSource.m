#import "ZWUnSelectedChannelDataSource.h"
#import "ZWChannelDataManager.h"

//元素
#define ITEM_COLOR [UIColor whiteColor]

@implementation ZWUnSelectedChannelDataSource

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [[[ZWChannelDataManager sharedInstance] unSelectedChannelList] count];
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
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = ITEM_COLOR;
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 3;
        view.layer.borderColor = [UIColor colorWithHexString:@"d5d5d5"].CGColor;
        view.layer.borderWidth = 0.3;
        
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //元素字面值
    UILabel *itemlabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    itemlabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    itemlabel.text = (NSString *)[[[ZWChannelDataManager sharedInstance] unSelectedChannelList] objectAtIndex:index];
    itemlabel.textAlignment = NSTextAlignmentCenter;
    itemlabel.backgroundColor = [UIColor clearColor];
    itemlabel.textColor = COLOR_333333;
    itemlabel.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:itemlabel];
    
    return cell;
}

#pragma mark GMGridViewActionDelegate
//处理删除行为
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if([self.delegate respondsToSelector:@selector(channelDataSource:didTapOnItemTitle:)])
    {
        [self.delegate channelDataSource:self didTapOnItemTitle:self.dataSource[position]];
    }
}

@end
