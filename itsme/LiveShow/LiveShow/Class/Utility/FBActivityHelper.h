#import <Foundation/Foundation.h>

/**
 *  @author 林思敏
 *  @brief  活动礼物相关压缩包
 */

@interface FBActivityHelper : NSObject

+ (void)downloadZipFileForActivity:(NSString *)activity completionBlock:(void(^)(void))completion;

+ (NSArray *)filesWithActivity:(NSString *)activit;

+ (NSDictionary *)filesWithActivityText:(NSString *)activit;

@end
