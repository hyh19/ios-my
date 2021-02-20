//
//  FBGuideCollectionViewCell.m
//  LiveShow
//
//  Created by chenfanshun on 09/11/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLaunchGuideCollectionViewCell.h"

@implementation FBLaunchGuideCollectionViewCell

- (instancetype)init {
    if (self = [super init]) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.layer.masksToBounds = YES;
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.imageView = [[UIImageView alloc]initWithFrame:bounds];
    self.imageView.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.hidden = YES;
    [button setFrame:CGRectMake(0, 0, 200, 44)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.layer setCornerRadius:5];
    [button.layer setBorderColor:[UIColor whiteColor].CGColor];
    [button.layer setBorderWidth:1.0f];
    [button setBackgroundColor:[UIColor clearColor]];
    
    self.button = button;
    
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.button];
    
    [self.button setCenter:CGPointMake(bounds.size.width / 2, bounds.size.height - 100)];
}


@end
