
#import <Foundation/Foundation.h>
/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 图评的model
 */
@interface ZWImageCommentModel : NSObject

/**
 所有图评信息
 */
@property (nonatomic, strong) NSMutableDictionary *imageCommentList;
/**
 评论图片url
 */
@property (nonatomic, strong) NSString *commentImageUrl;
/**
 评论id
 */
@property (nonatomic, strong) NSString *commmentImageId;

/**
 图评是否已经显示
 */
@property (nonatomic, assign) BOOL isAlreadyShow;
/**
 图评位置是否超出了图片的界限
 */
@property (nonatomic, assign) BOOL isExceedBoundary;

/**
 评论x坐标百分比
 */
@property (nonatomic, assign) CGFloat xPercent;
/**
 评论y坐标百分比
 */
@property (nonatomic, assign) CGFloat yPercent;
/**
 评论x坐标
 */
@property (nonatomic, assign) CGFloat x;
/**
 评论y坐标
 */
@property (nonatomic, assign) CGFloat y;

/**
 评论所在图片x坐标
 */
@property (nonatomic, assign) CGFloat image_x;
/**
 评论所在图片y坐标
 */
@property (nonatomic, assign) CGFloat image_y;

/**
 评论所在图片宽度
 */
@property (nonatomic, assign) CGFloat image_width;
/**
 评论所在图片高度
 */
@property (nonatomic, assign) CGFloat image_height;


/**
 当前webview的contentOffsetY
 */
@property (nonatomic, assign) CGFloat webViewOffsetY;

/**
 评论图片所在的新闻新闻id
 */
@property (nonatomic, strong) NSString *newsId;
/**
 评论图片的用户id
 */
@property (nonatomic, strong) NSString *userId;
/**
 评论图片的内容
 */
@property (nonatomic, strong) NSString *commentImageComment;
/**
 初始化model
 */
+(id)imageCommentModelFromDictionary:(NSDictionary *)dic;
@end
