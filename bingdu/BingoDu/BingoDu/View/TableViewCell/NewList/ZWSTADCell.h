#import "ZWNewsModel.h"
#import "ZWNewsBaseCell.h"
#import "STObject.h"

@class ZWSTADCell;

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup protocol
 *  @brief 时趣移动广告显示状态的委托
 */
@protocol ZWSTADCellDelegate <NSObject>

/** 处理时趣移动广告显示状态的回调，没有广告返回时不显示 */
- (void)STADCell:(ZWSTADCell *)cell displayed:(BOOL)displayed;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 时趣移动广告
 */
@interface ZWSTADCell : ZWNewsBaseCell

/** 时趣广告数据 */
@property (nonatomic, strong, readonly) STObject *STObj;

/** 时趣移动广告显示状态的委托 */
@property (nonatomic, weak) id<ZWSTADCellDelegate> delegate;

/** 高度 */
+ (CGFloat)height;

@end
