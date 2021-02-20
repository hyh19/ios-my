#import <MessageUI/MessageUI.h>
#import "ZWContactsViewController.h"
#import "ZWContactsCell.h"
#import "ABContact+NHZW.h"
#import "ABContactsHelper+NHZW.h"
#import "ZWContactsManager.h"
#import "UIActionSheet+Blocks.h"
#import "NSDate+Utilities.h"
#import "UIImageView+WebCache.h"
#import "ZWLoginViewController.h"
#import "ZWShareActivityView.h"
#import "ZWMyNetworkManager.h"

// 服务器返回的并友数据
#define kResponseFieldHeadURL  @"headUrl"     // 头像
#define kResponseFieldNickname @"nickName"    // 昵称
#define kResponseFieldMobile   @"phoneNumber" // 手机号码

/** 每次发送并友查询请求最多上传100个手机号码 */
const int maxMobileCount = 100;

@interface ZWContactsViewController () <MFMessageComposeViewControllerDelegate>

/** 通讯录联系人，不包括固话、小灵通联系人 */
@property (nonatomic, copy) NSArray *contactsArray;

/** 通讯录全部手机号码，排序与通讯录显示顺序一致 */
@property (nonatomic, copy) NSArray *mobileArray;

/** 通讯录联系人按姓名拼音分组数据 */
@property (nonatomic, strong) NSMutableArray *sectionsArray;

/** Table view 分组排序规则 */
@property (nonatomic, strong) UILocalizedIndexedCollation *collation;

/** 记录哪些Cell显示的联系人是并友 */
@property (nonatomic, strong) NSMutableDictionary *bingFriendsCellMemo;

/** 向服务器发送查询并友请求需要上传的手机号码数据，服务器请求上限是100个 */
@property (nonatomic, strong) NSMutableDictionary *bingFriendsRequestData;

/** tableview Header View*/
@property (strong, nonatomic) IBOutlet UIView *tableviewHeader;

@end

@implementation ZWContactsViewController

#pragma mark - Getter & Setter -
- (NSArray *)mobileArray {
    
    if (!_mobileArray) {
        
        NSMutableArray *theMobileArray = [NSMutableArray array];
        
        // 读取按姓名拼音分组的联系人
        for (NSArray *contactsInSection in self.sectionsArray) {
            
            // 读取联系人手机号码，每个联系人可以有多个号码
            for (ABContact *contact in contactsInSection) {
                [theMobileArray addObjectsFromArray:contact.mobileArray];
            }
        }
        _mobileArray = theMobileArray;
    }
    
    return _mobileArray;
}

/**
 *  字典的数据格式如下（字典查询键是各分组的第一个手机号码）：
 *  @{ @"18612345678": @[@"18612345678", @"13512345678", ..., @"13412345678"],
 *     @"15912345678": @[@"15912345678", @"13512387942", ..., @"13412328374"],
 *     ...
 *     @"13712345678": @[@"13712345678", @"13512389834", ..., @"13412373645"]
 *   }
 */
- (NSMutableDictionary *)bingFriendsRequestData {
    if (!_bingFriendsRequestData) {
        _bingFriendsRequestData = [[NSMutableDictionary alloc] init];
    }
    return _bingFriendsRequestData;
}

- (NSMutableDictionary *)bingFriendsCellMemo {
    if (!_bingFriendsCellMemo) {
        _bingFriendsCellMemo = [[NSMutableDictionary alloc] init];
    }
    return _bingFriendsCellMemo;
}

- (void)setContactsArray:(NSArray *)contactsArray {
    
    if (contactsArray != _contactsArray) {
        
        _contactsArray = [contactsArray copy];
        
        if (_contactsArray == nil) {
            
            self.sectionsArray = nil;
            
        } else {
            // 对联系人按姓名拼音进行分组
            [self configureSections];
        }
    }
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureUserInterface];
    
    // 配置联系人分组，按姓名拼音进行分组
    [self setContactsArray:[ABContactsHelper mobileContacts]];
    
    // 配置发送网络请求查询并友需要上传到服务器的手机号码
    [self configureBingFriendRequestData];
    
    // 进入通讯录界面，马上发送第一组手机号码到服务器请求查询并友
    if ([self.mobileArray count] > 0) {
        
        // 读取第一个手机号码，该手机号码是第一组手机号码的字典查询键
        NSString *key = [self.mobileArray firstObject];
        
        if (key) {
            
            // 第一组手机号码
            NSArray *firstGroup = self.bingFriendsRequestData[key];
            
            // 发送网络请求查询并友
            [self sendRequestForLoadingBingFriendsWithMobiles:firstGroup];
            
            // 不管网络请求成功与否，都把该分组删掉，因为每次进入该界面都会发送请求，所以，即
            // 使失败了，也将会在下次进入时重新发送。
            [self.bingFriendsRequestData removeObjectForKey:key];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 通讯录并友页：页面显示
    [MobClick event:@"address_list_page_show"];
}

#pragma mark - Event handler -
/** 发送手机短信 */
- (void)sendSMSToMobile:(NSString *)mobile {
    
    // 判断设备是否支持发送短信
    if ([MFMessageComposeViewController canSendText]) {
        
        // 创建发送短信的系统界面
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        
        picker.messageComposeDelegate = self;
        
        picker.navigationBar.tintColor = [UIColor whiteColor];
        
        picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        
        // 接收短信的手机号码
        picker.recipients = [NSArray arrayWithObject:mobile];
        
        // 邀请码
        NSString *code = [[ZWUserInfoModel sharedInstance] myCode];
        
        // 短信内容
        picker.body = [NSString shareMessageForSMSWithInvitationCode:code];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

/** 判断用户点击的是哪一个联系人的邀请按钮 */
- (void)checkButtonTapped:(id)sender event:(id)event {
    
    NSSet *touches = [event allTouches];
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    
    if (indexPath != nil){
        // 触发邀请按钮事件，发送邀请短信
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

/** 用户点击的邀请分享按钮 */
- (IBAction)friendFromShare:(id)sender {
    [self getRecommend];
}

/** 登录按钮触发的事件 */
- (IBAction)login:(id)sender
{
    if(![ZWUserInfoModel login])
    {
        ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
        [self.navigationController pushViewController:loginView animated:YES];
    }
}

#pragma mark - Network management -
/**
 *  发送获取并友请求
 *  @param numbers 手机号码数组，服务器最多查询100个
 */
- (void)sendRequestForLoadingBingFriendsWithMobiles:(NSArray *)mobiles {
    
    [[ZWContactsManager sharedInstance] loadBingFriendsWithUserId:[ZWUserInfoModel userID]
                                                    mobileNumbers:mobiles
                                                          isCache:NO
                                                           succed:^(id result) {
                                                               // 请求成功，记录服务器返回的并友数据
                                                               NSArray *body = (NSArray *)result;
                                                               [self addNewBingFriends:body];
                                                           }
                                                           failed:^(NSString *errorString) {
                                                               ZWLog(@"[errorString] %@", errorString);
                                                           }];
    
}

/**
 *  配置查询并友的数据，发送最多100个手机号码到服务器查询哪些联系人是并友，并友指的是并读新闻的
 *  注册用户
 */
- (void)configureBingFriendRequestData {
    
    // 对全部手机号码进行分组，每组100个
    for (int i = 0; i < [self.mobileArray count]; ++i) {
        
        if (i % maxMobileCount == 0) {
            
            // 每组的第一个手机号码作为该组的字典查询键
            NSString *key = self.mobileArray[i];
            
            NSRange range;
            range.location = i;
            
            if ((i+maxMobileCount) < [self.mobileArray count]) {
                // 100个手机号码作为一组
                range.length = maxMobileCount;
            } else {
                // 剩余的最后不足100个手机号码作为最后一组
                range.length = [self.mobileArray count] - i;
            }
            
            NSArray *obj = [self.mobileArray subarrayWithRange:range];
            
            [self.bingFriendsRequestData safe_setObject:obj forKey:key];
        }
    }
}

/**
 *  处理服务器返回的并友数据，记录哪些联系人已经是并友
 *  @param friends 服务器返回的并友数据
 */
- (void)addNewBingFriends:(NSArray *)friends {
    
    for (NSDictionary *obj in friends) {
        
        // 用手机号作为字典查询键，使得不同联系人有相同的手机号码也能识别为并友
        NSString *mobile = obj[kResponseFieldMobile];
        
        NSArray *array = [ABContactsHelper contactsMatchingMobile:mobile];
        
        if ([array count] > 0) {
            // 记录该手机号码所属的联系人已经是并友
            [self.bingFriendsCellMemo safe_setObject:obj forKey:mobile];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - UI management -
- (void)configureUserInterface {
    [self.tableView setSectionIndexColor:COLOR_333333];
    [self.tableView setBackgroundColor:COLOR_F2F2F2];
    self.tableviewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, 56);
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    // UI要求去掉导航栏下的边界黑线
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
}

#pragma mark - Data management -
/** 配置Table view cell的数据和外观 */
- (void)configureCell:(ZWContactsCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *contactsInSection = (self.sectionsArray)[indexPath.section];
    
    ABContact *contact = contactsInSection[indexPath.row];
    
    // 联系人姓名
    NSString *name = contact.name;
    
    // 联系人手机号码
    NSString *mobile = contact.mobileNumbers;
    
    // 邀请按钮
    [cell.inviteButton addTarget:self action:@selector(checkButtonTapped:event:)
                forControlEvents:UIControlEventTouchUpInside];
    
    id obj = nil;
    
    // 用手机号码作为字典查询键，使得不同联系人即使有相同的手机号码也能识别为并友
    for (NSString *mobile in [contact mobileArray]) {
        if (self.bingFriendsCellMemo[mobile]) {
            obj = self.bingFriendsCellMemo[mobile];
        }
    }
    
    if (!obj) { // 联系人不是并友，显示邀请按钮
        
        // 姓名
        cell.nameLabel.text = name;
        
        // 手机号码
        cell.mobileLabel.text = mobile;
        
        // 默认头像
        cell.avatarImageView.image = [UIImage imageNamed:@"icon_default_head"];
        
        // 邀请按钮
        [cell.inviteButton setBackgroundColor:COLOR_00BAA2];
        [cell.inviteButton setEnabled:YES];
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"邀请" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [cell.inviteButton setAttributedTitle:title forState:UIControlStateNormal];
        
    } else { // 联系人已经是并友，不显示邀请按钮
        
        // 姓名
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ (%@)", name, obj[kResponseFieldNickname]];
        
        // 手机号码
        cell.mobileLabel.text = mobile;
        
        // 用户头像
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:obj[kResponseFieldHeadURL]] placeholderImage:[UIImage imageNamed:@"icon_avatar_contact"]];
        
        // “已是并友”提示
        [cell.inviteButton setBackgroundColor:[UIColor clearColor]];
        [cell.inviteButton setEnabled:NO];
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"已是并友" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:COLOR_848484}];
        [cell.inviteButton setAttributedTitle:title forState:UIControlStateNormal];
    }
}

/** 配置通讯录联系人分组，按姓名拼音分组 */
- (void)configureSections {
    
    // 以下代码参考苹果官方例子
    
    // Get the current collation and keep a reference to it.
    self.collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger index, sectionTitlesCount = [[self.collation sectionTitles] count];
    
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    for (index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray safe_addObject:array];
    }
    
    for (ABContact *contact in self.contactsArray) {
        
        NSInteger sectionNumber = [self.collation sectionForObject:contact collationStringSelector:@selector(name)];
        
        // Get the array for the section.
        NSMutableArray *sectionContacts = newSectionsArray[sectionNumber];
        
        [sectionContacts safe_addObject:contact];
    }
    
    // Now that all the data's in place, each section array needs to be sorted.
    for (index = 0; index < sectionTitlesCount; index++) {
        
        NSMutableArray *contactsArrayForSection = newSectionsArray[index];
        
        // If the table view or its contents were editable, you would make a mutable copy here.
        NSArray *sortedContactsArrayForSection = [self.collation sortedArrayFromArray:contactsArrayForSection collationStringSelector:@selector(name)];
        
        // Replace the existing array with the sorted array.
        newSectionsArray[index] = sortedContactsArrayForSection;
    }
    
    self.sectionsArray = newSectionsArray;
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.collation sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *contactsInSection = (self.sectionsArray)[section];
    
    return [contactsInSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZWContactsCell *cell = (ZWContactsCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWContactsCell class]) forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.collation sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    return [self.collation sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - UITableViewDelegate -
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 22.0f)];
    headerView.backgroundColor = COLOR_F2F2F2;
    
    // 分区的字母标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 100, 23.0)];
    titleLabel.font = [UIFont systemFontOfSize:13.0f];
    titleLabel.textColor = COLOR_666666;
    titleLabel.text = [self.collation sectionTitles][section];
    [headerView addSubview:titleLabel];
    
    // UI要求headerView下的一条线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 22.5, SCREEN_WIDTH, 0.5)];
    bottomLine.backgroundColor = COLOR_E7E7E7;
    [headerView addSubview:bottomLine];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSArray *contactsInSection = (self.sectionsArray)[section];
    if ([contactsInSection count] > 0) {
        return 23.0f;
    }
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    // 点击邀请按钮后发送邀请短信
    
    NSArray *contactsInSection = (self.sectionsArray)[indexPath.section];
    
    ABContact *contact = contactsInSection[indexPath.row];
    
    NSArray *mobileArray = [contact mobileArray];
    
    // 如果联系人有多个手机号码，则弹出菜单让用户选择要发送到哪个号码，否则直接发送
    if ([mobileArray count]>1) {
        
        [UIActionSheet presentOnView:self.view
                           withTitle:nil
                        otherButtons:mobileArray
                            onCancel:^(UIActionSheet *actionSheet) {}
                     onClickedButton:^(UIActionSheet *actionSheet, NSUInteger index) {
                         [self sendSMSToMobile:mobileArray[index]];
                     }];
        
    } else {
        
        [self sendSMSToMobile:mobileArray[0]];
    }
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 向下滑动Table view的时候，检查是否达到下一组手机号码的临界值，每组100个
    NSArray *indexPathArray = [self.tableView indexPathsForVisibleRows];
    
    // 遍历当前屏幕可见的联系人手机号码，如果手机号码是分组数据的字典查询键，则发送获取并友请求
    for (NSIndexPath *indexPath in indexPathArray) {
        
        NSArray *contactsInSection = (self.sectionsArray)[indexPath.section];
        
        ABContact *contact = contactsInSection[indexPath.row];
        
        // 遍历联系人的全部手机号码
        for (NSString *mobile in [contact mobileArray]) {
            
            NSArray* numbers = (NSArray *)self.bingFriendsRequestData[mobile];
            
            // 手机号码分组不为空，则发送查询并友请求
            if (numbers) {
                
                // 上传手机号码，发送查询并友请求
                [self sendRequestForLoadingBingFriendsWithMobiles:numbers];
                
                // 删除该组手机号码，不管请求成功与否
                [self.bingFriendsRequestData removeObjectForKey:mobile];
            }
        }
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate -
// 发送短信界面的回调函数
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    switch (result) {
            // 取消发送短信
        case MessageComposeResultCancelled:
            break;
            
            // 发送短信成功
        case MessageComposeResultSent: {
            // 通讯录并友页：短信邀请
            [MobClick event:@"invite_message_address_list_page"];
            break;
        }
            // 发送短信失败
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - helper -
/** 获取邀请码 */
- (void)getRecommend
{
    if(![ZWUserInfoModel login])
    {
        [self hint:@"您还没有登录，不能邀请好友。是否立即登录邀请好友?"
         trueTitle:@"登录"
         trueBlock:^{
             [self login:nil];
         }
       cancelTitle:@"暂不"
       cancelBlock:^{
       }];
    }
    else
    {
        [self share:[ZWUserInfoModel sharedInstance].myCode];
    }
}

/** 分享给好友 */
- (void)share:(NSString *)recommendCode
{
    NSString *title = [NSString stringWithFormat:@"邀请码【%@】。下载并读，体验我的精致生活", recommendCode];
    
    [[ZWShareActivityView alloc]
     initQrcodeShareViewWithTitle:title
     content:[NSString shareMessageForSNSWithInvitationCode:recommendCode]
         SMS:[NSString shareMessageForSMSWithInvitationCode:recommendCode]
       image:[UIImage imageNamed:@"logo"]
         url:[NSString stringWithFormat:@"%@/share/app?uid=%@", BASE_URL, [ZWUserInfoModel userID]]
    mobClick:@"_friends_page"
      markSF:YES
 shareResult:^(SSDKResponseState state,
               SSDKPlatformType type,
               NSDictionary *userData,
               SSDKContentEntity *contentEntity,
               NSError *error) {
     if (state == SSDKResponseStateSuccess) {
         occasionalHint(@"分享成功");
         [[ZWMyNetworkManager sharedInstance] recommendDownload];
     }
     else if (state == SSDKResponseStateFail ||
              state == SSDKResponseStateCancel ||
              (type == SSDKPlatformTypeUnknown &&
               state == SSDKResponseStateSuccess) ||
              type == SSDKPlatformTypeUnknown) {
         //
     }
     //复制链接
     else if (state==SSDKResponseStateBegin && type==SSDKPlatformTypeCopy) {
         //
     }
 }];
}

@end
