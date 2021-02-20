//
//  FBGAIManager.m
//  LiveShow
//
//  Created by chenfanshun on 13/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBGAIManager.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "FBLoginInfoModel.h"

#define OLD_TRACKINGID          @"UA-74656459-3"
#define NEW_RELEASE_TRACKINGID  @"UA-74656459-7"
#define NEW_DEBUG_TRACKINGID    @"UA-77946873-1"

// 充值失败上报id
#define CHARGEERRO_TRACKINGID   @"UA-74656459-8"

@implementation FBGAIManager

-(void)ga_sendScreenHit:(NSString*)screenName
{
#ifndef DEBUG
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:OLD_TRACKINGID];
    [tracker set:kGAIDescription value:screenName];
    
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if(0 == [userID length]) {
        userID = @"0";
    }
    [tracker set:kGAIUserId value:userID];
    
    GAIDictionaryBuilder* screenHit = [GAIDictionaryBuilder createScreenView];
    [tracker send:[screenHit build]];
    [[GAI sharedInstance] dispatch];
#endif
}

-(void)ga_sendEvent:(NSString*)category action:(NSString*)action label:(NSString*)label value:(NSNumber *)value
{
#ifndef DEBUG
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:OLD_TRACKINGID];
    
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if(0 == [userID length]) {
        userID = @"0";
    }
    [tracker set:kGAIUserId value:userID];
    
    GAIDictionaryBuilder* eventHit = [GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value];
    [tracker send:[eventHit build]];
    [[GAI sharedInstance] dispatch];
#endif
}

-(void)ga_sendTime:(NSString*)category intervalMillis:(int)intervalMillis name:(NSString*)name label:(NSString *)label
{
#ifndef DEBUG
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:OLD_TRACKINGID];
    
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if(0 == [userID length]) {
        userID = @"0";
    }
    [tracker set:kGAIUserId value:userID];
    
    GAIDictionaryBuilder* timeHit = [GAIDictionaryBuilder createTimingWithCategory:category interval:[NSNumber numberWithInt:intervalMillis] name:name label:label];
    
    [tracker send:[timeHit build]];
    [[GAI sharedInstance] dispatch];
#endif
}


@end



@implementation FBNewGAIManager

-(void)ga_sendScreenHit:(NSString*)screenName
{
#ifdef DEBUG
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:NEW_DEBUG_TRACKINGID];
#else
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:NEW_RELEASE_TRACKINGID];
#endif
    
    [tracker set:kGAIDescription value:screenName];
    
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if(0 == [userID length]) {
        userID = @"0";
    }
    [tracker set:kGAIUserId value:userID];
    
    GAIDictionaryBuilder* screenHit = [GAIDictionaryBuilder createScreenView];
    [tracker send:[screenHit build]];
    [[GAI sharedInstance] dispatch];
}

-(void)ga_sendEvent:(NSString*)category action:(NSString*)action label:(NSString*)label value:(NSNumber *)value
{
#ifdef DEBUG
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:NEW_DEBUG_TRACKINGID];
#else
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:NEW_RELEASE_TRACKINGID];
#endif
    
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if(0 == [userID length]) {
        userID = @"0";
    }
    [tracker set:kGAIUserId value:userID];
    
    GAIDictionaryBuilder* eventHit = [GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value];
    [tracker send:[eventHit build]];
    [[GAI sharedInstance] dispatch];
}

-(void)ga_sendTime:(NSString*)category intervalMillis:(int)intervalMillis name:(NSString*)name label:(NSString *)label
{
#ifdef DEBUG
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:NEW_DEBUG_TRACKINGID];
#else
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:NEW_RELEASE_TRACKINGID];
#endif
    
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if(0 == [userID length]) {
        userID = @"0";
    }
    [tracker set:kGAIUserId value:userID];
    
    GAIDictionaryBuilder* timeHit = [GAIDictionaryBuilder createTimingWithCategory:category interval:[NSNumber numberWithInt:intervalMillis] name:name label:label];
    
    [tracker send:[timeHit build]];
    [[GAI sharedInstance] dispatch];
}

- (void)ga_sendChargeFailure:(NSString *)receipt {
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"itsme"
                                                        trackingId:CHARGEERRO_TRACKINGID];

    
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if(0 == [userID length]) {
        userID = @"0";
    }
    [tracker set:kGAIUserId value:userID];
    
    GAIDictionaryBuilder *eventHit = [GAIDictionaryBuilder createEventWithCategory:CATEGORY_RECHARGE_STATITICS action:@"充值失败" label:userID value:@(1)];
    [tracker send:[[eventHit set:receipt forKey:kGAIExDescription] build]];
    [[GAI sharedInstance] dispatch];
}

@end
