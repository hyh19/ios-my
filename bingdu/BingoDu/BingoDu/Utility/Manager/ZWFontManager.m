#import "ZWFontManager.h"

@interface ZWFontManager ()

/** 字体大小和颜色字典 */
@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation ZWFontManager

+ (instancetype)sharedInstance {
    
    static dispatch_once_t once;
    
    static ZWFontManager *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWFontManager alloc] init];
        
        sharedInstance.dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Font" ofType:@"plist"]];
        
    });
    
    return sharedInstance;
}

+ (UIFont *)sizeWithPrimaryKey:(NSString *)primaryKey andSecondaryKey:(NSString *)secondaryKey {
    
    NSDictionary *dictionary = [[ZWFontManager sharedInstance] dictionary];
    
    // 3.5英寸屏幕
    if ([[UIScreen mainScreen] isThreeFivePhone]) {
        NSNumber *size35 = dictionary[primaryKey][secondaryKey][@"3.5inch"];
        if ([size35 floatValue]>0) { return [UIFont systemFontOfSize:[size35 floatValue]]; }
        
    // 4.0英寸屏幕
    } else if ([[UIScreen mainScreen] isFourPhone]) {
        NSNumber *size40 = dictionary[primaryKey][secondaryKey][@"4inch"];
        if ([size40 floatValue]>0) { return [UIFont systemFontOfSize:[size40 floatValue]]; }
        
    // 4.7英寸屏幕
    } else if ([[UIScreen mainScreen] isFourSevenPhone]) {
        NSNumber *size47 = dictionary[primaryKey][secondaryKey][@"4.7inch"];
        if ([size47 floatValue]>0) { return [UIFont systemFontOfSize:[size47 floatValue]]; }
        
    // 5.5英寸屏幕
    } else if ([[UIScreen mainScreen] isFiveFivePhone]) {
        NSNumber *size55 = dictionary[primaryKey][secondaryKey][@"5.5inch"];
        if ([size55 floatValue]>0) { return [UIFont systemFontOfSize:[size55 floatValue]]; }
    }
    
    // 默认大小
    NSNumber *size = dictionary[primaryKey][secondaryKey][@"size"];
    return [UIFont systemFontOfSize:[size floatValue]];
}

+ (UIColor *)colorWithPrimaryKey:(NSString *)primaryKey andSecondaryKey:(NSString *)secondaryKey {
    NSDictionary *dictionary = [[ZWFontManager sharedInstance] dictionary];
    NSString *string = dictionary[primaryKey][secondaryKey][@"color"];
    return [UIColor colorWithHexString:string];
}

@end
