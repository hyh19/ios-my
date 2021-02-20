//
//  FBNetDiagnosisUnit.h
//  LiveShow
//
//  Created by chenfanshun on 28/06/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FBNetDiagnosisReportDelegate <NSObject>

-(void)onEndDiagnosis:(NSInteger)index;

@end

@interface FBNetDiagnosisUnit : NSObject

@property(nonatomic, assign)NSInteger index;

-(id)initWithUrl:(NSString*)openLiveUrl
        queryUrl:(NSString*)queryUrl
      querySlaps:(NSInteger)querySlaps
     streamSlaps:(NSInteger)streamSlaps
          liveid:(NSString*)live_id
     isReconnect:(BOOL)isReconnected
           index:(BOOL)index
     andDelegate:(id<FBNetDiagnosisReportDelegate>)delegate;

-(void)starDiagnosis;

@end
