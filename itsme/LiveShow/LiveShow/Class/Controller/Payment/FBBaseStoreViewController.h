#import "FBBaseTableViewController.h"

/** 冲钻状态 */
typedef NS_ENUM(NSUInteger, FBPurchaseStatus) {
    /** 正在冲钻 */
    kPurchaseStatusProcess,
    /** 冲钻成功 */
    kPurchaseStatusSuccess,
    /** 冲钻失败 */
    kPurchaseStatusFailure
};

/**
 *  @author 黄玉辉
 *
 *  @brief 冲钻界面的基类
 */
@interface FBBaseStoreViewController : FBBaseTableViewController

/** 冲钻方式的名称 */
@property (nonatomic, copy) NSString *storeTitle;

/** 冲钻方式的Logo */
@property (nonatomic, copy) NSString *storeLogo;

/** 列表的高度 */
@property (nonatomic) CGFloat heightForTableView;

/** 不同冲钻状态下的回调函数 */
@property (nonatomic, copy) void (^purchaseCallback)(FBPurchaseStatus status, NSString *message);

/** 刷新数据的回调函数，主要是请求App Store内置购买商品时用到 */
@property (nonatomic, copy) void (^reloadDataCallback)(void);

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

/** 请求添加钻石开始的时间 */
@property (nonatomic) NSTimeInterval requestDiamondBegin;

@end
