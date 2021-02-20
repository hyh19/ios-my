#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉
 *  @brief 等级控件
 */
@interface FBLevelView : UIView

/** 等级 */
@property (nonatomic, assign) NSInteger level;

/** 背景 */
@property (nonatomic, strong) UIImageView *background;

/** 初始化 */
- (instancetype)initWithLevel:(NSInteger)level;

@end
