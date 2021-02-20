#import <Foundation/Foundation.h>

/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 抽奖详情model
 */
@interface ZWPrizeDetailModel : NSObject
/**
 *  抽奖id
 */
@property(nonatomic,assign) NSInteger  prizeId;
/**
 *  是否有权限抽奖
 */
@property(nonatomic,assign) BOOL isCanPrize;
/**
 *  抽奖介绍图片，用户轮播图
 */
@property(nonatomic,strong) NSArray *prizeImageArray;
/**
 *  奖品介绍
 */
@property(nonatomic,strong) NSString  *prizeIntroduction;
/**
 *  抽奖参与人数
 */
@property(nonatomic,assign) NSInteger  prizeJoinNumber;

/**
 *  抽奖进度上限
 */
@property(nonatomic,assign) NSInteger  prizePregressMaxNumber;
/**
 *  进度信息（显示在进度条上得信息）
 */
@property(nonatomic,strong) NSString  *prizeProgressMsg;

/**
 *  抽奖价格
 */
@property(nonatomic,assign) CGFloat  prizePrice;

/**
 *  用户账号总额
 */
@property(nonatomic,assign) CGFloat  userAllMoney;
/**
 *  抽奖进度
 */
@property(nonatomic,assign) NSInteger  currentPrizeProgress;

/**
 *  抽奖状态
 
 0：结束状态
 1：正常状态
 2：暂停状态
 3: 抢完状态

 */
@property(nonatomic,assign) NSInteger  currentPrizeStatues;
/**
 *  抽奖规则
 */
@property(nonatomic,strong) NSString  *prizeRule;
/**
 *  非法用户提示
 */
@property(nonatomic,strong) NSString  *illegalityUserTip;
/**
 *  奖品名称
 */
@property(nonatomic,strong) NSString  *prizeName;
/**
 *  是否是虚拟物品
 */
@property(nonatomic,assign) BOOL  isVirtualPrize;
/**
 *  抽奖类型
 0：日期开奖
 1：人数开奖
 2：即时开奖
 */
@property(nonatomic,assign) NSInteger  prizeType;
/**
 *  获奖名单
 */
@property(nonatomic,strong) NSMutableArray  *prizewinners;

/**
 *  进度section的height
 */
@property(nonatomic,assign) NSInteger  progressSectionHeight;

/**
 *  奖品介绍section的height
 */
@property(nonatomic,assign) NSInteger  prizeIntrodutionSectionHeight;

/**
 *  奖品介绍section的实际高度
 */
@property(nonatomic,assign) NSInteger  prizeIntrodutionFactSectionHeight;
/**
 *  奖品规则section的height
 */
@property(nonatomic,assign) NSInteger  prizeRuleSectionHeight;
/**
 *  中奖名单section的height
 */
@property(nonatomic,assign) NSInteger  prizeNameListSectionHeight;
/**
 *  标记是否有更多的介绍
 */
@property(nonatomic,assign) BOOL  isMorePrizeIndtroduction;
/**
 *  奖品介绍cell状态 是否展开
 */
@property(nonatomic,assign) BOOL  isPrizeIntroductionExpand;
/**根据奖品信息实例化一个对象*/
+(id)prizeDetailObjByDictionary:(NSDictionary *)dictionary;
@end
