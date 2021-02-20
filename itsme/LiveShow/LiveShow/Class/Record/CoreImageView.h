//
//  CoreImageView.h
//  EAudioKit
//
//  Created by zhou on 15/11/18.
//  Copyright © 2015年 rcsing. All rights reserved.
//

#import <GLKit/GLKit.h>

/** 用于视频预览的渲染*/
@interface CoreImageView : GLKView

- (instancetype)initWithFrame:(CGRect)frame;
- (void)updateImage:(CIImage *)image;

/**
 *  获取最后一帧
 *
 *  @return <#return value description#>
 */
-(CIImage*)getLastFrame;

@end
