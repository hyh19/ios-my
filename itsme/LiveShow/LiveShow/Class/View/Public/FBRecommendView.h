#import <UIKit/UIKit.h>
#import "FBRecommendModel.h"
#import "FBLiveInfoModel.h"

@class FBRecommendView;

@protocol FBRecommendViewDelegate <NSObject>
- (void)clickDoneButtonToDone;

- (void)clickDoneButtonToLoading;

- (void)pushTAViewControllerWithUid:(NSString *)broadcasterID;

- (void)pushLiveRoomViewControllerWithLiveInfoModel:(FBLiveInfoModel *)liveInfo;

- (void)refreshRecommend;

@end

/**
 *  @author 林思敏
 *  @since 2.0.0
 *  @brief 推荐内容视图
 */

@interface FBRecommendView : UIView

@property (nonatomic, weak) id <FBRecommendViewDelegate> delegate;

@property (strong, nonatomic) NSString *recommendSort;

- (instancetype)init;

- (void)configRecommendListWithModel:(FBRecommendModel *)model;

@end
