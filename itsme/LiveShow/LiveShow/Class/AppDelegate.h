#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FBTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

/** 访问单例 */
+ (instancetype)sharedInstance;

/** 全局标签控制器 */
+ (FBTabBarController *)tabBarController;

@end

