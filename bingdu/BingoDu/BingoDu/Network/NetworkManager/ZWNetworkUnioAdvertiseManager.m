#import "ZWNetworkUnioAdvertiseManager.h"
#import "ZWNewsNetworkManager.h"
#import "ZWLocationManager.h"
#import "UIDevice+HardwareName.h"

@interface  ZWNetworkUnioAdvertiseManager()

@end

@implementation ZWNetworkUnioAdvertiseManager

-(id)initUionWithUlr:(NSString*)urlString callBack:(uionAdvertiseUrl) adverTiseUrl

{
    self=[super init];
    if (self)
    {
        _urlString=urlString;
        _urlCallBack=adverTiseUrl;
        [self getUnioAdvertiseUrl];
    }
    return  self;
}

-(void)getUnioAdvertiseUrl
{
    //创建媒体对象
    NSMutableDictionary *mediaDic=[[NSMutableDictionary alloc] init];
    NSMutableDictionary *deviceDic=[[NSMutableDictionary alloc] init];
    NSMutableDictionary *netDic=[[NSMutableDictionary alloc] init];
    NSMutableDictionary *clientDic=[[NSMutableDictionary alloc] init];
    NSMutableDictionary *geoDic=[[NSMutableDictionary alloc] init];
    NSMutableArray *adslotArray=[[NSMutableArray alloc] init];
    
    {
        [mediaDic safe_setObject:@"b8570a95" forKey:@"id"];
        [mediaDic safe_setObject:@"" forKey:@"channel_id"];
        [mediaDic safe_setObject:[NSNumber numberWithInteger:1] forKey:@"type"];
    }
    //创建设备信息对象
    {
        
        [deviceDic safe_setObject:[NSNumber numberWithInteger:2] forKey:@"type"];
        [deviceDic safe_setObject:[NSNumber numberWithInteger:2] forKey:@"os_type"];
        
        
        //创建版本对象
        NSMutableDictionary *versionDic=[[NSMutableDictionary alloc] init];
        [versionDic safe_setObject:[NSNumber numberWithInt:(int)[ZWUtility getIOSVersion]] forKey:@"major"];
        [deviceDic safe_setObject:versionDic forKey:@"os_version"];
        
        //创建屏幕大小对象
        NSMutableDictionary *screenDic=[[NSMutableDictionary alloc] init];
        [screenDic safe_setObject:[NSNumber numberWithInt:(int)SCREEN_WIDTH] forKey:@"width"];
        [screenDic safe_setObject:[NSNumber numberWithInt:(int)SCREEN_HEIGH] forKey:@"height"];
        [deviceDic safe_setObject:screenDic forKey:@"screen_size"];
        
        //创建idfa对象
        NSMutableDictionary *idfaDic=[[NSMutableDictionary alloc] init];
        [idfaDic safe_setObject:[NSNumber numberWithInt:3] forKey:@"type"];
        [idfaDic safe_setObject:([[UIDevice currentDevice] idfaString]? [[UIDevice currentDevice] idfaString] : @"") forKey:@"id"];
        [deviceDic safe_setObject:[NSArray arrayWithObjects:idfaDic, nil] forKey:@"ids"];
    }
    //创建网络信息对象
    {
        [netDic safe_setObject:[NSNumber numberWithInt:1] forKey:@"type"];
    }
    //创建客户端对象
    {
        [netDic safe_setObject:[NSNumber numberWithInt:1] forKey:@"type"];
        NSMutableDictionary *versionDic=[[NSMutableDictionary alloc] init];
        [versionDic safe_setObject:[NSNumber numberWithInt:1] forKey:@"major"];
        [clientDic safe_setObject:versionDic forKey:@"version"];
    }
    
    //创建地理位置对象
    {
        [geoDic safe_setObject:[NSNumber numberWithInt:1] forKey:@"type"];
        [geoDic safe_setObject: [NSNumber numberWithDouble:[[ZWLocationManager longitude] doubleValue]]  forKey:@"longitude"];
        [geoDic safe_setObject:[NSNumber numberWithDouble:[[ZWLocationManager latitude] doubleValue]] forKey:@"latitude"];
        [geoDic safe_setObject:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]forKey:@"timestamp"];
    }
    //创建广告信息对象
    {
        NSMutableDictionary *adslotDic=[[NSMutableDictionary alloc] init];
        [adslotDic safe_setObject:@"scf3362a" forKey:@"id"];
        [adslotDic safe_setObject:[NSNumber numberWithInt:9] forKey:@"type"];
        //创建广告图片大小对象
        NSMutableDictionary *imageDic=[[NSMutableDictionary alloc] init];
        [imageDic safe_setObject:[NSNumber numberWithInt:(int)SCREEN_WIDTH] forKey:@"width"];
        [imageDic safe_setObject:[NSNumber numberWithInt:100] forKey:@"height"];
        [adslotDic safe_setObject:imageDic forKey:@"size"];
        [adslotDic safe_setObject:[NSNumber numberWithInt:1] forKey:@"capacity"];
        [adslotDic safe_setObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], nil] forKey:@"accept_adtype"];
        [adslotArray safe_addObject:adslotDic];
    }
    __weak typeof(self) weakSelf=self;
    [[ZWNewsNetworkManager sharedInstance] getNetworkUionAdvertiseWithDomain:_urlString media:mediaDic device:deviceDic network:netDic client:clientDic geo:geoDic adslots:adslotArray succed:^(id result)
     {
         if (result && [result isKindOfClass:[NSDictionary class]])
         {
             ZWLog(@"result && [result isKindOfClass:[NSDictionary class]]");
             NSArray *adArray=[result objectForKey:@"Ads"];
             if (adArray && [adArray isKindOfClass:[NSArray class]])
             {
                 if (adArray.count<=0)
                 {
                     ZWLog(@"ads数据为空");
                     return;
                 }
                 NSDictionary *adverDic=adArray[0];
                 if (adverDic && [adverDic isKindOfClass:[NSDictionary class]])
                 {
                     NSDictionary *detailDic=adverDic[@"Native_material"];
                     if (detailDic && [detailDic isKindOfClass:[NSDictionary class]])
                     {
                         NSString *imageUrl=detailDic[@"Image_url"];
                         NSString *clickUrl=detailDic[@"Click_url"];
                         NSString *title=detailDic[@"Title"];
                         /**展现日志URL 发送给捷酷 */
                         NSArray *impressionUrl=detailDic[@"Impression_log_url"];
                         /**点击监控URL 发送给捷酷 */
                         NSArray *clickeMonitorUrl=detailDic[@"Click_monitor_url"];
                         if(imageUrl && clickUrl)
                         {
                             _urlCallBack(imageUrl,clickUrl,title,impressionUrl,clickeMonitorUrl);
                             ZWLog(@"the imageUrl:%@,clickurl:%@,title:%@",imageUrl,clickUrl,title);
                         }
                     }
                 }
                 else
                 {
                     ZWLog(@"网盟广告返回数据：Native_material 字段没找到");
                 }
                 
             }
             else
             {
                 ZWLog(@"网盟广告返回数据：Ads 内容格式错");
             }
         }
         else
         {
             ZWLog(@"网盟广告返回数据有误");
         }
         
     }
     failed:^(NSString *errorString)
     {
         ZWLog(@"加载网盟（捷酷）广告失败:%@！",errorString);
     }];
}
@end
