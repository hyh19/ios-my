#import "ABContact+NHZW.h"
#import "ZWUtility.h"

@implementation ABContact (NHZW)

- (NSArray *)mobileArray {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *phone in [self phoneArray]) {
        // 过滤手机号码中的非法字符，目前非法字符为：+86、空格、横杠
        NSString *filteredNum = phone.replace(@"+86", @"").replace(@" ", @"").replace(@"-", @"");
        
        if (filteredNum && filteredNum.length == 11) {
            [array safe_addObject:filteredNum];
        }
    }
    
    return array;
}

- (NSString *)mobileNumbers {
    return [self.mobileArray componentsJoinedByString:@" "];
}

- (NSString *)name {
    return ([self.compositeName isValid])? self.compositeName : self.mobileNumbers;
}

@end
