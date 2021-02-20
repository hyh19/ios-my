#import "ZWChannelDataManager.h"
#import "ChannelItem.h"
#import "AppDelegate.h"
#import "ZWChannelModel.h"
#import "ZWUpdateChannel.h"
#import "ZWLocationManager.h"
#import "ZWNewsNetworkManager.h"
#import "ZWVersionManager.h"
#import "NSDate+NHZW.h"
#import "UIViewController+NHZW.h"
#import "ZWRedPointManager.h"

@interface ZWChannelDataManager()

@property (nonatomic, assign) BOOL hasCheckedVersion; // 是否已经加载过更新检测接口

@end

@implementation ZWChannelDataManager

- (NSMutableArray *)selectedChannelList
{
    if(!_selectedChannelList)
    {
        _selectedChannelList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedChannelList;
}

- (NSMutableArray *)unSelectedChannelList
{
    if(!_unSelectedChannelList)
    {
        _unSelectedChannelList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _unSelectedChannelList;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZWChannelDataManager *_channelDataManager;
    dispatch_once(&onceToken, ^{
        _channelDataManager = [[ZWChannelDataManager alloc] init];
    });
    
    return _channelDataManager;
}

//刷新本地频道
-(void)refreshLocalChannelWithSuccess:(void (^)())success{
    if ([ZWLocationManager city]) {
        
        [self loadLocalChannel:[ZWLocationManager city] success:^{
            success();
        }];
        
    } else {
        
        [ZWLocationManager updateLocationWithSuccess:^{
            [self loadLocalChannel:[ZWLocationManager city] success:^{
                    success();
            }];
        } failure:nil];
    }
}

- (void)loadLocalChannel:(NSString *)city
                  success:(void (^)())success
{
    [[ZWNewsNetworkManager sharedInstance] loadLocalChannelWithLocation:[city stringByReplacingOccurrencesOfString:@"市" withString:@""] succed:^(id result) {
        
        if(result && [result count] > 0)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:result[0]];
            
            if([[NSUserDefaults loadValueForKey:LOCALCHANNEL defaultValue:@""] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *channel = [NSUserDefaults loadValueForKey:LOCALCHANNEL];
                
                if([channel[@"name"] isEqualToString:dic[@"name"]])
                    return ;
            }
            
            [dic safe_setObject:[NSNumber numberWithBool:YES] forKey:@"isSelect"];
            
            [NSUserDefaults saveValue:[dic copy] ForKey:LOCALCHANNEL];
            
            if(![[self selectedChannelList] containsObject:dic[@"name"]] || ![[self unSelectedChannelList] containsObject:dic[@"name"]])
            {
                [self addLocalChannel];
                success();
            }
        }
        else {
            
            [NSUserDefaults saveValue:@"" ForKey:LOCALCHANNEL];
        }
        
    } failed:^(NSString *errorString) {
    }];
}

//加载用户自定义的本地频道ID列表
- (NSArray *)localChannelDataWithDataSource:(NSArray *)dataSource
{
    NSArray *localChannelIDs = [NSArray arrayWithObjects:@"",nil];
    
    if(![ZWUserInfoModel login])//未登录用户
    {
        localChannelIDs = [[NSUserDefaults standardUserDefaults] objectForKey:@"logoutChannelID"];//获取本地未登录用户的频道ID
    }
    else//登录用户
    {
        localChannelIDs = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginChannelID"];//获取本地该登录用户的频道ID
    }
    if(localChannelIDs.count > 0)
    {
        NSMutableArray *localChannels = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSNumber *channelID in localChannelIDs)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelID == %@", channelID];
            NSArray *filteredArray = [dataSource filteredArrayUsingPredicate:predicate];
            if(filteredArray.count > 0)
            {
                [localChannels addObjectsFromArray:filteredArray];
            }
        }
        // 更新本地存储频道ID
        [self saveChannelData:localChannels];
        return [localChannels copy];
    }
    return nil;
}

//存储用户自定义的频道ID
- (void)saveChannelData:(NSArray *)dataSource
{
    if(dataSource && dataSource.count > 0)
    {
        NSMutableArray *updataChannelIDs = [[NSMutableArray alloc] initWithCapacity:0];
        
        for(ZWChannelModel *tmp in dataSource)
        {
            [updataChannelIDs safe_addObject:tmp.channelID];
        }
        
        if(![ZWUserInfoModel login])
        {
            [[NSUserDefaults standardUserDefaults] setObject:[updataChannelIDs copy] forKey:@"logoutChannelID"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[updataChannelIDs copy] forKey:@"loginChannelID"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)filterChannelData:(NSArray *)dataSource
{
    NSArray *localChannels = [self localChannelDataWithDataSource:dataSource];
    
    [[self selectedChannelList] removeAllObjects];
    
    [[self unSelectedChannelList] removeAllObjects];
    
    if(localChannels && localChannels.count > 0)
    {
        for (ZWChannelModel *tmp in dataSource) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelID == %@", tmp.channelID];
            
            NSArray *filteredArray = [localChannels filteredArrayUsingPredicate:predicate];
            
            if(filteredArray.count == 0)
            {
                [[self unSelectedChannelList] safe_addObject:tmp.channelName];
            }
            else
            {
                [[self selectedChannelList] safe_addObject:tmp.channelName];
            }
        }
    }
    else
    {
        for (ZWChannelModel *tmp in dataSource) {
            if ([tmp.isSelected boolValue] == 1)
            {
                [[self selectedChannelList] safe_addObject:tmp.channelName];
            }
            else
            {
                [[self unSelectedChannelList] safe_addObject:tmp.channelName];
            }
        }
        // 更新本地存储频道ID
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == 1"];
        
        [self saveChannelData:[dataSource filteredArrayUsingPredicate:predicate]];
    }
}

////添加缓存的地方频道
- (void)addLocalChannel
{
    if([[NSUserDefaults loadValueForKey:LOCALCHANNEL] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *channel = [NSUserDefaults loadValueForKey:LOCALCHANNEL];
        
        if([channel[@"isSelect"] boolValue] == YES)
        {
            if(![[self selectedChannelList] containsObject:channel[@"name"]])
            {
                //根据本地频道的位置序号插入到相应的位置
                if([[channel allKeys] containsObject:@"sort"] && [self selectedChannelList].count-1 > [channel[@"sort"] integerValue] && [channel[@"sort"] integerValue] > 0)
                {
                    [[self selectedChannelList] insertObject:channel[@"name"] atIndex:[channel[@"sort"] integerValue]];
                }
                else
                {
                    [[self selectedChannelList] safe_addObject:channel[@"name"]];
                }
                if([[self unSelectedChannelList] containsObject:channel[@"name"]])
                {
                    [[self unSelectedChannelList] removeObject:channel[@"name"]];
                }
            }
        }
        else
        {
            if(![[self unSelectedChannelList] containsObject:channel[@"name"]])
            {
                [[self unSelectedChannelList] safe_addObject:channel[@"name"]];
            }
        }
    }
}
//
////跟新本地地方频道选择状态
- (void)updataLocalChannelSelectedState:(BOOL)state
                            channelName:(NSString *)channelName
{
    if([[NSUserDefaults loadValueForKey:LOCALCHANNEL] isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *channel = [NSMutableDictionary dictionaryWithDictionary:[NSUserDefaults loadValueForKey:LOCALCHANNEL]];
        
        if([channel[@"name"] isEqualToString:channelName])
        {
            channel[@"isSelect"] = state == NO ? @(NO) : @(YES);
        }
        
        [NSUserDefaults saveValue:[channel copy] ForKey:LOCALCHANNEL];
    }
}

- (void)loadCustomChannel:(void (^)(BOOL successed))finish
{
    [[ZWNewsNetworkManager sharedInstance]
     loadNewsChannelListData:[ZWUserInfoModel userID]//userid
     isCache:NO
     succed:^(id result) {
         
         NSArray *temChannelData = result;
         if(temChannelData.count > 0)
         {
             NSArray *tmpArray = [[ZWChannelDataManager sharedInstance] queryChannelData];
             
             NSMutableArray *tempChannels = [[NSMutableArray alloc] initWithCapacity:0];
             
             [[[ZWChannelDataManager sharedInstance] selectedChannelList] removeAllObjects];
             
             for (int i = 0;i < [temChannelData count];i++) {
                 ZWChannelModel *channelModel =[ZWChannelModel channelModelFromDictionary:temChannelData[i]];
                 
                 //筛选自定义频道在总频道列表中存在的频道，目的是有些用户自定义的频道已经不存在了，所以要过滤掉
                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelID == %@", channelModel.channelID];
                 
                 NSArray *filteredArray = [tmpArray filteredArrayUsingPredicate:predicate];
                 
                 if(filteredArray.count > 0)
                 {
                     [tempChannels safe_addObject:filteredArray[0]];
                     [[[ZWChannelDataManager sharedInstance] selectedChannelList] safe_addObject:[(ZWChannelModel *)filteredArray[0] channelName]];
                 }
             }
             //缓存用户自定义的频道
             [[ZWChannelDataManager sharedInstance] saveChannelData:tempChannels];
             
             //用户自定义的频道过滤后那么根据这些频道去筛选在总频道列表中剩下的频道，这些频道则作为非选中的频道
             [[[ZWChannelDataManager sharedInstance] unSelectedChannelList] removeAllObjects];
             
             for (ZWChannelModel *tmp in tmpArray) {
                 
                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelID == %@", tmp.channelID];
                 
                 NSArray *filteredArray = [tempChannels filteredArrayUsingPredicate:predicate];
                 
                 if(filteredArray.count == 0)
                 {
                     [[[ZWChannelDataManager sharedInstance] unSelectedChannelList] safe_addObject:tmp.channelName];
                 }
             }
             
             //如果选中的频道大于0，则添加地方频道后直接在界面呈现
             if([[ZWChannelDataManager sharedInstance] selectedChannelList].count == 0)
             {
                 //如果没有自定义频道，则加载默认的选中频道
                 [[[ZWChannelDataManager sharedInstance] unSelectedChannelList] removeAllObjects];
                 
                 for (ZWChannelModel *tmp in tmpArray) {
                     
                     if ([tmp.isSelected boolValue] == 1) {
                         
                         [[[ZWChannelDataManager sharedInstance] selectedChannelList] safe_addObject:tmp.channelName];
                     }else{
                         
                         [[[ZWChannelDataManager sharedInstance] unSelectedChannelList] safe_addObject:tmp.channelName];
                     }
                 }
                 
                 // 更新本地存储频道ID
                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == 1"];
                 
                 [[ZWChannelDataManager sharedInstance] saveChannelData:[tmpArray filteredArrayUsingPredicate:predicate]];
                 
             }
             finish(YES);
         }
     } failed:^(NSString *errorString) {
     }];
}

- (void)updataLocalChannelList
{
    NSMutableArray *saveChannel = [[NSMutableArray alloc]initWithCapacity:0];
    
    for (NSString *itemname in [[ZWChannelDataManager sharedInstance] selectedChannelList]) {
        
        ChannelItem *items = [[ZWChannelDataManager sharedInstance] queryChannelDataWithChannelName:itemname];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:0];
        [dic safe_setObject:items.channelId forKey:@"id"];
        [dic safe_setObject:items.channelName forKey:@"name"];
        [dic safe_setObject:items.sort forKey:@"sort"];
        [dic safe_setObject:items.isSelect forKey:@"isSelect"];
        [dic safe_setObject:items.mapping forKey:@"mapping"];
        [dic safe_setObject:items.updateTime ? items.updateTime : @"" forKey:@"updateTime"];
        
        [dic safe_setObject:items.createTime ? items.createTime : @"" forKey:@"createTime"];
        
        ZWChannelModel *channelModel=[ZWChannelModel channelModelFromDictionary:dic];
        
        if([[NSUserDefaults loadValueForKey:LOCALCHANNEL] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *channel = [NSUserDefaults loadValueForKey:LOCALCHANNEL];
            if(![itemname isEqualToString:channel[@"name"]])
                [saveChannel safe_addObject:channelModel];
        }
        else
        {
            [saveChannel safe_addObject:channelModel];
        }
    }
    
    [[ZWChannelDataManager sharedInstance] saveChannelData:saveChannel];
}

- (void)uploadCustomChannelList
{
    NSMutableArray *channelIDArray = [[NSMutableArray alloc]init];
    
    for (NSString *itemname in [[ZWChannelDataManager sharedInstance] selectedChannelList]) {
        
        ChannelItem *tmpmod = [[ZWChannelDataManager sharedInstance] queryChannelDataWithChannelName:itemname];
        
        if([[NSUserDefaults loadValueForKey:LOCALCHANNEL] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *channel = [NSUserDefaults loadValueForKey:LOCALCHANNEL];
            if(![itemname isEqualToString:channel[@"name"]])
                [channelIDArray safe_addObject:tmpmod.channelId];
        }else
        {
            [channelIDArray safe_addObject:tmpmod.channelId];
        }
    }
    //上传我的屏道列表
    [[ZWNewsNetworkManager sharedInstance] uploadMyNewsChannelListData:[ZWUserInfoModel userID]
                                                    channelData:channelIDArray
                                                        isCache:NO
                                                         succed:^(id result) {
                                                             ZWLog(@"succed");
                                                         } failed:^(NSString *errorString) {
                                                             ZWLog(@"failed");
                                                         }];
}

- (void)checkVersion:(void (^)(BOOL successed))success {
    
    ZWVersionCheckType type = kVersionCheckTypeAutomatic;
    if (self.hasCheckedVersion) {
        type = kVersionCheckTypeIgnore;
    }
    
    [ZWVersionManager checkVersionWithType:type finishBlock:^(BOOL hasNewVersion, id versionData) {
        
        [[ZWUpdateChannel sharedInstance] checkChannelSuccessWithResult:versionData];
        
        // 如果没有拿到频道数据，则不继续执行下面操作
        if (![[ZWUpdateChannel sharedInstance] channelVersion]) {
            if (success) {
                success(NO);
            }
            return ;
        }

        self.hasCheckedVersion = YES;
        
        //读取缓存的频道版本号
        NSString *channelVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kChannelVersion];
        
        //如果缓存的频道版本号不存在，或者缓存的频道版本号与接口获取的频道版本号不一致，又或者没有缓存频道列表数据时，则进入if语句体
        NSArray *tmpArray = [self queryChannelData];
        
        if (!channelVersion || [channelVersion integerValue] != [[ZWUpdateChannel sharedInstance].channelVersion integerValue] || tmpArray.count == 0)
        {
            NSMutableArray *defaultChannellist = [[NSMutableArray alloc]initWithArray:[ZWUpdateChannel sharedInstance].channelList];
            //清空数据库里的频道列表
            [[ZWChannelDataManager sharedInstance] deleteChannelListData];
            //将接口拿到的频道列表数据存到数据库
            [[ZWChannelDataManager sharedInstance] addChannelListDataWithNSArray:defaultChannellist];
            //缓存频道版本号
            [[NSUserDefaults standardUserDefaults] setObject:[ZWUpdateChannel sharedInstance].channelVersion forKey:kChannelVersion];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //如果是登录状态，则获取用户自定义频道
        if([ZWUserInfoModel userID])
        {
            [self loadCustomChannel:^(BOOL successed) {
                if ([self.selectedChannelList count]>0) {
                    [[ZWChannelDataManager sharedInstance] addLocalChannel];
                    success(YES);
                }
            }];
        }
        else
        {
            NSArray *tmpArray = [[ZWChannelDataManager sharedInstance] queryChannelData];
            [[ZWChannelDataManager sharedInstance] filterChannelData:tmpArray];
            [[ZWChannelDataManager sharedInstance] addLocalChannel];
            success(YES);
        }
    }];
}

#pragma mark - coredata操作
//删除数据
-(void)deleteChannelListData{
    
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription *Channellist = [NSEntityDescription entityForName:@"ChannelItem" inManagedObjectContext:[[AppDelegate sharedInstance] managedObjectContext]];
    
    [request setEntity:Channellist];
    NSError* error=nil;
    
    NSMutableArray* mutableFetchResult=[[[[AppDelegate sharedInstance] managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResult==nil) {
        ZWLog(@"Error:%@",error);
    }
    
    for (ChannelItem *ChannelItem in mutableFetchResult) {
        [[[AppDelegate sharedInstance] managedObjectContext] deleteObject:ChannelItem];
    }
    
    if ([[[AppDelegate sharedInstance] managedObjectContext] save:&error]) {
        ZWLog(@"Error:%@,%@",error,[error userInfo]);
    }
}

//插入数据
-(void)addChannelListDataWithNSArray:(NSArray *)dataSource{
    
    for (ZWChannelModel *channelModel in dataSource){
        
        ChannelItem *channelitem = (ChannelItem *)[NSEntityDescription insertNewObjectForEntityForName:@"ChannelItem" inManagedObjectContext:[[AppDelegate sharedInstance] managedObjectContext]];
        
        channelitem.channelId = channelModel.channelID;
        channelitem.sort = channelModel.sort;
        channelitem.channelName = channelModel.channelName;
        channelitem.createTime = @"";
        channelitem.updateTime = @"";
        channelitem.mapping = channelModel.mapping;
        channelitem.isSelect = channelModel.isSelected;
    }
    NSError* error;
    BOOL isSaveSuccess=[[[AppDelegate sharedInstance] managedObjectContext] save:&error];
    
    if (!isSaveSuccess) {
        ZWLog(@"Error:%@",error);
    }else{
        ZWLog(@"Save successful!");
    }
}

//获取本地所有频道数据
-(NSMutableArray *)queryChannelData{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *ChannelItementy = [NSEntityDescription entityForName:@"ChannelItem" inManagedObjectContext:[[AppDelegate sharedInstance] managedObjectContext]];
    
    [request setEntity:ChannelItementy];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError* error = nil;
    
    NSMutableArray* mutableFetchResult = [[[[AppDelegate sharedInstance] managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResult == nil) {
        ZWLog(@"Error:%@",error);
    }
    
    NSMutableArray *tempChannelArray = [[NSMutableArray alloc]init];
    
    for (ChannelItem *items in mutableFetchResult){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:mutableFetchResult.count];
        [dic safe_setObject:items.channelId forKey:@"id"];
        [dic safe_setObject:items.channelName forKey:@"name"];
        [dic safe_setObject:items.sort forKey:@"sort"];
        [dic safe_setObject:items.isSelect forKey:@"isSelect"];
        [dic safe_setObject:items.updateTime forKey:@"updateTime"];
        [dic safe_setObject:items.createTime forKey:@"createTime"];
        [dic safe_setObject:items.mapping forKey:@"mapping"];
        ZWChannelModel *channelModel=[ZWChannelModel channelModelFromDictionary:dic];
        [tempChannelArray safe_addObject:channelModel];
    }
    
    return tempChannelArray;
}

//根据频道名字找出频道ID
-(ChannelItem *)queryChannelDataWithChannelName:(NSString *)channelName{
    if([[NSUserDefaults loadValueForKey:LOCALCHANNEL] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *channel = [NSUserDefaults loadValueForKey:LOCALCHANNEL];
        
        if([channelName isEqualToString:channel[@"name"]])
        {
            ChannelItem *channelItem = [[ChannelItem alloc] initWithEntity:[NSEntityDescription entityForName:@"ChannelItem" inManagedObjectContext:[[AppDelegate sharedInstance] managedObjectContext]] insertIntoManagedObjectContext:nil];
            
            [channelItem setChannelName:channel[@"name"]];
            channelItem.channelId = @([channel[@"id"] integerValue]);
            
            channelItem.isSelect = channel[@"isSelect"];
            
            if([[channel allKeys] containsObject:@"mapping"])
            {
                channelItem.mapping = channel[@"mapping"];
            }
            
            channelItem.sort = @(0);

            channelItem.updateTime = @"";
            
            channelItem.createTime = @"";
            return channelItem;
        }
    }
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *ChannelItementy = [NSEntityDescription entityForName:@"ChannelItem" inManagedObjectContext:[[AppDelegate sharedInstance] managedObjectContext]];
    
    [request setEntity:ChannelItementy];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"channelName == %@",channelName];
    
    [request setPredicate:predicate];
    NSError* error = nil;
    
    NSMutableArray* mutableFetchResult = [[[[AppDelegate sharedInstance] managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResult == nil) {
        ZWLog(@"Error:%@",error);
    }
    
    if(mutableFetchResult.count > 0)
    {
        return (ChannelItem *)mutableFetchResult[0];
    }
    return nil;
}

@end
