//
//  SCNavTabBarController.h
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//
#define DOT_COORDINATE 0
#define SCREEN_WIDTH                    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                   ([UIScreen mainScreen].bounds.size.height)
#define ARROW_BUTTON_WIDTH  35
#define NAV_TAB_BAR_HEIGHT              ARROW_BUTTON_WIDTH

#define STATUS_BAR_HEIGHT               20.0f
#define BAR_ITEM_WIDTH_HEIGHT           30.0f
#define NAVIGATION_BAR_HEIGHT           44.0f
#define SCNavTabbarBundleName           @"SCNavTabBar.bundle"
#define SCNavTabbarSourceName(file) [SCNavTabbarBundleName stringByAppendingPathComponent:file]

#define NavTabbarColor                  UIColorWithRGBA(255.0f, 255.0f, 255.0f, 1.0f)
#define UIColorWithRGBA(r,g,b,a)        [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]


#import <UIKit/UIKit.h>

@class SCNavTabBar;

/**
 *  @author 黄玉辉->陈梦杉
 *
 */
@interface SCNavTabBarController : UIViewController

@property (nonatomic, assign) BOOL        showArrowButton;            // Default value: YES
@property (nonatomic, assign) BOOL        scrollAnimation;            // Default value: NO
@property (nonatomic, assign) BOOL        mainViewBounces;            // Default value: NO

@property (nonatomic, strong) NSMutableArray     *subViewControllers;        // An array of children view controllers

@property (nonatomic, strong) UIColor     *navTabBarColor;            // Could not set [UIColor clear], if you set, NavTabbar will show initialize color
@property (nonatomic, strong) UIColor     *navTabBarLineColor;
@property (nonatomic, strong) UIImage     *navTabBarArrowImage;
@property (nonatomic, strong) SCNavTabBar *navTabBar;

@property (nonatomic, strong) void(^scrollController)(void);

/**
 *  Initialize Methods
 *
 *  @param show - is show the arrow button
 *
 *  @return Instance
 */
- (id)initWithShowArrowButton:(BOOL)show;

/**
 *  Initialize SCNavTabBarViewController Instance And Show Children View Controllers
 *
 *  @param subViewControllers - set an array of children view controllers
 *
 *  @return Instance
 */
- (id)initWithSubViewControllers:(NSMutableArray *)subViewControllers;

/**
 *  Initialize SCNavTabBarViewController Instance And Show On The Parent View Controller
 *
 *  @param viewController - set parent view controller
 *
 *  @return Instance
 */
- (id)initWithParentViewController:(UIViewController *)viewController;

/**
 *  Initialize SCNavTabBarViewController Instance, Show On The Parent View Controller And Show On The Parent View Controller
 *
 *  @param subControllers - set an array of children view controllers
 *  @param viewController - set parent view controller
 *  @param show           - is show the arrow button
 *
 *  @return Instance
 */
- (id)initWithSubViewControllers:(NSMutableArray *)subControllers andParentViewController:(UIViewController *)viewController showArrowButton:(BOOL)show;

/**
 *  Show On The Parent View Controller
 *
 *  @param viewController - set parent view controller
 */
- (void)addParentController:(UIViewController *)viewController;

- (void)channelChangeAtIndex:(NSInteger)index;
- (void)insertViewController:(UIViewController *)viewController;

/**
 *  @author 黄玉辉->陈梦杉
 *
 *  @brief  获取当前视图控制器
 */
- (UIViewController *)currentViewController;

@end

