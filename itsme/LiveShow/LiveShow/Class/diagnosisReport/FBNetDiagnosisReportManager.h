//
//  FBNetDiagnosisReportManager.h
//  LiveShow
//
//  Created by chenfanshun on 24/05/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBNetDiagnosisReportManager : NSObject

-(void)diagnosisWithUrl:(NSString*)openLiveUrl
               queryUrl:(NSString*)queryUrl
             querySlaps:(NSInteger)querySlaps
            streamSlaps:(NSInteger)streamSlaps
                 liveid:(NSString*)live_id
            isReconnect:(BOOL)isReconnected;


@end
