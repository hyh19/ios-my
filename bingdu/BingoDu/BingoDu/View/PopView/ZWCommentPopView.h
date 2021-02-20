#import <UIKit/UIKit.h>

/**
 按钮的宽度
 */
#define btnWidth  89
/**
 点击类型枚举
 */
typedef NS_ENUM (NSUInteger,ZWClickType)
{
    ZWClickReply,  //回复
    ZWClickGood,   //赞
    ZWClickReport, //举报
    ZWClickReadOldAriticle, //查看原文
};

/**
   回复类型枚举
 */
typedef NS_ENUM (NSUInteger,ZWPopviewType)
{
    ZWPopviewNewsDetail,  //新闻详情的popview
    ZWPopviewBinyouReply,   //并友的回复popview
};

/**
  点击回调block
 */
typedef void (^btnClicked)(ZWClickType clickType);

/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 点击评论弹出的view
 */



@interface ZWCommentPopView : UIView

/**
 *  用户选择的回调
 */
@property(nonatomic,copy)btnClicked btnClickBlock;

/**
 *  弹出视图的类型
 */
@property(nonatomic,assign) ZWPopviewType popViewType;

/**
 *  初始化view
 *  @param frame         view的大小
 *  @param btnClickBlock blcok回调
 *  @return view
 */
-(id)initWithFrame:(CGRect)frame  popViewType:(ZWPopviewType)popViewType callBack:(btnClicked) btnClickBlock;

/**
 *  改变button的状态
 *  @param btnType button的类型
 */
-(void)changeBtnState:(ZWClickType) btnType  value:(BOOL)isSelected;

@end
