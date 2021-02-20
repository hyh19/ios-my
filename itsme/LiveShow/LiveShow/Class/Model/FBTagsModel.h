#import <Foundation/Foundation.h>

/**
 *  @author 李世杰
 *  @brief  tag标签
 */
@interface FBTagsModel : NSObject

/** 标签名字 */
@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSNumber *num;

@property (nonatomic, strong) NSNumber *live_num;

@property (nonatomic, strong) NSNumber *record_num;

@property (nonatomic, strong) NSArray *record;

@property (nonatomic, copy) NSString *country;

@property (nonatomic, copy) NSArray *lives;

@property (nonatomic, assign) CGFloat cellHeight;

@end
