#import "ZWBingyouCommentTableView.h"
#import "ZWNewsTalkModel.h"
#import "ZWReviewCell.h"
#import "ZWBingYouCell.h"
@interface ZWBingyouCommentTableView()<ZWBingYouTableCellDelegate>
@end
@implementation ZWBingyouCommentTableView

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.dataSource = self;
        self.backgroundColor = [UIColor whiteColor];
        [self setSeparatorColor:COLOR_E7E7E7];
        self.separatorStyle=UITableViewCellSeparatorStyleNone;
        self.backgroundColor=COLOR_F8F8F8;;
    }
    return self;
}

#pragma mark - Properties
-(void)setCellDataSources:(NSMutableArray *)cellDataSources
{
    if (_cellDataSources!=cellDataSources)
    {
        _cellDataSources=cellDataSources;
    }
    [self reloadData];
}

#pragma mark - tableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [_cellDataSources count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    ZWNewsTalkModel *model=[_cellDataSources objectAtIndex:indexPath.row];
    return model.repley_cellHeight;
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
    [cell setFriend:[_cellDataSources objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.row;
    /**2099是评论操作菜单的tag*/
    UIView *subView=[cell viewWithTag:2099];
    if (subView)
    {
        [subView removeFromSuperview];
        subView=nil;
    }
    return cell;
}
- (void)bingYouTableViewCell:(ZWBingYouCell *)tableViewCell reply:(BOOL)isReply
{
    if(_commentCallback)
    {
        if (isReply)
        {
           _commentCallback(ZWClickReply,nil);
        }

    }
}
- (void)bingYouTableViewCell:(ZWBingYouCell *)tableViewCell didClickCellWithNewsInfo:(Friend *)newsInfo
{
    if(_commentCallback)
    {
        _commentCallback(ZWClickReadOldAriticle,newsInfo);
    }
}
@end
