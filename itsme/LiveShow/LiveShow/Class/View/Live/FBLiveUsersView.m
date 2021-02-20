#import "FBLiveUsersView.h"

@interface FBLiveUsersView () <UICollectionViewDelegate, UICollectionViewDataSource>

/** 观众列表 */
@property (nonatomic, strong) UICollectionView *collectionView;

/** 观众数据 */
@property (nonatomic, strong) NSArray *data;

@end

@implementation FBLiveUsersView

- (void)dealloc {
    self.collectionView.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *superView = self;
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superView);
        }];
    }
    return self;
}

- (NSArray *)data {
    if (!_data) {
        _data = [NSArray array];
    }
    return _data;
}

- (void)reloadUsers:(NSArray *)users {
    self.data = users;
    [self.collectionView reloadData];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 7;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(kAvatarSize, kAvatarSize);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[FBLiveUserCell class] forCellWithReuseIdentifier:NSStringFromClass([FBLiveUserCell class])];
        [_collectionView debugWithBorderColor:[UIColor greenColor]];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FBLiveUserCell *cell = (FBLiveUserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FBLiveUserCell class]) forIndexPath:indexPath];
    cell.model = self.data[indexPath.row];
    cell.doTapAvatarAction = ^ (FBUserInfoModel *model) {
        if (self.doTapAvatarAction) {
            self.doTapAvatarAction(model);
        }
    };
    return cell;
}

@end
