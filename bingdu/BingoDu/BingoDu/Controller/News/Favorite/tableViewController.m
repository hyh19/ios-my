#import "tableViewController.h"
#import "ZWAdxAdvertiseCell.h"
#import "ZWAdxAdvertiseModel.h"
#import "Reachability.h"
#import "ZWNewsNetworkManager.h"
#import "ZWUtility.h"

#import "ZWHTTPRequestFactory.h"

@interface tableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic) NSMutableArray *data;

@end

@implementation tableViewController

- (NSMutableArray *)data {
    if (!_data) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView registerClass:[ZWAdxAdvertiseCell class] forCellReuseIdentifier:NSStringFromClass([ZWAdxAdvertiseCell class])];
    [self sendRequestForAdxAdvertisement];
}

- (void)configureData:(id)data {
    
    id result = data;
    if ([data count] > 0) {
        for (NSDictionary *dict in result) {
            ZWAdxAdvertiseModel *model = [ZWAdxAdvertiseModel modelWithData:dict];
            [self.data safe_addObject:model];
        }
    }

}

/** 获取ip地址,只能获取到局域网内的 */
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        
        while (temp_addr != NULL)
        {
            if( temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

/** 氪金广告 */
- (void)sendRequestForAdxAdvertisement {
    
    NSDate *dateNow = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)[dateNow timeIntervalSince1970]];
    long now = [timeStamp longLongValue];
    
    NSString *appid = @"";
    NSString *idfa = [[UIDevice currentDevice] idfaString];
    NSString *os = @"2";
    NSString *pack = @"com.southZW.BD";
    NSString *appkey = @"apikeyfortest";
    
    NSString *token = [NSString stringWithFormat:@"%@%@%@%@%ld%@", appid, idfa, os, pack,now,appkey];
    NSString *tokenMD5 = [NSString stringWithFormat:@"%@", [ZWUtility md5:token]];
    
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    int nt = 0;
    switch (status) {
        case NotReachable:
        {
            nt = 0;
            break;
        }
        case ReachableViaWiFi:
        {
            nt = 1;
            break;
        }
        case ReachableViaWWAN:
        {
            nt = 4;
            break;
        }
        default:
            break;
    }
    
    [[ZWNewsNetworkManager sharedInstance] getNetworkAdxAdvertiseWithAffId:@"affbingduios"
                                                                   affType:1
                                                                posterType:0
                                                                   adWidth:320
                                                                  adHeigth:50
                                                                        os:2
                                                                       osv:[[UIDevice currentDevice] systemVersion]
                                                                      dvid:idfa
                                                                deviceType:1
                                                                      idfa:idfa
                                                                       mac:[[UIDevice currentDevice] macaddress]
                                                               deviceWidth:SCREEN_WIDTH
                                                              deviceHeigth:SCREEN_HEIGH
                                                               orientation:0
                                                                        ip:[self getIPAddress]
                                                                        nt:nt
                                                                      pack:@"com.southZW.BD"
                                                                 timestamp:now
                                                                     token:tokenMD5
                                                                    succed:^(id result) {
                                                                        if (result) {
                                                                            NSLog(@"the adx result is %@", result);
                                                                            [self configureData:result];                                                    }
                                                                        [self.tableView reloadData];

                                                                    }
                                                                    failed:^(NSString *errorString) {
                                                                        //
                                                                    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier forIndexPath:indexPath];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
//    }
//    cell.textLabel.text = self.data[indexPath.row];
//    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
//    
//    return cell;
    ZWAdxAdvertiseCell *cell = (ZWAdxAdvertiseCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWAdxAdvertiseCell class])];
    cell.adxModel = self.data[indexPath.row];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

@end
