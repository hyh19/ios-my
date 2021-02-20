#import <UIKit/UIKit.h>

@class ZWMessageFrame;

/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 意见反馈消息
 */
@interface ZWMessageCell : UITableViewCell

/**消息frame，记录每条消息的坐标信息*/
@property (nonatomic, strong) ZWMessageFrame *messageFrame;

@end

@class ZWMessageModel;

#define kMargin 10 //间隔
#define kIconWH 40 //头像宽高
#define kContentW [[UIScreen mainScreen] applicationFrame].size.width-140 //内容宽度

#define kTimeMarginW 10 //时间文本与边框间隔宽度方向
#define kTimeMarginH 10 //时间文本与边框间隔高度方向

#define kContentTop 10 //文本内容与按钮上边缘间隔
#define kContentLeft 15 //文本内容与按钮左边缘间隔
#define kContentBottom 10 //文本内容与按钮下边缘间隔
#define kContentRight 10 //文本内容与按钮右边缘间隔

#define kTimeFont [UIFont systemFontOfSize:12] //时间字体
#define kContentFont [UIFont systemFontOfSize:16] //内容字体

/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 记录每条消息的坐标信息
 */
@interface ZWMessageFrame : NSObject

/**用户头像的frame*/
@property (nonatomic, assign, readonly) CGRect iconFrame;
/**消息发送时间的frame*/
@property (nonatomic, assign, readonly) CGRect timeFrame;
/**消息内容文本的frame*/
@property (nonatomic, assign, readonly) CGRect contentFrame;
/**tableviewCell的高度*/
@property (nonatomic, assign, readonly) CGFloat cellHeight;
/**消息model*/
@property (nonatomic, strong) ZWMessageModel *message;
/**是否需要显示发送时间或者接收时间*/
@property (nonatomic, assign) BOOL showTime;

@end

