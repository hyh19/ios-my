//
//  FBNetDiagnosisReportManager.m
//  LiveShow
//
//  Created by chenfanshun on 24/05/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBNetDiagnosisReportManager.h"
#import "FBNetDiagnosisUnit.h"

@interface FBNetDiagnosisReportManager()<FBNetDiagnosisReportDelegate>

@property(nonatomic, strong) NSMutableArray *arrayItems;
@property(nonatomic, assign) NSInteger      index;

@end

@implementation FBNetDiagnosisReportManager

-(id)init
{
    if(self = [super init]) {
        self.arrayItems = [[NSMutableArray alloc] init];
        self.index = 0;
    }
    return self;
}

-(void)diagnosisWithUrl:(NSString*)openLiveUrl
               queryUrl:(NSString*)queryUrl
             querySlaps:(NSInteger)querySlaps
            streamSlaps:(NSInteger)streamSlaps
                 liveid:(NSString*)live_id
            isReconnect:(BOOL)isReconnected
{
    FBNetDiagnosisUnit *unit = [[FBNetDiagnosisUnit alloc] initWithUrl:openLiveUrl queryUrl:queryUrl querySlaps:querySlaps streamSlaps:streamSlaps liveid:live_id isReconnect:isReconnected index:self.index andDelegate:self];
    [unit starDiagnosis];
    
    [self.arrayItems addObject:unit];
    
    self.index++;
    NSLog(@"diagnosis count: %zd", self.index);
}

-(void)onEndDiagnosis:(NSInteger)index;
{
    for(NSInteger i = 0; i < [self.arrayItems count]; i++)
    {
        FBNetDiagnosisUnit *unit = self.arrayItems[i];
        if(unit.index == index) {
            unit = nil;
            [self.arrayItems removeObjectAtIndex:i];
            NSLog(@"diagnosis release on index: %zd", i);
            break;
        }
    }
}


@end
