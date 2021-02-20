#import "ZWURLRequest.h"

/** 引流标记请求头的键 */
#define kHeaderFieldRefer @"Referer"

/** 引流标记请求头的值 */
#define kHeaderValueRefer @"http://bdapp.bingodu.com"

@implementation ZWURLRequest

- (instancetype)initWithURL:(NSURL *)theURL {
    if (self = [super initWithURL:theURL]) {
        [self addValue:kHeaderValueRefer forHTTPHeaderField:kHeaderFieldRefer];
    }
    return self;
}

+ (instancetype)requestWithURL:(NSURL *)theURL {
    ZWURLRequest *request = [[ZWURLRequest alloc] initWithURL:theURL];
    return request;
}

- (instancetype)initWithURL:(NSURL *)theURL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (self = [super initWithURL:theURL cachePolicy:cachePolicy timeoutInterval:timeoutInterval]) {
        [self addValue:kHeaderValueRefer forHTTPHeaderField:kHeaderFieldRefer];
    }
    return self;
}

+ (instancetype)requestWithURL:(NSURL *)theURL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
    ZWURLRequest *request = [[ZWURLRequest alloc] initWithURL:theURL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
    return request;
}

@end
