#import "ZWChannelScrollView.h"
#import "GMGridView.h"
#import "RTLabel.h"
#import "ZWNewsListViewController.h"
#import "SCNavTabBar.h"
#import "ChannelItem.h"
#import "ZWUnSelectedChannelDataSource.h"
#import "ZWChannelDataSource.h"
#import "ZWChannelDataManager.h"
#import "ZWGlobalConfigurationManager.h"
#import "ZWTabBarController.h"
#import "AppDelegate.h"

@interface ZWChannelScrollView () <ChannelDataSourceDelegate, UnSelectedChannelDataSourceDelegate>

/**未选频道数据源*/
@property (nonatomic, strong) ZWUnSelectedChannelDataSource *unSelectedChannelDataSource;

/**未选频道顶部视图*/
@property (nonatomic, strong) UIView *unSelectHeadView;

/**已选频道视图*/
@property (nonatomic, strong) GMGridView *gmGridView;

/**未选频道视图*/
@property (nonatomic, strong) GMGridView *unSelectGmGridView;

/**收起按钮*/
@property (nonatomic, strong) UIButton *dismissButton;

/**完成按钮*/
@property (nonatomic, strong) UIButton *completeButton;

/**已选频道数据源*/
@property (nonatomic, strong) ZWChannelDataSource *channelDataSource;

/**是否已经展开频道列表*/
@property (nonatomic, assign) BOOL isOpenMenu;

@end

@implementation ZWChannelScrollView

#define UNSELECTCHANNELLIST [[ZWChannelDataManager sharedInstance] unSelectedChannelList]
#define SELECTCHANNELLIST [[ZWChannelDataManager sharedInstance] selectedChannelList]

#pragma mark - init
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNotificationHideChannelMenu)
                                                     name:kNotificationHideChannelMenu
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationHideChannelMenu object:nil];
}

#pragma mark - Event handler -
- (void)onTouchButtonHideChannelMenu {
    if (_isOpenMenu) {
        [self hideChannelMenu];
    }
}

- (void)hideChannelMenu {
    
    [[[self mainSuperView].view viewWithTag:8888] removeFromSuperview];
    [[self dismissButton] removeFromSuperview];
    [self.layer removeAllAnimations];
    
    // 显示标签栏
    [[AppDelegate tabBarController] showTabBarAnimated:YES WithDuration:0.25];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, -SCREEN_HEIGH, SCREEN_WIDTH, SCREEN_HEIGH);
    } completion:^(BOOL finished) {
        [[self unSelectGmGridView] removeFromSuperview];
        [self removeFromSuperview];
        _isOpenMenu = NO;
    }];
    
    //判断频道内容有没有变
    NSArray *oldTitles = [self mainSuperView].navTabBar.itemTitles;
    if(oldTitles.count == SELECTCHANNELLIST.count && SELECTCHANNELLIST.count != 0)
    {
        BOOL isDifferent = NO;
        int i = 0;
        for(NSString *titles in oldTitles)
        {
            if(![[titles stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] isEqualToString:SELECTCHANNELLIST[i]])
            {
                isDifferent = YES;
                break;
            }
            i++;
        }
        if(isDifferent == NO)
        {
            return ;
        }
    }
    /////////////////////////////////////////////////////
    [[self mainSuperView].view removeFromSuperview];
    if(SELECTCHANNELLIST.count > 0)
    {
        [self updataLocalChannelSort];
        [[self mainViewController] updataNewsViewControllers:SELECTCHANNELLIST];
        [((ZWNewsListViewController *)[self mainSuperView].subViewControllers[0]) reloadData];
    }
    //更新本地缓存的自定义频道列表数据
    [[ZWChannelDataManager sharedInstance] updataLocalChannelList];
    //上传自定义接口
    if ([ZWUserInfoModel userID]) {
        [[ZWChannelDataManager sharedInstance] uploadCustomChannelList];
    }
}

- (void)onTouchButtonShowChannelMenu {
    if (!_isOpenMenu) {
        [self showChannelMenu];
    } else {
        [self removeFromSuperview];
    }
}

- (void)showChannelMenu {
    // 新闻列表页：展开频道列表
    [MobClick event:@"show_channel_list"];
    [[self channelDataSource] setDataSource:SELECTCHANNELLIST];
    [[self unSelectedChannelDataSource] setDataSource:UNSELECTCHANNELLIST];
    [[self gmGridView] setDataSource:[self channelDataSource]];
    [[self gmGridView] reloadData];
    [[self unSelectGmGridView] setDataSource:[self unSelectedChannelDataSource]];
    [[self unSelectGmGridView] reloadData];
    [self addGirdView];
    
    UIView *titlelabel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ARROW_BUTTON_WIDTH)];
    titlelabel.backgroundColor = COLOR_FFFFFF;
    RTLabel *detaillabel = [[RTLabel alloc]initWithFrame:CGRectMake(15, 10, 200, ARROW_BUTTON_WIDTH)];
    detaillabel.text = @"<font color='#666666'>我的频道</font><font color='#666666' size='9'>     长按排序或删除</font>";
    [titlelabel addSubview:detaillabel];
    titlelabel.tag = 8888;
    [[self mainSuperView].view addSubview:titlelabel];
    [[self mainSuperView].view addSubview:[self dismissButton]];
    
    // 隐藏标签栏
    [[AppDelegate tabBarController] hideTabBarAnimated:YES WithDuration:0.5];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, ARROW_BUTTON_WIDTH, SCREEN_WIDTH, SCREEN_HEIGH - ARROW_BUTTON_WIDTH);
    } completion:^(BOOL finished) {
        _isOpenMenu = YES;
    }];
    //添加到select list
    __block NSMutableArray *weakcurrentData = SELECTCHANNELLIST;
    __block GMGridView *weakgmGridView = [self gmGridView];
    __block GMGridView *weakunselegmGridView = [self unSelectGmGridView];
    __block NSMutableArray *weakUnselectarray = UNSELECTCHANNELLIST;
    __weak typeof(self) weakSelf=self;
    
    //添加到unselect list
    [self gmGridView].delchannel = ^(NSInteger index){
        [weakUnselectarray safe_addObject:[weakcurrentData objectAtIndex:index]];
        [[ZWChannelDataManager sharedInstance] updataLocalChannelSelectedState:NO channelName:[weakcurrentData objectAtIndex:index]];
        [weakunselegmGridView insertObjectAtIndex:[weakUnselectarray count] -1 withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
        [weakcurrentData removeObjectAtIndex:index];
        [weakgmGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
        [weakSelf performSelector:@selector(updataUI) withObject:nil afterDelay:0.3];
    };
    
    __block SCNavTabBarController *weakself = [self mainSuperView];
    __block UIButton *weakcompleteButton = [self completeButton];
    __block UIButton *dismissBtn = [self dismissButton];
    
    [self gmGridView].completeButton = ^(){
        [weakself.view addSubview:weakcompleteButton];
        [weakcompleteButton addTarget:weakSelf action:@selector(onTouchButtonFinishMoveMenu) forControlEvents:UIControlEventTouchUpInside];
        dismissBtn.enabled = NO;
    };
}

- (void)onNotificationHideChannelMenu {
    [self hideChannelMenu];
    [self onTouchButtonFinishMoveMenu];
}

/**点击完成按钮触发方法*/
-(void)onTouchButtonFinishMoveMenu{
    [[self gmGridView] setEditing:NO animated:NO];
    [self dismissButton].enabled = YES;
    [[self completeButton] removeFromSuperview];
    [self updataUI];
}
/**更新本地频道的位置序号*/
- (void)updataLocalChannelSort
{
    if([[NSUserDefaults loadValueForKey:LOCALCHANNEL] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *channel = [NSUserDefaults loadValueForKey:LOCALCHANNEL];
        
        if([channel[@"isSelect"] boolValue] == YES)
        {
            NSInteger position = [SELECTCHANNELLIST indexOfObject:channel[@"name"]];
            
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:channel];
            
            [tempDict safe_setObject:@(position) forKey:@"sort"];
            
            [NSUserDefaults saveValue:[tempDict copy] ForKey:LOCALCHANNEL];
        }
    }
}

#pragma mark - Properties
/**添加已选频道列表和未选频道列表*/
-(void)addGirdView{
    self.frame = CGRectMake(0, -SCREEN_HEIGH, SCREEN_WIDTH, SCREEN_HEIGH);
    [self gmGridView].frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH);
    [[self gmGridView] removeFromSuperview];
    [self addSubview:[self gmGridView]];
    
    //未选择项
    RTLabel *headdetaillabel = [[RTLabel alloc]initWithFrame:CGRectMake(15, 10, 200, ARROW_BUTTON_WIDTH)];
    headdetaillabel.text = @"<font color='#666666'>添加频道</font>";
    [[self unSelectHeadView] addSubview:headdetaillabel];
    
    [self updataUI];
    
    [self  addSubview:[self unSelectHeadView]];
    [self  addSubview:[self unSelectGmGridView]];
}
/**跳转到选定的频道*/
- (void)jumpToSelectChannel:(NSNumber *)itemIndex
{
    [[self mainSuperView] channelChangeAtIndex:[itemIndex integerValue]];
}
/**更新频道视图UI*/
- (void)updataUI
{
    NSInteger selectChannelLines = SELECTCHANNELLIST.count/3;
    
    if(SELECTCHANNELLIST.count%3 > 0)
    {
        selectChannelLines++;
    }
    
    [self gmGridView].frame = CGRectMake(0, 0 , SCREEN_WIDTH,  selectChannelLines * 44 + 44);
    [self gmGridView].contentOffset = CGPointMake(0, 0);
    
    NSInteger unSelectChannelLines = UNSELECTCHANNELLIST.count/3;
    
    if(UNSELECTCHANNELLIST.count%3 > 0)
    {
        unSelectChannelLines++;
    }

    [self unSelectHeadView].frame = CGRectMake(0, selectChannelLines * 44+44, SCREEN_WIDTH, ARROW_BUTTON_WIDTH);
    
    [self unSelectGmGridView].frame = CGRectMake(0, [self unSelectHeadView].frame.origin.y + [self unSelectHeadView].frame.size.height, SCREEN_WIDTH,  unSelectChannelLines * 44);
    
    self.contentSize = CGSizeMake(0, [self unSelectGmGridView].frame.origin.y + [self unSelectGmGridView].frame.size.height + 120);
}

#pragma mark - channelDataSource delegate
- (void)dataSource:(ZWChannelDataSource *)channelDataSource didTapOnItemTitle:(NSString *)itemTitle
{
    NSInteger itemIndex = [SELECTCHANNELLIST indexOfObject:itemTitle];
    if([SELECTCHANNELLIST containsObject:itemTitle] && itemIndex<SELECTCHANNELLIST.count)
    {
        [self onTouchButtonFinishMoveMenu];
        [self onTouchButtonHideChannelMenu];
        [self performSelector:@selector(jumpToSelectChannel:) withObject:@(itemIndex) afterDelay:0.1];
    }
}

#pragma mark - unSelectedChannelDataSource delegate
- (void)channelDataSource:(ZWUnSelectedChannelDataSource *)channelDataSource didTapOnItemTitle:(NSString *)itemTitle
{
    //添加到select list
    if (SELECTCHANNELLIST.count < 15) {
        [SELECTCHANNELLIST safe_addObject:itemTitle];
        [[ZWChannelDataManager sharedInstance] updataLocalChannelSelectedState:YES channelName:itemTitle];
        [[self gmGridView] insertObjectAtIndex:[SELECTCHANNELLIST count] - 1
                                 withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
        [[self unSelectGmGridView] reloadData];
        [UNSELECTCHANNELLIST removeObject:itemTitle];
        [[self unSelectGmGridView] reloadData];
    }else{
        occasionalHint(@"您的订阅频道已到达到上限！");
    }
    [self updataUI];
}

#pragma mark - Getter & Setter

- (UIButton *)dismissButton
{
    if(!_dismissButton)
    {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - ARROW_BUTTON_WIDTH, 0, ARROW_BUTTON_WIDTH, ARROW_BUTTON_WIDTH)];
        [_dismissButton setImage:[UIImage imageNamed:@"common_channelbar"] forState:UIControlStateNormal];
        _dismissButton.transform = CGAffineTransformMakeRotation((M_PI*(-180)/180.0));
        [_dismissButton addTarget:self action:@selector(onTouchButtonHideChannelMenu) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

- (UIButton *)completeButton
{
    if(!_completeButton)
    {
        _completeButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 5, 50, 25)];
        _completeButton.backgroundColor = [UIColor whiteColor];
        _completeButton.layer.borderWidth = 0.5;
        _completeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_completeButton setTitle:@"完成" forState:UIControlStateNormal];
        _completeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_completeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _completeButton.layer.cornerRadius = 2;
    }
    return _completeButton;
}

- (GMGridView *)gmGridView
{
    if(!_gmGridView)
    {
        _gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _gmGridView.backgroundColor = COLOR_F8F8F8;
        _gmGridView.style = GMGridViewStylePush;
        _gmGridView.itemSpacing = 10;
        _gmGridView.minEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _gmGridView.centerGrid = NO;
        _gmGridView.actionDelegate = [self channelDataSource];
        _gmGridView.sortingDelegate = [self channelDataSource];
        _gmGridView.dataSource = [self channelDataSource];
        _gmGridView.mainSuperView = self;
        _gmGridView.enableEditOnLongPress = YES;
        _gmGridView.disableEditOnEmptySpaceTap = NO;
        _gmGridView.scrollEnabled = NO;
    }
    return _gmGridView;
}

- (GMGridView *)unSelectGmGridView
{
    if(!_unSelectGmGridView)
    {
        _unSelectGmGridView = [[GMGridView alloc] init];
        _unSelectGmGridView.backgroundColor = [UIColor whiteColor];
        _unSelectGmGridView.style = GMGridViewStylePush;
        _unSelectGmGridView.itemSpacing = 10;
        _unSelectGmGridView.enableEditOnLongPress = YES;
        _unSelectGmGridView.minEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _unSelectGmGridView.centerGrid = NO;
        _unSelectGmGridView.scrollEnabled = NO;
        _unSelectGmGridView.actionDelegate = [self unSelectedChannelDataSource];
        _unSelectGmGridView.mainSuperView = self;
    }
    return _unSelectGmGridView;
}

- (ZWUnSelectedChannelDataSource *)unSelectedChannelDataSource
{
    if(!_unSelectedChannelDataSource)
    {
        _unSelectedChannelDataSource = [[ZWUnSelectedChannelDataSource alloc]init];
        _unSelectedChannelDataSource.delegate = self;
    }
    return _unSelectedChannelDataSource;
}

- (UIView *)unSelectHeadView
{
    if(!_unSelectHeadView)
    {
        _unSelectHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ARROW_BUTTON_WIDTH)];
        _unSelectHeadView.backgroundColor = [UIColor whiteColor];
    }
    return _unSelectHeadView;
}

- (ZWChannelDataSource *)channelDataSource
{
    if(!_channelDataSource)
    {
        _channelDataSource = [[ZWChannelDataSource alloc] init];
        _channelDataSource.delegate = self;
    }
    return _channelDataSource;
}

- (void)setMainSuperView:(SCNavTabBarController *)mainSuperView
{
    _mainSuperView = mainSuperView;
}
- (void)setMainViewController:(ZWNewsMainViewController *)mainViewController{
    _mainViewController = mainViewController;
}

@end
