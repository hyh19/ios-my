#import "FBTopTagsView.h"
#import "FBTopTagsCell.h"
#import "FBAllTagsViewController.h"

@interface FBTopTagsView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

/** 完成按钮 */
@property (nonatomic, strong) UIButton *moreButton;

/** 分割线 */
@property (nonatomic, strong) UIView *separatorView1;

@property (nonatomic, strong) UIView *separatorView2;

@property (nonatomic, strong) UIView *blackView;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBTopTagsView

#pragma mark - Init -
- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.blackView];
        [self addSubview:self.moreButton];
        [self addSubview:self.collectionView];
        [self.blackView addSubview:self.separatorView1];
        [self.moreButton addSubview:self.separatorView2];
        
        [self.blackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 10));
            make.centerX.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 45));
            make.bottom.equalTo(self.blackView.mas_top);
            make.centerX.equalTo(self);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.moreButton.mas_top);
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        
        [self.separatorView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 0.5));
            make.centerX.equalTo(self);
            make.top.equalTo(self.blackView);
        }];
        
        [self.separatorView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 0.5));
            make.centerX.equalTo(self);
            make.top.equalTo(self.moreButton);
        }];
        
        NSArray *tagArrays1 = [self getTags];
        
        // tag数量小于2个
        if (tagArrays1.count < 2) {
            //
        } else {
            if (tagArrays1.count < 4) {
                for (int i = 0; i < 2; i ++) {
                    NSString *string = tagArrays1[i];
                    [self.tagArrays addObject:string];
                }

            } else {
                for (int i = 0; i < 4; i ++) {
                    NSString *string = tagArrays1[i];
                    [self.tagArrays addObject:string];
                }
            }
        }
        
        self.enterTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

#pragma mark - Getter and Setter -
- (UIView *)blackView {
    if (!_blackView) {
        _blackView = [[UIView alloc] init];
        _blackView.backgroundColor = COLOR_FFFFFF;
    }
    return _blackView;
}

- (UIView *)separatorView1 {
    if (!_separatorView1) {
        _separatorView1 = [[UIView alloc] init];
        _separatorView1.backgroundColor = COLOR_e3e3e3;
    }
    return _separatorView1;
}

- (UIView *)separatorView2 {
    if (!_separatorView2) {
        _separatorView2 = [[UIView alloc] init];
        _separatorView2.backgroundColor = COLOR_e3e3e3;
    }
    return _separatorView2;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] init];
        [_moreButton setBackgroundColor:COLOR_FFFFFF];
        [_moreButton setTitle:kLocalizationWorldHotTag forState:UIControlStateNormal];
        [_moreButton setTitleColor:COLOR_888888 forState:UIControlStateNormal];
        [_moreButton.titleLabel setFont:FONT_SIZE_15];
        [_moreButton addTarget:self action:@selector(onTouchButtonMore) forControlEvents:UIControlEventTouchUpInside];
        [_moreButton debug];
    }
    return _moreButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0.5;
        layout.minimumInteritemSpacing = 0.5;
        layout.itemSize = CGSizeMake(SCREEN_WIDTH/2, 44.5);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setBackgroundColor:COLOR_e3e3e3];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        
        [_collectionView registerClass:[FBTopTagsCell class] forCellWithReuseIdentifier:NSStringFromClass([FBTopTagsCell class])];
    }
    return _collectionView;
}

- (NSMutableArray *)tagArrays {
    if (!_tagArrays) {
        _tagArrays = [[NSMutableArray alloc] init];
    }
    return _tagArrays;
}

- (NSArray*)getTags {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    id result = [defaults objectForKey:kUserDefaultsHashTags];
    if(result) {
        NSArray* array = [FBTagsModel mj_objectArrayWithKeyValuesArray:result];
        
        NSMutableArray *tags = [[NSMutableArray alloc] init];
        for(FBTagsModel *model in array)
        {
            if([model.name length] && ![model.name isEqualToString:@"other"]) {
                [tags addObject:model.name];
            }
        }
        
        return tags;
    }
    return nil;
}

#pragma mark - Event Handler -
- (void)onTouchButtonMore {
    
    // 打点统计：每点击一次全球热门话题+1（林思敏）
    [self st_reportAllHashTagsEvent];
    
    if ([self.delegate respondsToSelector:@selector(getAllTagsList)]) {
        [self.delegate getAllTagsList];
    }
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tagArrays.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FBTopTagsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FBTopTagsCell class]) forIndexPath:indexPath];
    cell.tagLabel.text = self.tagArrays[indexPath.item];
    if (indexPath.item == 0) {
        cell.tagLabel.textColor = [UIColor hx_colorWithHexString:@"2fc6af"];
    } else if (indexPath.item == 1) {
        cell.tagLabel.textColor = COLOR_FFC600;
    } else if (indexPath.item == 2) {
        cell.tagLabel.textColor = COLOR_EF4242;
    } else if (indexPath.item == 3) {
        cell.tagLabel.textColor = COLOR_MAIN;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tag = self.tagArrays[indexPath.item];
    
    // 打点统计：new页面前四的tag每点击一次+1（林思敏）
    [self st_reportClickNewHashTagEvent:tag];
    
    if ([self.delegate respondsToSelector:@selector(pushTagListViewControllerWithTag:)]) {
        [self.delegate pushTagListViewControllerWithTag:tag];
    }
}

#pragma mark - Statistics -
/** new页面前四的tag每点击一次+1 */
- (void)st_reportClickNewHashTagEvent:(NSString *)tag {
    EventParameter *eventParmeter = [FBStatisticsManager eventParameterWithKey:@"content" value:tag];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"hashtag_click"  eventParametersArray:@[eventParmeter]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每点击一次全球热门话题+1 */
- (void)st_reportAllHashTagsEvent {
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"worldhottag_click" eventParametersArray:nil];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
