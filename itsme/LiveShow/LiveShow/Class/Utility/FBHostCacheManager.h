//
//  FBHostCacheManager.h
//  LiveShow
//
//  Created by chenfanshun on 26/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBHostCacheManager : NSObject

- (void)begin;

- (NSString*)getCacheIpFromHost:(NSString*)hostName;

@end
