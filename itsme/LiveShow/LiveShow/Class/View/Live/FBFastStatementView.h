#import <UIKit/UIKit.h>

@protocol FBFastStatementViewDelegate <NSObject>

- (void)changButton;

@end

/**
 *  @author 林思敏
 *  @brief  直播间长按快速发言视图
 */

@interface FBFastStatementView : UIView

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *statementArray;

@property (nonatomic, weak) id <FBFastStatementViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andIdentityCategory:(NSString *)identityCategory;

@end
