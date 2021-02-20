#ifndef Constant_Device_h
#define Constant_Device_h

#pragma mark - System version -

/** 操作系统版本等于 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

/** 操作系统版本大于 */
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

/** 操作系统版本大于等于 */
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

/** 操作系统版本小于 */
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

/** 操作系统版本小于等于 */
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#pragma mark - Measurement -

/** 屏幕宽度 */
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

/** 屏幕高度 */
#define SCREEN_HEIGH ([UIScreen mainScreen].bounds.size.height)

/** 状态栏的高度 */
#define STATUS_BAR_HEIGHT 20

/** 导航栏的高度 */
#define NAVIGATION_BAR_HEIGHT 44

/** 标签栏的高度 */
#define SEGMENT_BAR_HEIGHT ([[UIScreen mainScreen] isFiveFivePhone]? 40 : 34)

/** 底部标签栏的高度 */
#define TAB_BAR_HEIGHT 49

#endif
