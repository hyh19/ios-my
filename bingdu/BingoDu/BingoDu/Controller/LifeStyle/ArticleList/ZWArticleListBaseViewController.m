#import "ZWArticleListBaseViewController.h"
#import "ZWArticleDetailViewController.h"
#import "ZWArticleModel.h"
#import "NewsList.h"
#import "AppDelegate.h"
#import "NewsPicList.h"
#import "NSDate+Utilities.h"
#import "ZWArticleADModel.h"
#import "ZWArticleInfoADCell.h"
#import "ZWAdvertiseSkipManager.h"
#import "ZWFeaturedArticlesViewController.h"
#import "ZWCategoryArticlesViewController.h"
#import "ZWLoopADCell.h"

@interface ZWArticleListBaseViewController () <UITableViewDelegate, UITableViewDataSource, PullTableViewDelegate>

/** 置顶文章 */
@property (nonatomic, strong, readwrite) NSMutableArray *topList;

/** 普通文章 */
@property (nonatomic, strong, readwrite) NSMutableArray *articleList;

/** 缓存文章 */
@property (nonatomic, strong, readwrite) NSMutableArray *cacheList;

/** 广告列表 */
@property (nonatomic, strong, readwrite) NSMutableArray *ADList;

@end

@implementation ZWArticleListBaseViewController

#pragma mark - Getter & Setter -
- (NSMutableArray *)topList {
    if (!_topList) {
        _topList = [NSMutableArray array];
    }
    return _topList;
}

- (NSMutableArray *)articleList {
    if (!_articleList) {
        _articleList = [NSMutableArray array];
    }
    return _articleList;
}

- (NSMutableArray *)cacheList {
    if (!_cacheList) {
        _cacheList = [[NSMutableArray alloc] init];
    }
    return _cacheList;
}

- (NSMutableArray *)ADList {
    if (!_ADList) {
        _ADList = [[NSMutableArray alloc] init];
    }
    return _ADList;
}

- (PullTableView *)tableView {
    if (!_tableView) {
        _tableView = [[PullTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-SEGMENT_BAR_HEIGHT-TAB_BAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.pullBackgroundColor = [UIColor clearColor];
        _tableView.pullRefreshTextColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.hideActivity = YES;
        _tableView.pullDelegate = self;
        _tableView.separatorColor = COLOR_E7E7E7;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSMutableDictionary *)offscreenCells {
    if (!_offscreenCells) {
        _offscreenCells = [NSMutableDictionary dictionary];
    }
    return _offscreenCells;
}

- (void)setLoadCacheNow:(BOOL)loadCacheNow {
    _loadCacheNow = loadCacheNow;
    [self.tableView hidesLoadMoreView:_loadCacheNow];
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationArticleRead:) name:kNotificationNewsLoadFinished object:nil];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    // 解决在 iOS 7 和 iOS 8 下分隔线左右边距无法设置为0的问题的方法
    // iOS 7
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // iOS 8
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Data management -
/** 标记某一条新闻的已读状态 */
- (void)markNewsModelWithID:(NSString *)newsID {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"newsType==%d && isFeatured==%@ && newsId==%@",1, @(YES), newsID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray* fetchResult = [[[AppDelegate sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (error) { ZWLog(@"Error:%@",error); }
    
    for (NewsList *news in fetchResult) {
        [news setLoadFinished:[NSNumber numberWithBool:YES]];
    }
    if (![[AppDelegate sharedInstance].managedObjectContext save:&error]) {
        if (error) { ZWLog(@"Error:%@",error); }
    }
}

#pragma mark - Cache data management -
/** 加载缓存数据 */
- (void)preloadCacheData {
    
    if (!self.openCache) {
        return;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *newsEntity = [NSEntityDescription entityForName:@"NewsList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
    
    [fetchRequest setEntity:newsEntity];
    
    NSPredicate *predicate = nil;
    
    // ChannelID为-1表示精选
    if (-1 == self.channelID) {
        predicate = [NSPredicate predicateWithFormat:@"newsType==%d && isFeatured==%@", 1, @(YES)];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"newsType==%d && channel==%@", 1, [NSString stringWithFormat:@"%ld", (long)self.channelID]];
    }
    
    [fetchRequest setPredicate:predicate];
    
    // 先按缓存到数据库的时间排序，然后按照索引排序
    NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cachedTimestamp" ascending:NO];
    NSSortDescriptor *indexDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"newsIndex" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[timeDescriptor, indexDescriptor]];
    
    NSError *error = nil;
    
    NSMutableArray *fetchResult = [[[AppDelegate sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (!fetchResult) {
        ZWLog(@"Error:%@",error);
    }
    
    // 配置数据库查询结果
    for (NewsList *entity in fetchResult) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict safe_setObject:(entity.newsId? entity.newsId : @"") forKey:@"newsId"];
        
        [dict safe_setObject:entity.lNum forKey:@"likeNum"];
        
        [dict safe_setObject:entity.detailUrl forKey:@"detailUrl"];
        
        [dict safe_setObject:entity.newsTitle forKey:@"newsTitle"];
        
        [dict safe_setObject:entity.dNum forKey:@"dislikeNum"];
        
        [dict safe_setObject:entity.publishTime forKey:@"publishTime"];
        
        [dict safe_setObject:entity.sNum forKey:@"shareNum"];
        
        [dict safe_setObject:entity.cNum  forKey:@"commentNum"];
        
        [dict safe_setObject:entity.channel  forKey:@"channel"];
        
        [dict safe_setObject:(entity.timestamp? entity.timestamp:@"") forKey:@"timestamp"];
        
        [dict setObject:entity.spreadstate forKeyedSubscript:@"promotion"];
        
        [dict safe_setObject:(entity.readNum? entity.readNum:@"0") forKey:@"readNum"];
        
        if (entity.newsSource) { [dict safe_setObject:entity.newsSource forKey:@"newsSource"]; }
        
        if (entity.topicTitle) { [dict safe_setObject:entity.topicTitle forKey:@"topicTitle"]; }
        
        NSMutableArray *picArray = [NSMutableArray array];
        
        // 读取图片
        for (NewsPicList *pic in [entity.newsPic allObjects]) {
            NSMutableDictionary *picDict = [NSMutableDictionary dictionary];
            [picDict safe_setObject:pic.picUrl forKey:@"picUrl"];
            [picDict safe_setObject:pic.picName forKey:@"picName"];
            [picDict safe_setObject:pic.newsId forKey:@"newsId"];
            [picDict safe_setObject:pic.picId forKey:@"picId"];
            if (pic.picIndex) { [picDict safe_setObject:pic.picIndex forKey:@"picIndex"]; }
            [picArray safe_addObject:picDict];
        }
        
        // 图片排序
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"picIndex" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sorter count:1];
        if ([picArray count] > 0) {
            picArray = [NSMutableArray arrayWithArray:[picArray sortedArrayUsingDescriptors:sortDescriptors]];
        }
        
        // 配置新闻数据
        [dict safe_setObject:picArray forKey:@"picList"];
        
        [dict safe_setObject:(entity.position?entity.position:@"") forKey:@"position"];
        
        [dict safe_setObject:entity.zNum forKey:@"praiseNum"];
        
        [dict safe_setObject:(entity.adId? entity.adId:@"0") forKey:@"adId"];
        
        [dict safe_setObject:(entity.displayType? entity.displayType:@"0") forKey:@"displayType"];
        
        if (entity.advType&&![entity.advType isEqualToString:@""]) { [dict safe_setObject:entity.advType forKey:@"advType"]; }
        
        if (entity.redirectType) { [dict safe_setObject:entity.redirectType forKey:@"redirectType"]; }
        
        if (entity.redirectTargetId) { [dict safe_setObject:entity.redirectTargetId forKey:@"redirectTargetId"]; }
        
        // 生活方式文章属性
        if ([entity.summary isValid]) {
            [dict safe_setObject:entity.summary forKey:@"summary"];
        }
        
        if ([entity.channelName isValid]) {
            [dict safe_setObject:entity.channelName forKey:@"channelName"];
        }
        
        ZWArticleModel *model = [ZWArticleModel modelWithData:dict];
        model.newsIndex = entity.newsIndex;
        model.markType = entity.markType;
        model.loadFinished = entity.loadFinished;
        model.isFeatured = entity.isFeatured;
        
        [self.cacheList safe_addObject:model];
    }
}

/** 清除缓存数据 */
- (void)deleteCacheDataIfNeeded {
    // 记录最近一次清除缓存的时间
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *latest = [standardUserDefaults objectForKey:kUserDefaultsLatestDeleteCache];
    if (!latest) {
        latest = [NSDate date];
        [standardUserDefaults setObject:latest forKey:kUserDefaultsLatestDeleteCache];
    } else {
        NSDate *now = [NSDate date];
        // 七天或以上清除一次
        if ([now daysAfterDate:latest]>=7) {
            [self deleteCacheData];
        }
        [standardUserDefaults setObject:now forKey:kUserDefaultsLatestDeleteCache];
    }
}

/** 清除缓存数据 */
- (void)deleteCacheData {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *newsEntity = [NSEntityDescription entityForName:@"NewsList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];

    [fetchRequest setEntity:newsEntity];

    NSPredicate *predicate = nil;
    
    // ChannelID为-1表示精选
    if (-1 == self.channelID) {
        predicate = [NSPredicate predicateWithFormat:@"newsType==%d && isFeatured==%@", 1, @(YES)];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"newsType==%d && channel==%@", 1, [NSString stringWithFormat:@"%ld", (long)self.channelID]];
    }

    [fetchRequest setPredicate:predicate];

    NSError *error = nil;

    NSMutableArray *fetchResult = [[[AppDelegate sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (error) { ZWLog(@"Error:%@",error); }

    for (NewsList* news in fetchResult) {
        [[AppDelegate sharedInstance].managedObjectContext deleteObject:news];
    }

    if (![[AppDelegate sharedInstance].managedObjectContext save:&error]) {
        if (error) { ZWLog(@"Error:%@",error); }
    }
}

- (void)addCacheData:(NSArray *)data {
    
    if (!self.openCache) {
        return;
    }
    
    if ([data count]>0) {
        [self deleteCacheDataIfNeeded];
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    for (int i =0; i<data.count; i++) {
        
        ZWArticleModel *model = data[i];
        
        if (![self checkCachedWithID:model.newsId]) {
            
            NewsList *newEntity = (NewsList *)[NSEntityDescription insertNewObjectForEntityForName:@"NewsList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
            
            // 新闻属性
            [newEntity setNewsId:model.newsId];
            [newEntity setLNum:model.lNum];
            [newEntity setDetailUrl:model.detailUrl];
            [newEntity setNewsTitle:model.newsTitle];
            [newEntity setDNum:model.dNum];
            [newEntity setPublishTime:model.publishTime];
            [newEntity setSNum:model.sNum];
            [newEntity setCNum:model.cNum];
            [newEntity setChannel:model.channel];
            [newEntity setAdvType:model.advType];
            [newEntity setPosition:model.position?model.position:@""];
            [newEntity setTimestamp:model.timestamp];
            [newEntity setReadNum:model.readNum];
            [newEntity setSpreadstate:[NSNumber numberWithInt:model.spread_state ]];
            [newEntity setTopicTitle:model.topicTitle];
            [newEntity setAdId:(model.adId? model.adId:@"0")];
            
            if (model.newsSource) { [newEntity setNewsSource:model.newsSource]; }
            if (model.redirectTargetId) { [newEntity setRedirectTargetId:@([model.redirectTargetId integerValue])]; }
            if (model.redirectType > 0) { [newEntity setRedirectType:@(model.redirectType)]; }
            if (model.onTop) { newEntity.onTop = model.onTop; }
            
            NSMutableArray *array = [NSMutableArray array];
            for (int j=0; j<[model.picList count]; ++j) {
                
                ZWPicModel *pic = [model.picList safe_objectAtIndex:j];
                
                NewsPicList *newsPic = (NewsPicList *)[NSEntityDescription insertNewObjectForEntityForName:@"NewsPicList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
                [newsPic setPicId:[NSNumber numberWithInt:[pic.picId intValue]]];
                [newsPic setNewsId:[NSNumber numberWithInt:[pic.newsId intValue]]];
                [newsPic setPicName:pic.picName];
                [newsPic setPicUrl:pic.picUrl];
                [newsPic setPicIndex:[NSNumber numberWithInt:j]];
                [array safe_addObject:newsPic];
            }
            
            [newEntity setNewsPic:[NSSet setWithArray:array]];
            [newEntity setZNum:model.zNum];
            [newEntity setDisplayType:[NSString stringWithFormat:@"%ld",(unsigned long)model.displayType]];
            [newEntity setMarkType:model.markType];
            [newEntity setState:[NSNumber numberWithInt:model.state]];
            [newEntity setLoadFinished:model.loadFinished];
            
            // 生活方式属性
            newEntity.newsType = @(1);
            // 是否是精选文章
            newEntity.isFeatured = (-1 == self.channelID);
            // 缓存的时间戳
            newEntity.cachedTimestamp = @(now);
            // 排序索引
            newEntity.newsIndex = @(i);
            if ([model.summary isValid]) { newEntity.summary = model.summary; }
            if ([model.channelName isValid]) { newEntity.channelName = model.channelName; }
        }
    }
    
    NSError *error;
    if (![[AppDelegate sharedInstance].managedObjectContext save:&error]) {
        if (error) { ZWLog(@"Error:%@",error); }
    }
}

- (BOOL)checkCachedWithID:(NSString *)newsID {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *newsEntity = [NSEntityDescription entityForName:@"NewsList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
    
    [fetchRequest setEntity:newsEntity];
    
    NSPredicate *predicate = predicate = [NSPredicate predicateWithFormat:@"newsType==%d && newsId==%@", 1, newsID];;
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSMutableArray *fetchResult = [[[AppDelegate sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if ([fetchResult count]>0) {
        return YES;
    }
    return NO;
}

#pragma mark - Event handler -
/** 监听新闻详情页面加载完成状态 */
- (void)onNotificationArticleRead:(NSNotification*)notification {
    
    if (!self.openReadObserve) {
        return;
    }
    
    NSString *newsID = [notification object];
    
    for (ZWNewsModel *newsModel in self.topList){
        if ([newsModel.newsId isEqualToString:newsID]) {
            newsModel.loadFinished = [NSNumber numberWithBool:YES];
        }
    }
    
    for (ZWNewsModel *newsModel in self.articleList){
        if ([newsModel.newsId isEqualToString:newsID]) {
            newsModel.loadFinished = [NSNumber numberWithBool:YES];
        }
    }
    
    for (ZWNewsModel *newsModel in self.cacheList){
        if ([newsModel.newsId isEqualToString:newsID]) {
            newsModel.loadFinished = [NSNumber numberWithBool:YES];
        }
    }
    
    [self markNewsModelWithID:newsID];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.loadCacheNow) {
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return [self.topList count];
    // 该分区是用于提示“再往下就是之前推荐过的文章了”
    } else if (1 == section) {
        return 0;
    } else if (2 == section) {
        return [self.articleList count];
    } else if (3 == section) {
        return [self.cacheList count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // iOS 7
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // iOS 8
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 友盟统计
    if ([self isKindOfClass:[ZWFeaturedArticlesViewController class]]) {
        [MobClick event:@"click_information_list_prime_page"];
    } else if ([self isKindOfClass:[ZWCategoryArticlesViewController class]]) {
        [MobClick event:@"click_information_list_classified_channel_page"];
    }
    
    ZWArticleModel *model = [self modelByIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[ZWArticleInfoADCell class]]) {
        if ([model.advType isEqualToString:@"STREAM"]) {
            [self pushAdvertisementViewController:model];
        }
    } else if ([cell isKindOfClass:[ZWLoopADCell class]]) {
        //
    } else {
        if (model.isFeatured) {
            model.newsSourceType = ZWNewsSourceTypeLifeStyleSelect;
        } else {
            model.newsSourceType = ZWNewsSourceTypeLifeStyleClass;
            [MobClick event:@"click_information_list_classified_channel_page"];
        }
        [self pushNewsDetailViewController:model];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Navgation -
/** 点击进入新闻详情 */
- (void)pushNewsDetailViewController:(ZWArticleModel *)model {
    model.newsType = kNewsTypeLifeStyle;
    ZWArticleDetailViewController *nextViewController = [[ZWArticleDetailViewController alloc] initWithNewsModel:model];
    nextViewController.willBackViewController = self.navigationController.visibleViewController;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 信息流广告跳转 */
- (void)pushAdvertisementViewController:(ZWNewsModel *)model {
    ZWArticleAdvertiseModel *ariticleMode = [ZWArticleAdvertiseModel ariticleModelByNewsModel:model];
    [ZWAdvertiseSkipManager pushViewController:self withAdvertiseDataModel:ariticleMode];
}

#pragma mark - Helper -
- (UITableViewCell *)cellWithClassName:(NSString *)className andIndexPath:(NSIndexPath *)indexPath {
    // 信息流广告
    if ([className isEqualToString:NSStringFromClass([ZWArticleInfoADCell class])]) {
        ZWArticleInfoADCell *cell = (ZWArticleInfoADCell *)[self.tableView dequeueReusableCellWithIdentifier:className];
        cell.backgroundColor = [UIColor whiteColor];
        cell.model = [self modelByIndexPath:indexPath];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        return cell;
    // 转云鹏
    // 轮播广告
    } else if ([className isEqualToString:NSStringFromClass([ZWLoopADCell class])]) {
        ZWLoopADCell *cell = (ZWLoopADCell *)[self.tableView dequeueReusableCellWithIdentifier:className];
        cell.backgroundColor = [UIColor whiteColor];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        return cell;
    } else {
        
        ZWArticleBaseCell *cell = (ZWArticleBaseCell *)[self.tableView dequeueReusableCellWithIdentifier:className];
        cell.model = [self modelByIndexPath:indexPath];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        return cell;
    }
    return nil;
}

- (CGFloat)heightForCellWithClassName:(NSString *)className andIndexPath:(NSIndexPath *)indexPath {
    // 信息流广告
    if ([className isEqualToString:NSStringFromClass([ZWArticleInfoADCell class])]) {
        
        ZWArticleInfoADCell *cell = [self.offscreenCells objectForKey:className];
        if (!cell) {
            cell = [[ZWArticleInfoADCell alloc] init];
            [self.offscreenCells setObject:cell forKey:className];
        }
        cell.model = [self modelByIndexPath:indexPath];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(cell.bounds));
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1;
        return height;
    // 转云鹏
    // 轮播广告
    } else if ([className isEqualToString:NSStringFromClass([ZWLoopADCell class])]) {
        return 115;
    } else {
        
        ZWArticleBaseCell *cell = [self.offscreenCells objectForKey:className];
        if (!cell) {
            cell = [[ZWArticleBaseCell alloc] init];
            [self.offscreenCells setObject:cell forKey:className];
        }
        cell.model = [self modelByIndexPath:indexPath];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(cell.bounds));
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1;
        return height;
    }
    
    return 0;
}

- (ZWArticleModel *)modelByIndexPath:(NSIndexPath *)indexPath {
    ZWArticleModel *model = nil;
    if (0 == indexPath.section) {
        model = self.topList[indexPath.row];
    // 该分区是用于提示“再往下就是之前推荐过的文章了”
    } else if (1 == indexPath.section) {
        model = nil;
    } else if (2 == indexPath.section) {
        model = self.articleList[indexPath.row];
    } else if (3 == indexPath.section) {
        model = self.cacheList[indexPath.row];
    }
    return model;
}

@end
