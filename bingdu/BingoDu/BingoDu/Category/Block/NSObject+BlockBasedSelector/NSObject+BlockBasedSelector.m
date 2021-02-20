//
//  NSObject+BlockBasedSelector.m
//  NSObject_BlockBasedSelector
//
//  Created by Jack Rostron on 10/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "NSObject+BlockBasedSelector.h"

@implementation NSObject (BlockBasedSelector)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(performBlock:) withObject:[block copy] afterDelay:delay];
}

- (void)performBlock:(void (^)(void))block
{
    block();
}

@end
