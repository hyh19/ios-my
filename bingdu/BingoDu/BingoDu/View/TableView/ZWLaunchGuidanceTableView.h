#import <UIKit/UIKit.h>

@class ZWLaunchGuidanceTableView;

@protocol ZWLaunchGuidanceTableViewDelegate <NSObject>

- (void)didSelectItemsWithList:(NSArray *)selectItems;

@end

@interface ZWLaunchGuidanceTableView : UITableView

@property (nonatomic, weak) id<ZWLaunchGuidanceTableViewDelegate>tableViewDelegate;

- (void)loadLocalLifeStyleDataSource;

@end
