//
//  FBLiveManager.m
//  LiveShow
//
//  Created by chenfanshun on 14/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLiveManager.h"

@implementation FBLiveManager
{
    UIViewController    *_currentLiveController;
    NSString            *_currentLiveID;
}

-(UIViewController*)currentLiveController
{
    return _currentLiveController;
}

-(void)setCurrentLiveController:(UIViewController *)currentLiveController
{
    _currentLiveController = currentLiveController;
}

-(NSString*)currentLiveID
{
    return _currentLiveID;
}

-(void)setCurrentLiveID:(NSString *)currentLiveID
{
    _currentLiveID = currentLiveID;
}

@end
