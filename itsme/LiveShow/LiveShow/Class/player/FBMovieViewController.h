//
//  FBMovieViewController.h
//  LiveShow
//
//  Created by chenfanshun on 21/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FBMovieDelegate

-(void)onVideoWidth:(CGFloat)width height:(CGFloat)height;
-(void)onPlayError:(NSError*)error;
-(void)onPlayTimeOut;

-(void)onUpdatePlayState:(BOOL)isPlaying;
-(void)onUpdateProgressWithPosition:(CGFloat)position duration:(CGFloat)duration;

@end


@interface FBMovieViewController : UIViewController

@property(nonatomic, assign)id<FBMovieDelegate> delegate;

- (id) initWithParameters: (NSDictionary *) parameters bouns:(CGRect)frame isRealTime:(BOOL)isRealTime;

-(void) playWithPath:(NSString*)path;

-(void) playWithURL:(NSURL*)url;

-(void) closePlayStream;

-(void) trogglePlay;

-(void) setPlayProgress:(CGFloat)progress;

@end
