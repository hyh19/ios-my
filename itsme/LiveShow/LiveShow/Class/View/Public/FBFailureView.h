#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉
 *  @brief 默认错误页
 */

typedef void (^FBFailViewBlock)(void);

@interface FBFailureView : UIView

/** 提示图片 */
@property (nonatomic, copy) NSString *image;

/** 提示信息 */
@property (nonatomic, copy) NSString *message;

/** 详情信息 */
@property (nonatomic, copy) NSString *detail;

/** 按钮文本 */
@property (nonatomic, copy) NSString *buttonTitle;

/** 高度 */
@property (nonatomic, assign) CGFloat *height;

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame image:(NSString *)image message:(NSString *)message;

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame
                        image:(NSString *)image
                      message:(NSString *)message
                        event:(void (^)(void))event;

/**
 *  带有图片、提示和详情的初始化
 *
 *  @param frame   大小
 *  @param image   图片名称
 *  @param message 提示信息
 *  @param detail  详情信息
 *
 *  @return self
 */
- (instancetype)initWithFrame:(CGRect)frame
                        image:(NSString *)image
                      message:(NSString *)message
                       detail:(NSString *)detail;


/**
 *  带有图片、高度、提示、详情和按钮的初始化
 *
 *  @param frame       大小
 *  @param image       图片名称
 *  @param height      图片距离顶部的高度（有120的高度）
 *  @param message     提示信息
 *  @param detail      详情信息
 *  @param buttonTitle 按钮文本
 *  @param event       点击事件
 *
 *  @return self
 */
- (instancetype)initWithFrame:(CGRect)frame
                        image:(NSString *)image
                       height:(CGFloat)height
                      message:(NSString *)message
                       detail:(NSString *)detail
                  buttonTitle:(NSString *)buttonTitle
                        event:(void (^)(void))event;

@end
