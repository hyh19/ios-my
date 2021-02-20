#import "NSArray+FB.h"

@implementation NSMutableArray (FB)

- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject) { [self insertObject:anObject atIndex:index]; }
}

- (void)safe_addObject:(id)anObject {
    if (anObject) { [self addObject:anObject]; }
}

- (void)safe_addObjectsFromArray:(NSArray *)otherArray {
    if (otherArray && [otherArray count] > 0) {
        [self addObjectsFromArray:otherArray];
    }
}

- (void)safe_removeObject:(id)anObject {
    if (anObject) { [self removeObject:anObject]; }
}

- (void)safe_removeObjectsInArray:(NSArray *)otherArray {
    if (otherArray && [otherArray count] > 0) {
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