#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ASIDownloadCache.h"
#import "WXApi.h"
#import "ZWTabBarController.h"

@class Reachability;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    enum WXScene _scene;
}

@property (strong, nonatomic) UIWindow *window;
//是否允许屏幕旋转
@property (assign, nonatomic) BOOL isAllowRotation;
//视频是否全屏
@property (assign, nonatomic) BOOL isFullScreen;
//当前是否在视频界面
@property (assign, nonatomic) BOOL isInVideoView;
//app是否进入后台
@property (assign, nonatomic) BOOL isEnterBackGround;

@property (nonatomic, strong, readonly) Reachability  *reachability;
@property (nonatomic,assign) BOOL isPersonWifeOpen;//判断个人热点是否打开
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/** 单例 */
+ (instancetype)sharedInstance;

/** 全局标签栏 */
+ (ZWTabBarController *)tabBarController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

