#import <Foundation/Foundation.h>

@class ChannelItem;

/**
 *  @author 陈新存
 *  @ingroup utility
 *  @brief 频道数据逻辑处理类
 */
@interface ZWChannelDataManager : NSObject

/** 未选择的频道数据列表 */
@property (nonatomic, strong)NSMutableArray *unSelectedChannelList;

/** 已选择的频道数据列表 */
@property (nonatomic, strong)NSMutableArray *selectedChannelList;

/**类实例共享*/
+ (instancetype)sharedInstance;

/**
 *  刷新本地频道
 *  @param success 成功回调
 */
-(void)refreshLocalChannelWithSuccess:(void (^)())success;

/**
 *  加载用户自定义的本地频道ID列表
 *  @param dataSource 频道数据
 */
- (NSArray *)localChannelDataWithDataSource:(NSArray *)dataSource;

/**
 *  存储用户自定义的频道ID
 *  @param dataSource 频道数据
 */
- (void)saveChannelData:(NSArray *)dataSource;

/**
 *  过滤频道数据，筛选出已选频道与未选频道
 *  @param dataSource 频道数据
 */
- (void)filterChannelData:(NSArray *)dataSource;

/**
 *  添加缓存的地方频道
 *  @param dataSource 频道数据
 */
- (void)addLocalChannel;

/**
 *  跟新本地地方频道选择状态
 *  @param state 选择状态
 *  @param dataSource 频道数据
 */
- (void)updataLocalChannelSelectedState:(BOOL)state
                            channelName:(NSString *)channelName;

/**
 *  获取用户自定义频道列表
 *  @param finish 成功获取后的回调block
 */
- (void)loadCustomChannel:(void (^)(BOOL successed))finish;

/**
 *  更新本地存储的自定义频道列表
 */
- (void)updataLocalChannelList;

/**
 *  上传自定义频道列表到服务器
 */

- (void)uploadCustomChannelList;

/**
 *  检查app版本以及频道版本信息
 *  @param success 成功获取后的回调block
 */
- (void)checkVersion:(void (^)(BOOL successed))success;

/**
 *  获取本地所有频道数据
 */
-(NSMutableArray *)queryChannelData;

/**
 *  插入数据
 */
-(void)addChannelListDataWithNSArray:(NSArray *)dataSource;

/**
 *  删除数据
 */
-(void)deleteChannelListData;

/**
 *  根据频道名字找出频道ID
 */
-(ChannelItem *)queryChannelDataWithChannelName:(NSString *)channelName;

@end
