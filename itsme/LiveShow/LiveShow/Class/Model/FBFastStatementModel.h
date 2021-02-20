#import <Foundation/Foundation.h>

/**
 *  @author 林思敏
 *  @brief  直播间长按快速发言model
 */

@interface FBFastStatementModel : NSObject

/** 发言的内容 */
@property (strong, nonatomic) NSString *statement;

@property (strong, nonatomic) NSString *statementID;

@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) NSString *country;

@end
