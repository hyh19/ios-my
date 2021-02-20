#import <UIKit/UIKit.h>
#import "ZWNewsModel.h"

@class ZWNewsBottomBar;

/**
 底部bar类型
 */
typedef NS_ENUM(NSUInteger, ZWBottomBarTye) {
    ZWNesDetail,        //新闻详情底部bar
    ZWLive,             //直播底部bar
    ZWNewsComment,      //最新评论底部bar
    ZWVideo,      //视频
};
/** bottombar的代理*/
@protocol ZWNewsBottomBarDelegate <NSObject>
@optional
/**
  返回rootViewController
 */
-(void)onTouchButtonBackByBottomBar:(ZWNewsBottomBar *)bar;

/**
 点击分享按钮回调方法
 */
-(void)onTouchButtonShareByBottomBar:(ZWNewsBottomBar *)bar;
/**
  点击发送按钮回调方法
 */
-(void)onTouchButtonSend:(ZWNewsBottomBar *)bar;
/**
 点击评论按钮的回调
 */
-(void)onTouchButtonComment:(ZWNewsBottomBar *)bar;
/**
 根据积分情况弹出提示登录框的回调方法
 */
-(void)loadLoginViewByLikeOrHate:(ZWNewsBottomBar *)bar;
/**
  直播弹幕开关的回调
 */
-(void)onTouchButtonBarrage:(ZWNewsBottomBar *)bar;
/**
 开始发表的发表评论的回调
 */
-(void)onTouchCommentTextField:(ZWNewsBottomBar *)bar;
@end

/**
 *  @brief 新闻详情底部状态栏模块
 *  @ingroup view
 *  @auther 刘云鹏
 */
@interface ZWNewsBottomBar : UIView<UITextFieldDelegate>

/**
 数据model
 */
@property (nonatomic,strong)ZWNewsModel *newsModel;
/**
 评论输入框
 */
@property (nonatomic,strong)UITextField *enter;
/**
 底部整体视图
 */
@property (nonatomic,strong)UIView *bottomBar;
/**
 赞数label
 */
@property (nonatomic,strong)UILabel *likeLbl;
/**
 评论数label
 */
@property (nonatomic,strong)UILabel *commentNumLable;
/**
 返回按钮
 */
@property (nonatomic,strong)UIButton *backBtn;
/**
 分享按钮
 */
@property (nonatomic,strong)UIButton *shareBtn;
/**
 赞按钮
 */
@property (nonatomic,strong)UIButton *likeBtn;
/**
 发送按钮
 */
@property (nonatomic,strong)UIButton *sendBtn;
/**
 评论按钮
 */
@property (nonatomic,strong)UIButton *commentBtn;

/**
 textfield 的宽度
 */
@property (nonatomic,assign)float sumWidth;
/**
 根据输入框来 标示当前bar的位置（上/下）
 */
@property (nonatomic,assign)BOOL up;

/**
 底部栏类型
 */
@property (nonatomic,assign)ZWBottomBarTye bottomBarType;

/**
 botttombar的代理
*/
@property (nonatomic,assign)id <ZWNewsBottomBarDelegate> delegate;
/**
 构建 botttombar
 */
-(void)addbottomBar;
/**
 bottombar is enable
 */
-(void)enableBottomBar:(BOOL)enable;
@end
