

#import <Foundation/Foundation.h>

@interface ZWLifeStyleModel : NSObject

@property (nonatomic, copy)NSString *imageName;

@property (nonatomic, copy)NSString *name;

@property (nonatomic, strong)NSNumber *boyID;

@property (nonatomic, strong)NSNumber *girlID;

/**实例化模型*/
+(id)loadModelFromDictionary:(NSDictionary *)dictionary;

@end
