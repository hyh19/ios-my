//
//  FBHashTagManager.m
//  LiveShow
//
//  Created by chenfanshun on 11/08/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBHashTagManager.h"

@interface FBHashTagManager()

@property(nonatomic, strong)NSMutableArray  *tagsArray;

@end

@implementation FBHashTagManager

-(id)init
{
    if(self = [super init]) {
        self.tagsArray = [[NSMutableArray alloc] init];
        //暂时写死
        [self.tagsArray addObject:@"#Music"];
        [self.tagsArray addObject:@"#Dancing"];
        [self.tagsArray addObject:@"#Boys"];
        [self.tagsArray addObject:@"#Singing"];
    }
    return self;
}

-(NSArray*)getTags
{
    return self.tagsArray;
}

@end
