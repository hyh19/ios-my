#import <UIKit/UIKit.h>

@class FBTopTagsView;

@protocol FBTopTagsViewDelegate <NSObject>
- (void)getAllTagsList;
- (void)pushTagListViewControllerWithTag:(NSString *)tag;

@end

/**
 *  @author 林思敏
 *  @brief 最新列表顶部Tags view
 */

@interface FBTopTagsView : UIView

@property (nonatomic, weak) id <FBTopTagsViewDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *tagArrays;

@end
