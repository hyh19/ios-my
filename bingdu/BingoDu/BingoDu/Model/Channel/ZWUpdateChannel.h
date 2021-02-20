#import <Foundation/Foundation.h>

/**
 *  @author 陈新存
 *
 *  更新频道列表数据模型
 */
@interface ZWUpdateChannel : NSObject

/**频道数据列表*/
@property (nonatomic, strong)NSArray *channelList;

/**频道版本号*/
@property (nonatomic, strong)NSString *channelVersion;

/**实例共享*/
+ (instancetype)sharedInstance;

/**检测频道是否有更新*/
- (void)checkChannelSuccessWithResult:(id)result;

@end
