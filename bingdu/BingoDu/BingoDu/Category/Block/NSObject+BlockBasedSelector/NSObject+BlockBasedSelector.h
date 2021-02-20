//
//  NSObject+BlockBasedSelector.h
//  NSObject_BlockBasedSelector
//
//  Created by Jack Rostron on 10/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BlockBasedSelector)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
