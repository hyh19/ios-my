//
//  FBIJKMoiveViewController.h
//  LiveShow
//
//  Created by chenfanshun on 12/09/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJKFFMoviePlayerController.h"

@protocol FBIJKMovieDelegate

-(void)onVideoWidth:(CGFloat)width height:(CGFloat)height;
-(void)onPlayError:(NSError*)error;
-(void)onPlayTimeOut;

-(void)onUpdatePlayState:(BOOL)isPlaying;
-(void)onUpdateProgressWithPosition:(CGFloat)position duration:(CGFloat)duration;

@end

@interface FBIJKMoiveViewController : UIViewController

@property(nonatomic, assign)id<FBIJKMovieDelegate> delegate;

- (id) initWithParameters: (NSDictionary *) parameters bouns:(CGRect)frame isRealTime:(BOOL)isRealTime;

-(void) playWithPath:(NSString*)path;

-(void) pause;

-(void) play;

-(void) closePlayStream;

@end
