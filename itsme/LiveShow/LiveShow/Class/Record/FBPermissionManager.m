//
//  FBPermissionManager.m
//  LiveShow
//
//  Created by chenfanshun on 03/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import "FBPermissionManager.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FBPermissionManager()<UIAlertViewDelegate>

@end

@implementation FBPermissionManager

+(instancetype)shareInstance
{
    static dispatch_once_t predicate;
    static id instance;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}


- (void)checkMicPermissionsWithBlock:(void(^)(BOOL granted))block
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if(!granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLocalizationMircophoneErroTip
                                                                message:kLocalizationMircophoneSettingGuide
                                                               delegate:self
                                                      cancelButtonTitle:kLocalizationOK
                                                      otherButtonTitles:kLocalizationPricySetting, nil];
                alert.delegate = self;
                [alert show];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(block) {
                block(granted);
            }
        });
        
    }];
}

- (void)checkCameraPermissionWithBlock:(void(^)(BOOL granted))block
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (!granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLocalizationCammeraErroTip
                                                                message:kLocalizationCammeraSettingGuide
                                                               delegate:self
                                                      cancelButtonTitle:kLocalizationOK
                                                      otherButtonTitles:kLocalizationPricySetting, nil];
                alert.delegate = self;
                [alert show];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(block) {
                block(granted);
            }
        });
    }];
}

#pragma -mark alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //go to settings
    if(buttonIndex == 1){
        //ios8以上才打开设置
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            return;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
