#import <UIKit/UIKit.h>
#import "ZWImageCommentModel.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup view
 *  @brief 新闻详情里大图模式中单张图片的控件
 */
@interface ZWImageScrollView : UIScrollView

/** 是否下载成功的标示 */
@property (nonatomic,assign)BOOL downLoadFinished;
/** 是否是直播类型 */
@property (nonatomic,assign)BOOL isLiveNews;

/** 图片视图 */
@property (nonatomic,strong)UIImageView *imgView;

/** 设置图片内容尺寸 */
- (void) setContentWithFrame:(CGRect) rect;

/** 设置图片地址 */
- (void) setImageUrl:(NSString *) imageUrl;

/** 新闻id */
@property(nonatomic,strong)NSString *newsId;

/** 这张图片的图评数据 */
@property (nonatomic,strong)NSMutableArray *commmentModelArray;

/**
 保存图评过的图片
 */
@property(nonatomic,strong)NSMutableArray *imageCommentDetailChange;

/** 是否需要图评 */
@property (nonatomic,assign)BOOL isNeedImagaComment;

/** 复原图片大小 */
- (void) rechangeInitRdct;

@end
