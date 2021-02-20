//
//  ViewController.h
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@protocol kxMovieDelegate

-(void)onVideoWidth:(CGFloat)width height:(CGFloat)height;
-(void)onPlayError:(NSError*)error;
-(void)onPlayTimeOut;

-(void)onUpdatePlayState:(BOOL)isPlaying;
-(void)onUpdateProgressWithPosition:(CGFloat)position duration:(CGFloat)duration;
-(void)onBuffer:(NSTimeInterval)bufferTime;

@end

@class KxMovieDecoder;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL

@interface KxMovieViewController : UIViewController

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters bouns:(CGRect)frame;

- (id) initWithParameters: (NSDictionary *) parameters bouns:(CGRect)frame isRealTime:(BOOL)isRealTime;

-(void) playWithPath:(NSString*)path;

-(void) closePlayStream;

-(void) trogglePlay;

-(void) setPlayProgress:(CGFloat)progress;

@property(nonatomic, assign)id<kxMovieDelegate> delegate;
@property (readonly) BOOL playing;

- (void) play;
- (void) pause;

@end
