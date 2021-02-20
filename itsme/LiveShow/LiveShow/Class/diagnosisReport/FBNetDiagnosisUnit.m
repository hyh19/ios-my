//
//  FBNetDiagnosisUnit.m
//  LiveShow
//
//  Created by chenfanshun on 28/06/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBNetDiagnosisUnit.h"
#import "FBLoginInfoModel.h"
#import "FBLiveStreamNetworkManager.h"

#import "LDNetDiagnoService.h"


@interface FBNetDiagnosisUnit()<LDNetDiagnoServiceDelegate>

@property(nonatomic, copy)NSString *openLiveUrl;
@property(nonatomic, copy)NSString *queryUrl;
@property(nonatomic, copy)NSString *live_id;

@property(nonatomic, assign)NSInteger querySlaps;
@property(nonatomic, assign)NSInteger streamSlaps;
@property(nonatomic, assign)BOOL      isReconnected;

@property(nonatomic, assign)id<FBNetDiagnosisReportDelegate>    delegate;

/** 网络诊断 */
@property(nonatomic, strong) LDNetDiagnoService *diagnoService;


@end

@implementation FBNetDiagnosisUnit

-(id)initWithUrl:(NSString*)openLiveUrl
        queryUrl:(NSString*)queryUrl
      querySlaps:(NSInteger)querySlaps
     streamSlaps:(NSInteger)streamSlaps
          liveid:(NSString*)live_id
     isReconnect:(BOOL)isReconnected
           index:(BOOL)index
     andDelegate:(id<FBNetDiagnosisReportDelegate>)delegate
{
    if(self = [super init]) {
        self.openLiveUrl = openLiveUrl;
        self.queryUrl = queryUrl;
        self.live_id = live_id;
        self.querySlaps = querySlaps;
        self.streamSlaps = streamSlaps;
        self.isReconnected = isReconnected;
        self.index = index;
        self.delegate = delegate;
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"dealloc %@", self);
}

-(void)starDiagnosis
{
    NSString *domain = [self getAppDomainFrom:self.openLiveUrl];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *appName = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [NSString stringWithFormat:@"%@/%@", [FBUtility versionCode], [FBUtility buildCode]];
    NSString *uid = [[FBLoginInfoModel sharedInstance] userID];
    NSString *carrierName = [FBUtility carrierName];
    _diagnoService = [[LDNetDiagnoService alloc] initWithAppCode:identifier appName:appName appVersion:appVersion userID:uid deviceID:nil dormain:domain carrierName:carrierName ISOCountryCode:nil MobileCountryCode:nil MobileNetCode:nil];
    _diagnoService.delegate = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_diagnoService startNetDiagnosis];
    });
}

-(void)endDiagnosis
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf.diagnoService stopNetDialogsis];
        weakSelf.diagnoService.delegate = nil;
        weakSelf.diagnoService = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([weakSelf.delegate respondsToSelector:@selector(onEndDiagnosis:)]) {
                [weakSelf.delegate onEndDiagnosis:weakSelf.index];
            }
        });
    });
}

-(NSString*)getAppDomainFrom:(NSString*)url
{
    NSString* domain = @"";
    NSString* proto = @"rtmp://";
    NSRange range = [url rangeOfString:proto];
    if(range.location != NSNotFound) {
        url = [url substringFromIndex:range.length];
    }
    NSArray* spliters = [url componentsSeparatedByString:@"/"];
    if(2 == [spliters count]) {
        domain = spliters[0];
    } else {
        domain = url;
    }
    
    spliters = [domain componentsSeparatedByString:@":"];
    if(2 == [spliters count]) {
        domain = spliters[0];
    }
    return domain;
}

#pragma mark - network diagnosis -
- (void)netDiagnosisDidStarted
{
    
}

- (void)netDiagnosisStepInfo:(NSString *)stepInfo
{
    
}

- (void)netDiagnosisDidEnd:(NSString *)allLogInfo
{
    if([allLogInfo length]) {
        [[FBLiveStreamNetworkManager sharedInstance] reportDataLogWithUrl:self.openLiveUrl queryUrl:self.queryUrl querySlaps:self.querySlaps streamSlaps:self.streamSlaps liveid:self.live_id type:@"ping" isreconnect:_isReconnected bitRate:nil ping:allLogInfo error:nil success:^(id result) {
            NSLog(@"report netDiagnosis success");
        } failure:^(NSString *errorString) {
            NSLog(@"report netDiagnosis failure");
        } finally:^{
            
        }];
    }
    
    [self endDiagnosis];
}


@end
