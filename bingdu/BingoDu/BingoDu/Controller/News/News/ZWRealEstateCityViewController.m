#import "ZWRealEstateCityViewController.h"
#import "ALView+PureLayout.h"
#import "ZWLocationManager.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@interface ZWRealEstateCityCell ()

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

/** 城市名称 */
@property (nonatomic, strong) UILabel *cityLabel;

@end

@implementation ZWRealEstateCityCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.cityLabel];
    }
    return self;
}

- (UILabel *)cityLabel {
    if (!_cityLabel) {
        _cityLabel = [UILabel newAutoLayoutView];
        _cityLabel.numberOfLines = 1;
        _cityLabel.font = [UIFont systemFontOfSize:15];
        _cityLabel.textColor = COLOR_333333;
    }
    return _cityLabel;
}

- (void)setData:(NSDictionary *)data {
    _data = data;
    if (_data) {
        self.cityLabel.text = _data[@"region_name"];
        if ([_data[@"is_loupan"] boolValue]) {
            self.backgroundColor = [UIColor whiteColor];
            
            self.cityLabel.textColor = COLOR_333333;
            
            self.layer.borderColor = COLOR_E5E5E5.CGColor;
            self.layer.borderWidth = 0.5;
        } else {
            self.backgroundColor = [UIColor colorWithHexString:@"#e6e6e6"];
            
            self.cityLabel.textColor = COLOR_848484;
            
            self.layer.borderColor = [UIColor colorWithHexString:@"#cccccc"].CGColor;
            self.layer.borderWidth = 0.5;
        }
    }
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        // 标题适配
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.cityLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.cityLabel autoCenterInSuperview];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.cityLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.cityLabel.bounds);
}

@end

@interface ZWRealEstateCityViewController ()

/** 城市 */
@property (nonatomic, strong) NSArray *cities;

@end

@implementation ZWRealEstateCityViewController

#pragma mark - Getter & Setter -
- (NSArray *)cities {
    if (!_cities) {
        _cities = [NSArray array];
    }
    return _cities;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUserInterface];
    [self initData];
    [self sendRequestForLoadingCityData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UI management -
/** 初始化界面 */
- (void)initUserInterface {
    
    self.title = @"切换城市";
    
    self.collectionView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    
    [self.collectionView registerClass:[ZWRealEstateCityCell class] forCellWithReuseIdentifier:NSStringFromClass([ZWRealEstateCityCell class])];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
}

/** 刷新界面 */
- (void)updateUserInterface {
    [self.collectionView reloadData];
}

#pragma mark - Network management -
/** 发送网络请求加载城市数据 */
- (void)sendRequestForLoadingCityData {
    NSURL *url = [NSURL URLWithString:@"http://douhuilai.gzlinker.cn/index.php?g=Wap&m=Bingdu&a=city"];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSData *responseData = [request responseData];
        NSDictionary *result = [responseData objectFromJSONData];
        if (result && [result isKindOfClass:[NSDictionary class]] && [result[@"code"] isEqualToString:@"0001"]) {
            [self configureData:result[@"data"]];
            [self updateUserInterface];
        }
    }];
    [request setFailedBlock:^{
        occasionalHint(@"请求失败");
    }];
    [request startAsynchronous];
}

#pragma mark - Data management -
/** 初始化数据 */
- (void)initData {
    // 先读取缓存数据
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:kRealEstateCityData];
    if (array) {
        self.cities = array;
    }
}

/** 配置城市数据 */
- (void)configureData:(NSArray *)data {
    self.cities = data;
    // 更新缓存数据
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kRealEstateCityData];
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // 定位成功
    if ([[ZWLocationManager city] isValid]) {
        return 2;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([[ZWLocationManager city] isValid]) {
        if (0 == section) {
            return 1;
        }
    }
    return [self.cities count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[ZWLocationManager city] isValid]) {
        if (0 == indexPath.section) {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.borderColor = COLOR_E5E5E5.CGColor;
            cell.layer.borderWidth = 0.5;
            
            NSString *cityText = [ZWLocationManager city];
            NSString *fullText = [NSString stringWithFormat:@"当前定位城市：%@", cityText];
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
            NSRange hilightedRange = [fullText rangeOfString:cityText];
            [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_MAIN range:hilightedRange];
            
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = COLOR_333333;
            label.attributedText = attributedText;
            [label sizeToFit];
            label.center = CGPointMake(CGRectGetWidth(cell.bounds)/2, CGRectGetHeight(cell.bounds)/2);
            label.dop_x = 10;
            [cell.contentView addSubview:label];
            return cell;
        }
    }
    
    ZWRealEstateCityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZWRealEstateCityCell class]) forIndexPath:indexPath];
    cell.data = self.cities[indexPath.item];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = 0;
    
    if ([[ZWLocationManager city] isValid]) {
        section = 1;
    }
    
    if (section == indexPath.section && kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                             withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = COLOR_848484;
        label.text = @"查看更多城市购房优惠";
        [label sizeToFit];
        label.center = CGPointMake(CGRectGetWidth(view.bounds)/2, CGRectGetHeight(view.bounds)/2);
        label.dop_x = 10;
        [view addSubview:label];
        return view;
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate -
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[ZWLocationManager city] isValid]) {
        if (0 == indexPath.section) {
            return NO;
        }
    }
    // 未开放城市不可以选择
    NSDictionary *dict = self.cities[indexPath.item];
    return [dict[@"is_loupan"] boolValue];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 高亮背景
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    
    // 更新缓存数据
    NSDictionary *dict = self.cities[indexPath.item];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kRealEstateSelectedCity];
    
    // 通知新闻列表界面更新城市
    if (self.delegate && [self.delegate respondsToSelector:@selector(realEstateViewController:didSelectCity:)]) {
        [self.delegate realEstateViewController:self didSelectCity:dict];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[ZWLocationManager city] isValid]) {
        if (0 == indexPath.section) {
            return CGSizeMake(SCREEN_WIDTH, 50);
        }
    }
    return CGSizeMake((SCREEN_WIDTH-2*10-2*8)/3, 34);
}

- (UIEdgeInsets)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ([[ZWLocationManager city] isValid]) {
        if (0 == section) {
            return UIEdgeInsetsMake(10, 0, 0, 0);
        }
    }
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ([[ZWLocationManager city] isValid]) {
        if (0 == section) {
            return 0;
        }
    }
    return 8;
}

- (CGFloat)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ([[ZWLocationManager city] isValid]) {
        if (0 == section) {
            return 0;
        }
    }
    return 8;
}

- (CGSize)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([[ZWLocationManager city] isValid]) {
        if (0 == section) {
            return CGSizeZero;
        }
    }
    return CGSizeMake(SCREEN_WIDTH, 40);
}

@end
