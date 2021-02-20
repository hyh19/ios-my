
#import <Foundation/Foundation.h>

@interface ZWLifeStyleChannelItemModel : NSObject

@property (nonatomic, strong)NSNumber *channelID;

@property (nonatomic, copy)NSString *channelName;

@property (nonatomic, copy)NSString *channelImageUrl;

/**实例化频道模型*/
+(id)channelModelFromDictionary:(NSDictionary *)dictionary;

@end
