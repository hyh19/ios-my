#import <Foundation/Foundation.h>

/**
 点击回调block
 */
typedef void (^uionAdvertiseUrl)(NSString *url, NSString *clickUrl,NSString *title, NSArray *impressionUrl,NSArray*clickMonitorUrl);
/**
 *  @author 刘云鹏
 *  @ingroup network
 *  @brief 网盟广告
 */
@interface ZWNetworkUnioAdvertiseManager : NSObject
/** 初始化对像 */
-(id)initUionWithUlr:(NSString*)urlString callBack:(uionAdvertiseUrl) adverTiseUrl;
/** 网盟广告对象地址 */
@property(nonatomic,strong)NSString *urlString;
/** 网盟广告回调block */
@property(nonatomic,copy)uionAdvertiseUrl urlCallBack;
@end
