#import "ZWLocationManager.h"
#import "UIAlertView+Blocks.h"

#define LOCATION_TIMEOUT 30

/** 省份名称 */
static NSString *province = nil;

/** 城市名称 */
static NSString *city = nil;

/** 区名称 */
static NSString *regin = nil;

/** 经度 */
static NSString *longitude = nil;

/** 纬度 */
static NSString *latitude = nil;

@interface ZWLocationManager () <CLLocationManagerDelegate>

/** 系统的定位服务管理器 */
@property (nonatomic, strong) CLLocationManager *locationManager;

/** 定位成功后的回调函数 */
@property (nonatomic, copy) void (^successBlock) ();

/** 定位失败后的回调函数 */
@property (nonatomic, copy) void (^failureBlock) ();

@end

@implementation ZWLocationManager

+ (void)updateLocationWithSuccess:(void(^)())success failure:(void(^)())failure {
    
    if (![ZWLocationManager locationAvailable]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        ZWLocationManager *manager = [[ZWLocationManager alloc] init];
        
        if ([manager.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
            [manager.locationManager requestWhenInUseAuthorization];
        }
        
        manager.successBlock = (success);
        
        manager.failureBlock = (failure);
        
        [manager.locationManager startUpdatingLocation];
        
        [manager performSelector:@selector(stopUpdatingLocation) withObject:nil afterDelay: LOCATION_TIMEOUT];
    });
}

+ (BOOL)locationAvailable {
    return !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
             [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted);
}

+ (NSString *)province {
    return province;
}

+ (NSString *)city {
    return city;
}

+ (NSString *)regin
{
    return regin;
}

+ (NSString *)longitude {
    return longitude;
}

+ (NSString *)latitude {
    return latitude;
}

static NSString * const AppleLanguagesKey = @"AppleLanguages";

/** 根据经纬度解析出地理位置名，如省市名称等 */
- (void)performCoordinateGeocode:(CLLocation *)location {
    
    // 如果手机系统语言不是简体中文，先强制转化为简体中文，地理位置解析完成后重置为默认系统语言
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:AppleLanguagesKey];
    
    NSString *currentLanguage = [array firstObject];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-Hans", nil]
                                              forKey:AppleLanguagesKey];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if (error){
                           [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:currentLanguage, nil]
                                                                     forKey:AppleLanguagesKey];
                           return;
                       }
                       
                       CLPlacemark *placemark = [placemarks lastObject];
                       
                       province = placemark.administrativeArea;
                       
                       city = placemark.locality;
                       
                       regin = placemark.subLocality;
                       
                       longitude = [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude];
                       
                       latitude = [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude];
                       
                       if (self.successBlock) { self.successBlock(); }
                       
                       [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:currentLanguage, nil]
                                                                 forKey:AppleLanguagesKey];
                   }];
}

/** 关闭定位更新 */
- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}

#pragma mark - Getter & Setter
- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        
        _locationManager.distanceFilter = 10.0f;
        
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        
    }
    return _locationManager;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self performCoordinateGeocode:[locations lastObject]];
    [self stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if (self.failureBlock) { self.failureBlock(); }
    
    [self stopUpdatingLocation];
}

@end
