#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 新闻列表图片model
 */
@interface ZWPicModel : NSObject

/** 图片id */
@property (nonatomic, strong) NSString *picId;

/** 新闻id */
@property (nonatomic, strong) NSString *newsId;

/** 图片标题 */
@property (nonatomic, strong) NSString *picName;

/** 图片地址 */
@property (nonatomic, strong) NSString *picUrl;
/**
 图片索引
 */
@property (nonatomic, assign) NSNumber *picIndex;
/**
 初始化model
 */
+(id)pictureModelFromDictionary:(NSDictionary *)dic;

@end
