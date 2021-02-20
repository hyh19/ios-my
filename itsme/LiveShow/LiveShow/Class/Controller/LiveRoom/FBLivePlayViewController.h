#import "FBLiveBaseViewController.h"
#import "FBLiveBaseViewController+Guide.h"
#import "FBLiveInfoModel.h"

@interface FBLivePlayViewController : FBLiveBaseViewController

/** 直播信息 */
@property (nonatomic, strong) FBLiveInfoModel *liveInfo;

-(id)initWithModel:(FBLiveInfoModel*)model;

-(void)startPlay;

-(void)endPlay;

@end
