@implementation NSMutableDictionary (NHZW)

- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey defaultObject:(id)defaultObject {
    if (anObject) {
        [self safe_setObject:anObject forKey:aKey];
    } else {
        [self safe_setObject:defaultObject forKey:aKey];
    }
}

@end