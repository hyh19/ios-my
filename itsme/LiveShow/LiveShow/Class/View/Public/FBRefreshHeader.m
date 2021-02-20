//
//  FBRefreshHeader.m
//  LiveShow
//
//  Created by tak on 12/2/16.
//  Copyright © 2016 FB. All rights reserved.
//

#import "FBRefreshHeader.h"

@implementation FBRefreshHeader

- (void)prepare {
    [super prepare];
    NSMutableArray *normalImages = [NSMutableArray array];
    for (int i = 0; i <= 15; i++) {
        if (i == 0) {
            //初始状态图片
            [normalImages addObject: [UIImage imageNamed:@"loading_001"]];
        } else {
            [normalImages addObject:[UIImage imageNamed:@"pull_000"]];
        }
    }
    // 设置普通状态的动画图片
    for (int i = 1; i<=14; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"pull_%03d", i]];
        [normalImages addObject:image];
    }
    [self setImages:normalImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (int i = 1; i<=15; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%03d", i]];
        [refreshingImages addObject:image];
    }
    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
}

@end
