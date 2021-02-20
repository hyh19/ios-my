#import "FBGiftPageView.h"
#import "FBLiveUserCell.h"
#import "FBGiftCell.h"
#import "UIImage-Helpers.h"
#import "FBLiveRoomNetworkManager.h"
#import "FBProfileNetWorkManager.h"
#import "FBLoginInfoModel.h"

/** 礼物滑动列表的高度 */
#define kCollectionViewHeight 200

/** 礼物圆点指示器的高度 */
#define kPageControlHeight 20

/** 礼物选项的宽高 */
#define kCollectionViewCellSize CGSizeMake(SCREEN_WIDTH/4, 100)

/** 用于记录选择礼物的状态 */
#define kCollectionView @"CollectionView"

/** 用于记录选择礼物的状态 */
#define kIndexPath @"IndexPath"

@interface FBGiftPageView () <UICollectionViewDelegate, UICollectionViewDataSource> {
    FBGiftModel *_selectedGift;
}

/** 工具栏 */
@property (nonatomic, strong) UIView *toolView;

/** 余额 */
@property (nonatomic, strong) UILabel *balanceLabel;

/** 发送按钮 */
@property (nonatomic, strong) UIButton *sendButton;

/** 连发按钮 */
@property (nonatomic, strong) UIButton *comboButton;

/** 连发文本 */
@property (nonatomic, strong) UILabel *comboLabel;

/** 滚动控件 */
@property (nonatomic, strong) UIScrollView *scrollView;

/** 礼物翻页指示器(小圆点) */
@property (nonatomic, strong) UIPageControl *pageIndicator;

/** 礼物数据 */
@property (nonatomic, strong) NSMutableArray *gifts;

/** 选定的礼物状态 */
@property (nonatomic, strong) NSMutableDictionary *selectedMemo;

/** 选定的礼物 */
@property (nonatomic, strong) FBGiftModel *selectedGift;

/** 连发计时器 */
@property (nonatomic, strong) NSTimer *comboTimer;

/** 更新余额定时器 */
@property (nonatomic, strong) NSTimer *balanceTimer;

@end

@implementation FBGiftPageView

- (void)dealloc {
    for (UIView *subview in self.scrollView.subviews) {
        if ([subview isKindOfClass:[UICollectionView class]]) {
            UICollectionView *collectionView = (UICollectionView *)subview;
            collectionView.delegate = nil;
        }
    }
    [self removeTimers];
    [self removeNotifiationObservers];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configData];
        [self configUI];
        [self addTimers];
        [self addNotificationObservers];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.layer.cornerRadius = 2.5;
        _sendButton.layer.masksToBounds = YES;
        [_sendButton setTitle:kLocalizationButtonSend forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[UIImage imageWithColor:COLOR_ASSIST_TEXT] forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[UIImage imageWithColor:[UIColor hx_colorWithHexString:@"cdcfd5"]] forState:UIControlStateDisabled];
        [_sendButton.titleLabel setFont:FONT_SIZE_16];
        _sendButton.enabled = NO;
        
        __weak typeof(self) wself = self;
        [_sendButton bk_addEventHandler:^(id sender) {
            [wself onTouchButtonSend:sender];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (UILabel *)comboLabel {
    if (!_comboLabel) {
        _comboLabel = [[UILabel alloc] init];
        _comboLabel.text = @"Combo";
        _comboLabel.font = FONT_SIZE_12;
        [_comboLabel sizeToFit];
        _comboLabel.textColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.8];
    }
    return _comboLabel;
}

- (UIButton *)comboButton {
    if (!_comboButton) {
        _comboButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_comboButton setBackgroundImage:[UIImage imageNamed:@"gift_btn_combo_nor"] forState:UIControlStateNormal];
        [_comboButton setBackgroundImage:[UIImage imageNamed:@"gift_btn_combo_hig"] forState:UIControlStateHighlighted];
        __weak typeof(self) wself = self;
        [_comboButton bk_addEventHandler:^(id sender) {
            [wself onTouchButtonCombo:sender];
        } forControlEvents:UIControlEventTouchUpInside];
        _comboButton.hidden = YES;
        
        [_comboButton addSubview:self.comboLabel];
        [self.comboLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(_comboButton);
//            make.centerY.equalTo(_comboButton).offset(10);
            make.right.bottom.equalTo(_comboButton).offset(-15);
        }];
    }
    return _comboButton;
}

- (UIView *)toolView {
    if (!_toolView ) {
        _toolView = [[UIView alloc] init];
        _toolView.backgroundColor = [UIColor clearColor];
        [_toolView debugWithBorderColor:[UIColor blueColor] andBorderWidth:3];
        
        UIView *superView = _toolView;
        
        __weak typeof(self) wself = self;
        
        [superView addSubview:self.sendButton];
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(90, 45));
            make.bottom.right.equalTo(superView);
        }];

        UIImageView *diamond = [[UIImageView alloc] init];
        diamond.image = [UIImage imageNamed:@"pub_icon_diamond"];
        [superView addSubview:diamond];
        [diamond mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(20, 20));
            make.centerY.equalTo(self.sendButton);
            make.left.equalTo(superView).offset(13);
            [diamond debug];
        }];
        
        [superView addSubview:self.balanceLabel];
        [self.balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(diamond.mas_right).offset(5);
            make.centerY.equalTo(diamond);
            [self.balanceLabel debug];
        }];
        

        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.image = [UIImage imageNamed:@"gift_icon_arrow"];
        [superView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(5, 10));
            make.centerY.equalTo(diamond);
            make.left.equalTo(self.balanceLabel.mas_right).offset(5);
            [arrow debug];
        }];

        UIButton *depositButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [depositButton bk_addEventHandler:^(id sender) {
            if (wself.doPurchaseAction) {
                wself.doPurchaseAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [superView addSubview:depositButton];
        [depositButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(superView);
            make.left.equalTo(diamond);
            make.right.equalTo(arrow);
        }];
    }
    return _toolView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView debug];
    }
    return _scrollView;
}


- (NSMutableArray *)gifts {
    if (!_gifts) {
        _gifts = [NSMutableArray array];
    }
    return _gifts;
}

- (FBGiftModel *)selectedGift {
    UICollectionView *selectedCollectionView = self.selectedMemo[kCollectionView];
    NSIndexPath *selectedIndexPath = self.selectedMemo[kIndexPath];
    if (selectedCollectionView) {
        FBGiftModel *model = self.gifts[selectedCollectionView.tag][selectedIndexPath.item];
        return model;
    }
    return nil;
}

- (NSMutableDictionary *)selectedMemo {
    if (!_selectedMemo) {
        _selectedMemo = [NSMutableDictionary dictionary];
    }
    return _selectedMemo;
}

- (UILabel *)balanceLabel {
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc] init];
        _balanceLabel.textColor = COLOR_TEXT_HIGHLIGHT;
        _balanceLabel.font = FONT_SIZE_16;
        NSUInteger balance = [[FBLoginInfoModel sharedInstance] balance];
        _balanceLabel.text = [NSString stringWithFormat:@"%ld", (long)balance];
        [_balanceLabel debug];
    }
    return _balanceLabel;
}

- (UIPageControl *)pageIndicator {
    if (!_pageIndicator) {
        _pageIndicator = [[UIPageControl alloc] init];
        _pageIndicator.hidesForSinglePage = YES;
        _pageIndicator.numberOfPages = self.gifts.count;
        _pageIndicator.pageIndicatorTintColor = [UIColor grayColor];
        _pageIndicator.currentPageIndicatorTintColor = COLOR_ASSIST_TEXT;
    }
    return _pageIndicator;
}

#pragma mark - Data Management -
- (void)configData {
    
    [self.gifts removeAllObjects];
    
    NSArray *allGifts = [[GVUserDefaults standardUserDefaults] giftList];
    NSInteger pageCount = allGifts.count / 8;
    for (int i = 0; i < pageCount; ++i) {
        NSArray *pageArray = [allGifts subarrayWithRange:NSMakeRange(i * 8, 8)];
        NSArray *pageObject = [FBGiftModel mj_objectArrayWithKeyValuesArray:pageArray];
        [self.gifts addObject:pageObject];
    }
    
    if (allGifts.count % 8 > 0) {
        NSArray *lastPage = [allGifts subarrayWithRange:NSMakeRange(pageCount * 8, allGifts.count % 8)];
        NSArray *lastObject = [FBGiftModel mj_objectArrayWithKeyValuesArray:lastPage];
        [self.gifts addObject:lastObject];
    }
}


#pragma mark - UI Management -
/** 配置UI */
- (void)configUI {
    
    UIView *superView = self;
    
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(superView);
        make.height.equalTo(kCollectionViewHeight);
    }];
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * [self.gifts count], 0);
    
    for (int i = 0; i < [self.gifts count]; ++i) {
        UICollectionView *collectionView = [self createCollectionView];
        collectionView.dop_origin = CGPointMake(i * SCREEN_WIDTH, 0);
        collectionView.tag = i;
        [collectionView debugWithBorderColor:[UIColor greenColor] andBorderWidth:3];
        [self.scrollView addSubview:collectionView];
    }

    [self addSubview:self.pageIndicator];
    [self.pageIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollView);
        make.top.equalTo(self.scrollView.mas_bottom);
        make.height.equalTo(kPageControlHeight);
    }];
    
    [self addSubview:self.toolView];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(superView);
        make.top.equalTo(self.scrollView.mas_bottom);
    }];
    
    [self addSubview:self.comboButton];
    [self.comboButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(100, 100));
        make.right.equalTo(superView).offset(0);
        make.bottom.equalTo(superView).offset(0);
    }];
}

#pragma mark - Network Management -
/** 更新用户的钻石余额 */
- (void)requestForBalance {
    __weak typeof(self) wself = self;
    [[FBProfileNetWorkManager sharedInstance] loadProfitInfoSuccess:^(id result) {
        NSNumber *balance = result[@"account"][@"gold"];
        wself.balanceLabel.text = [NSString stringWithFormat:@"%@", balance];
        [[FBLoginInfoModel sharedInstance] setBalance:[balance integerValue]];
    } failure:^(NSString *errorString) {
        
    } finally:^{
        
    }];
}

#pragma mark - Event handler -
/** 添加定时器 */
- (void)addTimers {
    __weak typeof(self) wself = self;
    self.balanceTimer = [NSTimer bk_scheduledTimerWithTimeInterval:5 block:^(NSTimer *timer) {
        [wself requestForBalance];
    } repeats:YES];
}

/** 移除定时器 */
- (void)removeTimers {
    [self.balanceTimer invalidate];
    self.balanceTimer = nil;
    
    [self.comboTimer invalidate];
    self.comboTimer = nil;
}

/** 添加广播监听事件 */
- (void)addNotificationObservers {
    __weak typeof(self) wself = self;
    // 监听更新钻石余额的广播
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationUpdateBalance object:nil queue:nil usingBlock:^(NSNotification *note) {
        [wself requestForBalance];
    }];
}

- (void)removeNotifiationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onTouchButtonSend:(id)sender {
    //【礼物动画关键业务逻辑】用于测试，直接广播加载礼物动画，测试完记得删除
//    // 国际版
//#if TARGET_VERSION_ENTERPRISE
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGiftAnimationTest object:self.selectedGift];
//#else
    if ([self hasEnoughDiamond]) {
        if (self.doSendGiftAction) {
            self.doSendGiftAction(self.selectedGift);
        }
        //全屏礼物不能连发 且发送完隐藏礼物键盘
        if ([self.selectedGift.type isEqual:@(2)]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCloseGiftKeyboard object:nil];
        } else {
            self.sendButton.hidden = YES;
            self.comboButton.hidden = NO;
            [self resetComboButton];
        }

    } else {
        [self showAlertCharge];
    }
//#endif
}

- (void)onTouchButtonCombo:(id)sender {
    if ([self hasEnoughDiamond]) {
        if (self.doSendGiftAction) {
            self.doSendGiftAction(self.selectedGift);
        }
        if ([self.selectedGift.type isEqual:@(2)]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCloseGiftKeyboard object:nil];
        } else {
            [self.comboTimer invalidate];
            self.comboTimer = nil;
            [self resetComboButton];
        }
    } else {
        [self.comboTimer invalidate];
        self.comboTimer = nil;
        self.sendButton.hidden = NO;
        self.comboButton.hidden = YES;
        [self showAlertCharge];
    }
}

/** 重置连发按钮的计时 */
- (void)resetComboButton {
    if ([self.comboTimer isValid]) {
        [self.comboTimer invalidate];
        self.comboTimer = nil;
    }
    
    [self.comboButton setTitle:@"30" forState:UIControlStateNormal];
    self.comboButton.titleEdgeInsets = UIEdgeInsetsMake(20, 28, 0, 0);
    self.comboTimer = [NSTimer bk_scheduledTimerWithTimeInterval:3.6/30 block:^(NSTimer *timer) {
        NSInteger count = [[self.comboButton currentTitle] integerValue];
        if (count > 0) {
            count -= 1;
            [self.comboButton setTitle:[NSString stringWithFormat:@"%ld", (long)count] forState:UIControlStateNormal];
        } else {
            [self.comboTimer invalidate];
            self.comboTimer = nil;
            self.sendButton.hidden = NO;
            self.comboButton.hidden = YES;
        }
    } repeats:YES];
}

/** 重置发送按钮状态 */
- (void)resetSendButton {
    self.sendButton.hidden = NO;
    self.sendButton.enabled = NO;
    self.comboButton.hidden = YES;
    [self.comboTimer invalidate];
    self.comboTimer = nil;
}

/** 提示余额不足 */
- (void)showAlertCharge {
    __weak typeof(self) wself = self;
    [UIAlertView bk_showAlertViewWithTitle:nil message:kLocalizationDialogRechagreHint cancelButtonTitle:kLocalizationPublicCancel otherButtonTitles:@[kLocalizationPublicConfirm] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (wself.doPurchaseAction) {
                wself.doPurchaseAction();
            }
        }
    }];
}

- (void)deductBalance:(NSInteger)count {
    NSInteger balance = [[FBLoginInfoModel sharedInstance] balance];
    balance -= count;
    if (balance < 0) {
        balance = 0;
    }
    [[FBLoginInfoModel sharedInstance] setBalance:balance];
    self.balanceLabel.text = [NSString stringWithFormat:@"%ld", (long)balance];
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *array = self.gifts[collectionView.tag];
    return [array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FBGiftCell *cell = (FBGiftCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FBGiftCell class]) forIndexPath:indexPath];
    NSArray *array = self.gifts[collectionView.tag];
    FBGiftModel *model = array[indexPath.item];
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionView *selectedCollectionView = self.selectedMemo[kCollectionView];
    NSIndexPath *selectedIndexPath = self.selectedMemo[kIndexPath];
    if (selectedCollectionView) {
        // 选择同一页的礼物
        if (selectedCollectionView == collectionView) {
            // 再次点击选中的，则取消选择
            if ([selectedIndexPath compare:indexPath] == NSOrderedSame) {
                [selectedCollectionView deselectItemAtIndexPath:selectedIndexPath animated:NO];
                [self.selectedMemo removeAllObjects];
            } else {
                // 选择同一页的不同礼物
                self.selectedMemo[kIndexPath] = indexPath;
            }
        // 选择不同页的礼物
        } else {
            [selectedCollectionView deselectItemAtIndexPath:selectedIndexPath animated:NO];
            self.selectedMemo[kCollectionView] = collectionView;
            self.selectedMemo[kIndexPath] = indexPath;
        }
    } else {
        self.selectedMemo[kCollectionView] = collectionView;
        self.selectedMemo[kIndexPath] = indexPath;
    }
    
    if (self.selectedGift) {
        self.sendButton.enabled = YES;
    } else {
        [self resetSendButton];
    }
}

#pragma mark - Helper -
- (UICollectionView *)createCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = kCollectionViewCellSize;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kCollectionViewHeight) collectionViewLayout:layout];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollEnabled = NO;
    
    [collectionView registerClass:[FBGiftCell class] forCellWithReuseIdentifier:NSStringFromClass([FBGiftCell class])];
    return collectionView;
}


/** 钻石是否足够 */
- (BOOL)hasEnoughDiamond {
    if (self.selectedGift) {
        NSUInteger balance = [[FBLoginInfoModel sharedInstance] balance];
        if ([self.selectedGift.gold integerValue] <= balance) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - scrollViewDelegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageIndicator.currentPage = scrollView.contentOffset.x / SCREEN_WIDTH;
}

@end
