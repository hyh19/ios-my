
#import "ZWLaunchGuidanceTableView.h"
#import "ZWLaunchGuidanceCell.h"
#import "ZWLifeStyleModel.h"

@interface ZWLaunchGuidanceTableView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)NSArray *listArray;

@property (nonatomic, assign)NSInteger totol;

@property (nonatomic, strong)NSMutableArray *selectArray;

@property (nonatomic, assign)BOOL isAnimation;

@end

@implementation ZWLaunchGuidanceTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource=self;
        self.delegate = self;
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
//        self.bounces = NO;
    }
    return self;
}

- (void)setListArray:(NSArray *)listArray
{
    if(_listArray != listArray)
    {
        _listArray = listArray;
    }
}

- (NSMutableArray *)selectArray
{
    if(!_selectArray)
    {
        _selectArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _selectArray;
}

- (void)loadLocalLifeStyleDataSource
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LifeStyle" ofType:@"plist"];
    NSArray *list = [[NSArray alloc] initWithContentsOfFile:path];
    NSMutableArray *tempList = [[NSMutableArray alloc] initWithCapacity:0];
    for(NSDictionary *dict in list)
    {
        ZWLifeStyleModel *model = [ZWLifeStyleModel loadModelFromDictionary:dict];
        [tempList addObject:model];
    }
    [self setListArray:[tempList copy]];
    [self reloadData];
}

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self listArray])
        return [self listArray].count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LaunchGuidanceCell";
    
    ZWLaunchGuidanceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWLaunchGuidanceCell" owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[ZWLaunchGuidanceCell class]])
                cell = (ZWLaunchGuidanceCell *)oneObject;
    }
    
    ZWLifeStyleModel *model = [self listArray][indexPath.row];
    
    [cell.bgImageView setImage:[UIImage imageNamed:model.imageName]];
    
    if([[self selectArray] containsObject:model])
    {
        [cell.markImageView setImage:[UIImage imageNamed:@"LaunchSelected"]];
    }
    else
    {
        [cell.markImageView setImage:nil];
    }

    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 106 * SCREEN_WIDTH/320;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.isAnimation == NO)
    {
        CATransform3D translation;
        translation = CATransform3DMakeTranslation(0, 480, 0);
        
        cell.layer.shadowColor = [[UIColor blackColor]CGColor];
        cell.layer.shadowOffset = CGSizeMake(10, 10);
        
        cell.layer.transform = translation;
        cell.layer.anchorPoint = CGPointMake(0, 0.5);
        
        if(cell.layer.position.x != 0){
            cell.layer.position = CGPointMake(0, cell.layer.position.y);
        }
        
        [UIView beginAnimations:@"translation" context:NULL];
        [UIView setAnimationDuration:0.8 + indexPath.row*0.2];
        cell.layer.transform = CATransform3DIdentity;
        
        cell.layer.shadowOffset = CGSizeMake(0, 0);
        
        [UIView commitAnimations];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWLifeStyleModel *model = [self listArray][indexPath.row];
    if([[self selectArray] containsObject:model])
    {
        [[self selectArray] removeObject:model];
    }
    else
    {
        [[self selectArray] addObject:model];
    }
    self.isAnimation = YES;
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if([[self tableViewDelegate] respondsToSelector:@selector(didSelectItemsWithList:)])
    {
        [[self tableViewDelegate] didSelectItemsWithList:[[self selectArray] copy]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isAnimation = YES;
}

@end
