#import <Foundation/Foundation.h>
#import "NSObject+OTSharedInstance.h"
#import "FBHTTPSessionManager.h"
#import "FBURLManager.h"

/** GET请求 */
#define GET_REQUEST(URLString)	\
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance]; \
    [manager GET:URLString \
      parameters:parameters \
         success:success \
         failure:failure \
         finally:finally \
    ];

/** POST请求 */
#define POST_REQUEST(URLString)	\
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance]; \
    [manager POST:URLString \
       parameters:parameters \
          success:success \
          failure:failure \
          finally:finally \
    ];

@interface FBBaseNetworkManager : NSObject

@end
