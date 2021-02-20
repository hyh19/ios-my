#import "FBURLManager.h"
#import "FBHostCacheManager.h"
#import "FBGAIManager.h"

@interface FBURLManager ()

@property (nonatomic, strong) NSTimer *requestTimer;

/** 请求失败加载缓存数据时，是否已经广播过加载数据的通知 */
@property (nonatomic) BOOL postNotificationWhenLoadCacheData;

@end

@implementation FBURLManager

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    
    static FBURLManager *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[FBURLManager alloc] init];
        
    });
    
    return sharedInstance;
}

- (void)dealloc {
    [self removeTimers];
}

#pragma mark - Getter & Setter -
- (void)setServerType:(FBServerType)serverType {
    _serverType = serverType;
    // 缓存到本地
    [[GVUserDefaults standardUserDefaults] setServerType:@(_serverType)];
    // 切换的时候要重新请求全部接口数据
    [self requestURLData];
}

+ (NSString *)baseURL {
    if (kServerTypeDevelopment == (FBServerType)[[[GVUserDefaults standardUserDefaults] serverType] integerValue]) {
        return BASE_URL_DEVELOPMENT;
    }
    return BASE_URL_PRODUCTION;
}

+ (NSString *)URLForAllNetworkAPI {
    return [NSString stringWithFormat:@"%@%@", [FBURLManager baseURL], @"/serviceinfo/all.php"];
}

+ (NSDictionary *)URLData {
    return [[GVUserDefaults standardUserDefaults] URLData];
}

- (void)requestURLData {
    [[FBPublicNetworkManager sharedInstance] loadAllURLWithSuccess:^(id result) {
        [self configURLData:result];
        [self removeTimers];
    } failure:^(NSString *errorString) {
        // 如果请求失败，并且没有缓存数据，则一直重新请求，如果有缓存，则定时刷新
        if ([[[GVUserDefaults standardUserDefaults] URLData] count] <= 0) {
            [self requestURLData];
        } else {
            // 已经广播过，不再广播，避免每次定时刷新时都广播
            if (!self.postNotificationWhenLoadCacheData) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadURLDataSuccess object:nil];
            }
            [self addTimers];
        }
        
        NSString *action = @"error";
        if([errorString length]) {
            action = errorString;
        }
        [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_HTTPERROR_STATITICS action:errorString label:@"IOS_API_MAP" value:@(1)];
    } finally:^{
        //
    }];
}

/** 配置数据 */
- (void)configURLData:(NSDictionary *)dict {
    NSArray *array = dict[@"server"];
    NSMutableDictionary *URLDictionary = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in array) {
        [URLDictionary setObject:dict[@"url"] forKey:dict[@"key"]];
    }
    if ([URLDictionary count] > 0) {
        // 缓存数据到本地
        [[GVUserDefaults standardUserDefaults] setURLData:URLDictionary];
        // 广播成功加载网络请求接口数据
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadURLDataSuccess object:nil];
    }
}

- (NSString *)URLStringWithKey:(NSString *)key {
    // 从本地缓存读取数据
    return [[GVUserDefaults standardUserDefaults] URLData][key];
}

- (NSString *)keyFromURLString:(NSString *)URLString {
    NSString *result = @"";
    NSDictionary *URLData = [[GVUserDefaults standardUserDefaults] URLData];
    NSArray *allKeys = [URLData allKeys];
    for (NSString *key in allKeys) {
        NSString *theURLString = URLData[key];
        if([URLString isEqualToString:theURLString]) {
            result = key;
        }
    }
    return result;
}

- (NSString *)streamURLWithParam:(NSString *)param {
    NSString *IPAddress = [[FBHostCacheManager sharedInstance] getCacheIpFromHost:LIVE_STREAM_HOST];
    NSString *URLString = [NSString stringWithFormat:@"http://%@:9999/%@", IPAddress, param];
    return URLString;
}

- (void)addTimers {
    [self removeTimers];
    // 1至5秒随机
    NSInteger time = 1 + arc4random() % (5 - 1 + 1);
    self.requestTimer = [NSTimer bk_scheduledTimerWithTimeInterval:time block:^(NSTimer *timer) {
        [self requestURLData];
    } repeats:NO];
}

- (void)removeTimers {
    if (self.requestTimer) {
        [self.requestTimer invalidate];
        self.requestTimer = nil;
    }
}

@end
