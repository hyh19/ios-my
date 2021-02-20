#import "FBStatisticsManager.h"
#import <AdSupport/AdSupport.h>
#import "FBLoginInfoModel.h"
#import "AFNetworkReachabilityManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "SSCarrierInfo.h"

@implementation FBStatisticsManager

+ (void)report:(id<GeneratedMessageProtocol>)protodata {
    
    NSMutableString *URLString = [NSMutableString stringWithString:@"https://stats.itsme.media/ios"];
    if ([protodata isKindOfClass:[EventsData class]]) {
        [URLString appendString:@"/event"];
    } else if ([protodata isKindOfClass:[AppActiveData class]]) {
        [URLString appendString:@"/appactive"];
    } else if ([protodata isKindOfClass:[UserActionData class]]) {
        [URLString appendString:@"/useraction"];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    NSData *data = [protodata data];
    request.HTTPBody = data;
    
    __block NSURLSessionDataTask *dataTask = nil;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    dataTask = [manager dataTaskWithRequest:request
                          completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                              if (error) {
                                  NSLog(@"error: %@", error);
                              } else {
                                  NSLog(@"success: %@", responseObject);
                              }
                          }];
    
    [dataTask resume];
}

+ (Identifier *)identifier {
    IdentifierBuilder *builder = [Identifier builder];
    [builder setIdfv:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    [builder setIdfa:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    [builder setUserId:[FBLoginInfoModel sharedInstance].userID];
    return [builder build];
}

+ (Device *)device {
    DeviceBuilder *builder = [Device builder];
    UIDevice *device = [UIDevice currentDevice];
    [builder setName:device.name];
    [builder setModel:device.model];
    [builder setLocalizedmodel:device.localizedModel];
    [builder setOrientation:device.orientation];
    [builder setBatteryMonitoringEnabled:device.batteryMonitoringEnabled];
    [builder setOrientationNotifications:device.generatesDeviceOrientationNotifications];
    [builder setAvailableBattery:device.batteryLevel];
    switch (device.batteryState) {
        case 0:
            [builder setBatteryState:@"UIDeviceBatteryStateUnknown"];
            break;
        case 1:
            [builder setBatteryState:@"UIDeviceBatteryStateUnplugged"];
            break;
        case 2:
            [builder setBatteryState:@"UIDeviceBatteryStateCharging"];
            break;
        case 3:
            [builder setBatteryState:@"UIDeviceBatteryStateFull"];
            break;
        default:
            [builder setBatteryState:@"UIDeviceBatteryStateUnknown"];
            break;
    }
    return [builder build];
}

+ (System *)system {
    SystemBuilder *builder = [System builder];
    UIDevice *device = [UIDevice currentDevice];
    [builder setSystemName:device.systemName];
    [builder setSystemVersion:device.systemVersion];
    [builder setCountryCode:[SSCarrierInfo carrierISOCountryCode]];
    [builder setNetworkType:[self networkType]];
    [builder setNetworkInformation:[SSCarrierInfo carrierName]];
    return [builder build];
}

+ (Product *)product {
    ProductBuilder *builder = [Product builder];
    [builder setPackgeName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    int versionCode = (int)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [builder setAppVersionCode:versionCode];
    [builder setInstallTime:[[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultsInstallDate]];
    [builder setUpdateTime:[[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultsUpdateDate]];
    return [builder build];
}

+ (EventParameter *)eventParameterWithKey:(NSString *)key value:(NSString *)value {
    EventParameterBuilder *builder = [EventParameter builder];
    [builder setKey:key];
    [builder setValue:value];
    return [builder build];
}

+ (Event *)eventWithSessionId:(SInt64)sessionID
                           ID:(NSString *)ID
         eventParametersArray:(NSArray *)array {
    EventBuilder *builder = [Event builder];
    [builder setSessionId:sessionID];
    [builder setId:ID];
    [builder setTime:[[NSDate date] timeIntervalSince1970]];
    [builder setEventParametersArray:array];
    return [builder build];
}

+ (EventsData *)eventsDataWithEventsArray:(NSArray *)array {
    EventsDataBuilder *builder = [EventsData builder];
    [builder setProtocolVersion:1];
    [builder setIdentifier:[FBStatisticsManager identifier]];
    [builder setDevice:[FBStatisticsManager device]];
    [builder setSystem:[FBStatisticsManager system]];
    [builder setProduct:[FBStatisticsManager product]];
    [builder setEventsArray:array];
    [builder setLoginTimestamp:[[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultsLoginTimeStamp]];
    return [builder build];
}


+ (AppActiveData *)appActiveData {
    AppActiveDataBuilder *builder = [AppActiveData builder];
    [builder setProtocolVersion:1];
    [builder setIsInitiative:YES];
    [builder setIdentifier:[self identifier]];
    [builder setDevice:[self device]];
    [builder setSystem:[self system]];
    [builder setProduct:[self product]];
    [builder setLoginTimestamp:[[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultsLoginTimeStamp]];
    return [builder build];
}

+ (RoomEventParameter *)roomEventParameterWithKey:(NSString *)key value:(NSString *)value {
    RoomEventParameterBuilder *builder = [RoomEventParameter builder];
    [builder setValue:key];
    [builder setKey:value];
    return [builder build];
}

+ (RoomEvent *)roomEventWithMoudleId:(SInt32)moudleId
                          positionId:(SInt32)positionId
                              roomId:(SInt32)roomId
                         broadcastId:(SInt32)broadcastId
                                  Id:(NSString *)Id
            roomeventParametersArray:(NSArray *)array {
    RoomEventBuilder *builder = [RoomEvent builder];
    [builder setMoudleId:moudleId];
    [builder setPositionId:positionId];
    [builder setRoomId:roomId];
    [builder setBroadcastId:broadcastId];
    [builder setTime:[[NSDate date] timeIntervalSince1970]];
    [builder setId:Id];
    [builder setRoomeventParametersArray:array];
    return [builder build];
}

+ (UserActionData *)userActionDataWithSessionId:(SInt64)sessionId
                                    eventsArray:(NSArray *)array {
    UserActionDataBuilder *builder = [UserActionData builder];
    [builder setProtocolVersion:1];
    [builder setIdentifier:[self identifier]];
    [builder setDevice:[self device]];
    [builder setSystem:[self system]];
    [builder setProduct:[self product]];
    [builder setRoomSessionId:sessionId];
    [builder setRoomeventsArray:array];
    [builder setLoginTimestamp:[[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultsLoginTimeStamp]];
    return [builder build];
}


// 网络类型，0=未获取到网络类型，1=wifi,2=2G,3=3G,4=4G,5=未知网络
+ (int32_t)networkType {
    __block int32_t networkStatus;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        networkStatus = status;
    }];
    switch (networkStatus) {
        case AFNetworkReachabilityStatusUnknown:
            return 5;
            break;
        case AFNetworkReachabilityStatusNotReachable:
            return 0;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:{
            NSString *currentStatus  = [[CTTelephonyNetworkInfo alloc]init].currentRadioAccessTechnology;
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]) {
                return 4;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                return 2;
            } else {
                return 3;
            }
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return 1;
            break;
        default:
            return 0;
            break;
    }
    
}

+ (NSInteger)loginStatus {
    NSString *loginType = [[FBLoginInfoModel sharedInstance] loginType];
    if ([loginType isValid]) {
        if (loginType.isEqualTo(kPlatformFacebook)) {
            return 1;
        } else if (loginType.isEqualTo(kPlatformTwitter)) {
            return 2;
        } else if (loginType.isEqualTo(kPlatformEmail)) {
            return 3;
        } else {
            return 4;
        }
    }
    return 0;
}

@end
