#import <Foundation/Foundation.h>

/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 并友热议model
 */
@interface ZWNewsTalkModel : NSObject

/**
 用户头像,URL
 */
@property (nonatomic,strong) NSString *uIcon;

/**
 用户id
 */
@property (nonatomic,strong) NSNumber *userId;

/**
 评论所在的新闻
 */
@property (nonatomic,strong) NSString *newsTitle;

/**
 用户昵称
 */
@property (nonatomic,strong) NSString *nickName;

/**
 时间,服务端转成如1分钟前
 */
@property (nonatomic,strong) NSString *reviewTime;

/**
 时间，13位毫秒数
 */
@property (nonatomic,strong) NSString *reviewTimeIndex;

/**
 评论内容
 */
@property (nonatomic,strong) NSString *comment;

/**
 评论Id
 */
@property (nonatomic,strong) NSNumber *commentId;

/**
 本条评论的点赞数
 */
@property (nonatomic,strong) NSNumber *praiseCount;

/**
 本条评论所在的新闻的点赞数
 */
@property (nonatomic,strong) NSNumber *newsPraiseCount;
/**
 *  新闻类型
 */
@property (nonatomic, retain) NSNumber * newsType;
/**
 *  及时新闻新闻类型
 */
@property (nonatomic, retain) NSNumber * displayType;
/**
 新闻图片url
 */
@property (nonatomic,strong) NSString *newsImagelUrl;

/**
 举报数
 */
@property (nonatomic,strong) NSNumber *reportCount;

 /**
 评论数
 */
@property (nonatomic,strong) NSNumber *commentCount;

/**
 新闻id
 */
@property (nonatomic,strong) NSNumber *newsId;

/**
 频道id
 */
@property (nonatomic,strong) NSNumber *channelId;

/**
 被回复评论的id
 */
@property (nonatomic,strong) NSNumber *parentId;

/**
 是否已赞
 */
@property (nonatomic,assign) BOOL alreadyApproval;

/**
 是否已举报
 */
@property (nonatomic,assign) BOOL alreadyReport;

/**
 判断这条是否有评论
 */
@property (nonatomic,assign) BOOL isHaveReply;

/**
   评论cell的高度
 */
@property (nonatomic,assign) CGFloat cellHeight;

/**
 并友回复cell的高度
 */
@property (nonatomic,assign) CGFloat repley_cellHeight;

/**
 回复某条评论的回复者名字
 */
@property (nonatomic,strong) NSString *reply_comment_name;

/**
 回复某条评论是否是图评
 */
@property (nonatomic,assign) NSInteger  reply_comment_type;

/**
 回复某条评论的回复时间
 */
@property (nonatomic,strong) NSString *reply_comment_time;

/**
 回复某条评论的回复内容
 */
@property (nonatomic,strong) NSString *reply_comment_content;

/**
 新闻的url
 */
@property (nonatomic,strong) NSString *newsDetailUrl;

/**
 是否是最热评论
 */
@property (nonatomic,assign) BOOL isHotComment;
/**
 评论的类型
 0 是普通评论
 1 是图片评论
 */
@property (nonatomic,assign) NSInteger commentType;

/**
 *  构建一个评论model
 *  @param dic        基本信息dic
 *  @param replyDic   回复某条评论的dic
 *  @param newsDic    回复某条评论所在的新闻dic
 *  @param friendDic  回复我得评论的朋友信息dic
 *  @return model
 */
+(id)talkModelFromDictionary:(NSDictionary *)dic
                    replyDic:(NSDictionary*)replyDic
                     newsDic:(NSDictionary*)newsDic
                   friendDic:(NSDictionary*)friendDic;

/**
 *  计算cell的高度
 *  @return  cell的高度
 */
-(CGFloat)calculateCellHeight:(BOOL)isPinlun;

@end
