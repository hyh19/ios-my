#import "ZWImageChannelCollectionView.h"
#import "ZWImageChannelCell.h"

@implementation ZWImageChannelCollectionView

#pragma mark -init
-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self setDataSource:self];
        self.backgroundColor = [UIColor clearColor];
        [self registerNib:[UINib nibWithNibName:@"ZWImageChannelCell" bundle:nil] forCellWithReuseIdentifier:@"ZWImageChannelCell"];
    }
    return self;
}

#pragma mark - Praviate method
-(void)setNewsDictionary:(NSMutableDictionary *)newsDictionary
{
    _newsDictionary=newsDictionary;
    [self reloadData];
}

-(void)forceToFreshData{
    [self setContentOffset:CGPointMake(self.contentOffset.x,0) animated:NO];
    [self setPullTableIsRefreshing:YES];
    [self performSelector:@selector(refreshData) withObject:nil afterDelay:0.5f];
}

-(void)refreshData
{
    [pullDelegate pullCollectionViewDidTriggerRefresh:self];
}

#pragma  mark -UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self newsDictionary][@"newsListData"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZWImageChannelCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"ZWImageChannelCell"
                                              forIndexPath:indexPath];
    [cell setNewsModel:[self newsDictionary][@"newsListData"][indexPath.row]];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZWLog(@"items_%ld", indexPath.row);
}

@end
