#import <UIKit/UIKit.h>

/** 加载提示所在的界面类型，主要分为一般的界面和并友、收藏等小界面 */
typedef NS_ENUM(NSUInteger, ZWLoadingParentType){
    /** 一般界面 */
    kLoadingParentTypeDefault = 0,
    
    /** 并友、收藏等小界面 */
    kLoadingParentTypeSmall = 1,
};

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief 正在加载控件
 *  @ingroup view
 */
@interface ZWLoadingView : UIView

- (instancetype)initWithFrame:(CGRect)frame andType:(ZWLoadingParentType)type;

@end
