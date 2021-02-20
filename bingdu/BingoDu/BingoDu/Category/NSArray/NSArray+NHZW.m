#import "NSArray+NHZW.h"

@implementation NSMutableArray (NHZW)

- (void)safe_addObject:(id)anObject {
    if (anObject) { [self addObject:anObject]; }
}

- (void)safe_addObjectsFromArray:(NSArray *)otherArray {
    if (otherArray && [otherArray count]) {
        [self addObjectsFromArray:otherArray];
    }
}

- (void)safe_removeObject:(id)anObject {
    if (anObject) { [self removeObject:anObject]; }
}

- (void)safe_removeObjectsInArray:(NSArray *)otherArray {
    if (otherArray && otherArray.count>0) {
        [self removeObjectsInArray:otherArray];
    }
}

- (id)safe_objectAtIndex:(NSUInteger)index {
    if (self && [self count] > index) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end