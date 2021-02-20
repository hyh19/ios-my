#import "FBStoreSegmentedControl.h"
#import "UIImage+ImageWithColor.h"
#import "FBBaseStoreViewController.h"
#import "UIView+Borders.h"

#define kHeaderHeight 50

@interface FBStoreSegmentedControl () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *header;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation FBStoreSegmentedControl

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.header];
        [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.equalTo(kHeaderHeight);
        }];
        
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self).offset(0);
            make.top.equalTo(self.header.mas_bottom).offset(0);
        }];
        
        self.selectedIndex = 0;
    }
    return self;
}

#pragma mark - Life Cycle -

#pragma mark - Getter & Setter -
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame) - kHeaderHeight);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        
        [_collectionView registerClass:[FBStoreSegmentCell class] forCellWithReuseIdentifier:NSStringFromClass([FBStoreSegmentCell class])];
    }
    return _collectionView;
}

- (UIView *)header {
    if (!_header) {
        _header = [[UIView alloc] init];
        _header.backgroundColor = COLOR_F0F7F6;
        [_header addTopBorderWithHeight:0.5 andColor:COLOR_e3e3e3];
        [_header addBottomBorderWithHeight:0.5 andColor:COLOR_e3e3e3];
        UILabel *label = [[UILabel alloc] init];
        [_header addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_header.mas_left).offset(@15);
            make.centerY.equalTo(_header.mas_centerY);
        }];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = COLOR_444444;
        [label sizeToFit];
        label.text = kLocalizationPaymentSelection;
    }
    return _header;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
    [self.collectionView reloadData];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewControllers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FBStoreSegmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FBStoreSegmentCell class]) forIndexPath:indexPath];
    FBBaseStoreViewController *viewController = self.viewControllers[indexPath.row];
    cell.titleLabel.text = viewController.storeTitle;
    cell.logoImageView.image = [UIImage imageNamed:viewController.storeLogo];
    cell.checked = (indexPath.item == self.selectedIndex);
    return cell;
}

#pragma mark - UICollectionViewDelegate -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item != self.selectedIndex) {
        self.selectedIndex = indexPath.item;
        if (self.indexChangeBlock) {
            self.indexChangeBlock(self.selectedIndex);
        }
    }
}

@end

@interface FBStoreSegmentCell ()

@property (nonatomic, strong) UIImageView *checkedImageView;

@end

@implementation FBStoreSegmentCell

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.logoImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.checkedImageView];
        
        [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(30, 30));
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-17);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.logoImageView.mas_bottom).offset(10);
        }];
        
        [self.checkedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(20, 20));
            make.bottom.right.equalTo(self).offset(0);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = COLOR_444444;
        _titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImageView.clipsToBounds = YES;
    }
    return _logoImageView;
}

- (UIImageView *)checkedImageView {
    if (!_checkedImageView) {
        _checkedImageView = [[UIImageView alloc] init];
        _checkedImageView.contentMode = UIViewContentModeScaleAspectFit;
        _checkedImageView.clipsToBounds = YES;
    }
    return _checkedImageView;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    if (_checked) {
        self.layer.borderColor = [UIColor hx_colorWithHexString:@"50e3ce"].CGColor;
        self.layer.borderWidth = 0.5;
        self.checkedImageView.image = [UIImage imageNamed:@"payment_charge_btn_select"];
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
        self.checkedImageView.image = nil;
    }
}

@end
