#import "ABContactsHelper+NHZW.h"
#import "ABContact+NHZW.h"

@implementation ABContactsHelper (NHZW)

+ (NSArray *)mobileContacts {
    
    NSMutableArray *array = [NSMutableArray array];
    for (ABContact *contact in [ABContactsHelper contacts]) {
        if ([contact.mobileArray count]>0) {
            [array safe_addObject:contact];
        }
    }
    
    return array;
}

+ (NSArray *)contactsMatchingMobile:(NSString *)number {
    
    NSPredicate *pred;
    
    NSArray *contacts = [ABContactsHelper mobileContacts];
    
    pred = [NSPredicate predicateWithFormat:@"mobileNumbers contains[cd] %@", number];
    
    return [contacts filteredArrayUsingPredicate:pred];
}

+ (NSArray *)mobileArray {
    
    NSMutableArray *array = [NSMutableArray array];
    for (ABContact *contact in [ABContactsHelper mobileContacts]) {
        [array addObjectsFromArray:contact.mobileArray];
    }
    return array;
}

@end
