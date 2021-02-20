#import <UIKit/UIKit.h>

@class ZWNewsTalkModel;
@class ZWBarrageView;

@protocol ZWBarrageViewDelegate <NSObject>

@optional
/**
 点击某条评论进行回复的委托方法
 */
-(void)onTouchBarrageItemWithNewsTalkModel:(ZWNewsTalkModel *)talkModel;

@end

/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 弹幕界面
 */

@interface ZWBarrageView : UIView

/**ZWBarrageViewDelegate的代理*/
@property (nonatomic,assign)id <ZWBarrageViewDelegate> delegate;

/**初始化一个对象*/
- (id)initWithFrame:(CGRect)frame
             newsID:(NSString *)newsID;

//弹幕动画开始指令
- (void)barrageAnimationStart;

/**切换弹幕状态*/
- (void)changeBarrageAnimationSwitchStatus;

/**继续弹幕移动动画*/
- (void)resumeAnimation;

/**暂停弹幕移动的动画*/
- (void)pauseAnimation;

/**插入评论回复对象*/
- (void)insertTalkModel:(ZWNewsTalkModel *)talkModel;

/**还原弹幕原貌*/
- (void)reSetBarrageView:(NSArray *)barrageItems;

@end
