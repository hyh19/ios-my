#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 九宫格菜单数据模型
 */
@interface ZWMenuModel : NSObject

/** 菜单名 */
@property (nonatomic, copy) NSString *name;

/** 菜单标题 */
@property (nonatomic, copy) NSString *title;

/** 菜单副标题 */
@property (nonatomic, copy) NSString *subtitle;

/** 菜单图标 */
@property (nonatomic, copy) NSString *icon;

/** 菜单角标 */
@property (nonatomic, copy) NSString *cornerMark;

/** 点击菜单要进入的界面 */
@property (nonatomic, copy) NSString *nexViewController;

/** 是否显示菜单，YES-显示，NO-不显示 */
@property (nonatomic, assign) BOOL showMenu;

/** 是否显示菜单角标，YES-显示，NO-不显示 */
@property (nonatomic, assign) BOOL showCornerMark;

/** 初始化 */
- (instancetype)initWithName:(NSString *)name
                       title:(NSString *)title
                    subtitle:(NSString *)subtitle
                        icon:(NSString *)icon
                  cornerMark:(NSString *)cornerMark
          nextViewController:(NSString *)nextViewController
                    showMenu:(BOOL)showMenu
              showCornerMark:(BOOL)showCornerMark;

@end
