#import "NSUserDefaults+NHZW.h"

@implementation NSUserDefaults (NHZW)

+ (void)saveValue:(id)value ForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)loadValueForKey:(NSString *)key {
    id value = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    return value;
}

+ (id)loadValueForKey:(NSString *)key defaultValue:(id)defaultValue {
    id value = [NSUserDefaults loadValueForKey:key];
    if (value) {
        return value;
    }
    return defaultValue;
}

+ (id)objectForKey:(NSString *)key defaultObject:(id)defaultObject {
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (obj) {
        return obj;
    }
    return defaultObject;
}

@end

