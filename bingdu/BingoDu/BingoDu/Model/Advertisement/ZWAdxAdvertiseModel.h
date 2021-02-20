#import <Foundation/Foundation.h>

/**
 *  @author 林思敏
 *  @brief 氪金广告数据模型
 */

@interface ZWAdxAdvertiseModel : NSObject

/** 广告唯一标识 */
@property (nonatomic, strong) NSString *advId;

/** 点击广告后的行为 */
@property (nonatomic, strong) NSString *advAction;

/** 返回的广告素材类型 */
@property (nonatomic, strong) NSString *advType;

/** html广告代码 */
@property (nonatomic, strong) NSString *advHtml;

/** 广告尺寸（宽*高） */
@property (nonatomic, strong) NSString *advSize;

/** 广告图标URL */
@property (nonatomic, strong) NSString *advIconUrl;

/** 广告文字内容 */
@property (nonatomic, strong) NSString *advContent;

/** 广告标题 */
@property (nonatomic, strong) NSString *advTitle;

/** 广告副标题 */
@property (nonatomic, strong) NSString *advSubtitleLabel;

/** 图片广告时，图片URL */
@property (nonatomic, strong) NSString *advImageUrl;

/** 广告行为图标URL */
@property (nonatomic, strong) NSString *advActionIconUrl;

/** 点击跳转地址 */
@property (nonatomic, strong) NSString *advLink;

/** alink不支持,跳转备用地址URL */
@property (nonatomic, strong) NSString *advFallBack;

///** 原生素材内容 */
//@property (nonatomic, strong) NSString *advNative;

/** 点击监控URL */
@property (nonatomic, strong) NSMutableArray *advEventClick;

/** 展示监控URL */
@property (nonatomic, strong) NSMutableDictionary *advEventShow;

/** 初始化方法 */
- (instancetype)initWithData:(NSDictionary *)dict;

/** 工厂方法 */
+ (instancetype)modelWithData:(NSDictionary *)dict;

@end
