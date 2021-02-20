//
//  DAKeyboardControl.h
//  DAKeyboardControlExample
//
//  Created by Daniel Amitay on 7/14/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DAKeyboardDidMoveBlock)(CGRect keyboardFrameInView);
typedef void (^DAKeyboardDidCompleteBlock)(BOOL finished, BOOL isShowing, BOOL isFromPan);

@interface  ZWKeyBoardManager : NSObject

@property (nonatomic) CGFloat keyboardTriggerOffset;

- (void)addKeyboardPanningWithActionHandler:(DAKeyboardDidMoveBlock)didMoveBlock view:(UIView*)keyManagerView;
- (void)addKeyboardNonpanningWithActionHander:(DAKeyboardDidMoveBlock)didMoveBlock view:(UIView*)keyManagerView;
- (void)addKeyboardCompletionHandler:(DAKeyboardDidCompleteBlock)didMoveBlock view:(UIView*)keyManagerView;

- (void)removeKeyboardControl;

- (CGRect)keyboardFrameInView;

@end