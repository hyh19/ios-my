#import "ZWBingYouTableView.h"
#import "ZWBingYouCell.h"

@interface ZWBingYouTableView () <ZWBingYouTableCellDelegate>

@end

@implementation ZWBingYouTableView

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.dataSource = self;
        self.backgroundColor = [UIColor clearColor];
        [self setSeparatorColor:COLOR_E7E7E7];
        self.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return self;
}

#pragma mark - Properties
-(void)setCellDataSources:(NSMutableArray *)cellDataSources
{
    if (_cellDataSources!=cellDataSources) {
        _cellDataSources=cellDataSources;
    }
    [self reloadData];
}

#pragma mark - tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [[self cellDataSources] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if([self cellDataSources].count > 0)
    {
        ZWBingYouCell *cell;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWBingYouCell" owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[ZWBingYouCell class]])
                cell = (ZWBingYouCell *)oneObject;
        Friend *friend = [[self cellDataSources] objectAtIndex:indexPath.row];
        CGRect oneLineFrame = [NSString heightForString:@"你好" fontSize:(![[UIScreen mainScreen] isiPhone6]) ? 14 : 15 andSize:CGSizeMake(self.frame.size.width - [cell commentLabel].frame.origin.x - 12, MAXFLOAT)];
        CGRect frame = [NSString heightForString:friend.comment fontSize:(![[UIScreen mainScreen] isiPhone6]) ? 14 : 15 andSize:CGSizeMake(self.frame.size.width - [cell commentLabel].frame.origin.x - 12, MAXFLOAT)];
        
        if(frame.size.height>2*oneLineFrame.size.height)
            frame.size.height=2*oneLineFrame.size.height;
        
        if([friend.actionType integerValue] != commetActionType)
        {
            return 116;
        }
        else
        {
            if(frame.size.height > 0 && friend.comment.length > 0)
                return 127  + frame.size.height;
            return 116;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDenifer=@"ZWBingYouCell";
    ZWBingYouCell *cell=[tableView dequeueReusableCellWithIdentifier:cellDenifer];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWBingYouCell" owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[ZWBingYouCell class]])
                cell = (ZWBingYouCell *)oneObject;
        cell.delegate = self;
    }
    [cell setFriend:[[self cellDataSources] objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark -ZWBingYouCell delegate method
- (void)bingYouTableViewCell:(ZWBingYouCell *)tableViewCell didClickCellWithNewsInfo:(Friend *)newsInfo
{
    if([self.tableViewDelegate respondsToSelector:@selector(pushToNewsDetailViewWithTableView:dataSource:)])
    {
        [self.tableViewDelegate pushToNewsDetailViewWithTableView:self dataSource:newsInfo];
    }
}

@end
