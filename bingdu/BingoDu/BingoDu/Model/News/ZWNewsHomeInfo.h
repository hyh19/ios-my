#warning 没有用到啊  后续再检查下
#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 补充注释
 */
@interface ZWNewsHomeInfo : NSObject
@property (nonatomic,strong) NSString *newsTitle;
@property (nonatomic,strong) NSMutableArray *newsImgUrls;
@property (nonatomic,strong) NSString *newsTime;
@property (nonatomic,strong) NSString *newsLikeNumbers;
@property (nonatomic,strong) NSString *newsReviewNumbers;
@property (nonatomic,strong) NSString *newsPlatform;
@property (nonatomic,assign) int newsType;//每条新闻后台返回需有模型标示

+(id)newsInfoBy:(NSMutableDictionary *)dic;

@end
