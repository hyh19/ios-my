#import "FBLoginInfoModel.h"

@implementation FBLoginInfoModel {
    NSString *_userID;
    NSString *_tokenString;
    NSString *_loginType;
}

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    
    static FBLoginInfoModel *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[FBLoginInfoModel alloc] init];
        
    });
    
    return sharedInstance;
}

- (NSString *)userID {
    return [[GVUserDefaults standardUserDefaults] userID];
}

- (NSString *)tokenString {
    return [[GVUserDefaults standardUserDefaults] tokenString];
}

- (NSString *)loginType {
    return [[GVUserDefaults standardUserDefaults] loginType];
}

- (NSString *)nickName {
    if (self.user) {
        if ([self.user.nick isValid]) {
            return self.user.nick;
        }
    }
    return nil;
}

- (void)setUserID:(NSString *)userID {
    _userID = userID;
    [[GVUserDefaults standardUserDefaults] setUserID:_userID];
}

- (void)setTokenString:(NSString *)tokenString {
    _tokenString = tokenString;
    [[GVUserDefaults standardUserDefaults] setTokenString:_tokenString];
}

- (void)setLoginType:(NSString *)loginType {
    _loginType = loginType;
    [[GVUserDefaults standardUserDefaults] setLoginType:_loginType];
}

- (FBUserInfoModel *)user {
    NSData *data = [[GVUserDefaults standardUserDefaults] userData];
    // 反序列化
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    return [FBUserInfoModel mj_objectWithKeyValues:dict];
}

- (UIImage *)avatarImage {
    return [UIImage imageWithData:[[GVUserDefaults standardUserDefaults] avatarData]];
}

- (void)saveUserInfo:(NSDictionary *)dict {
    if (dict) {
        // 序列化
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        [[GVUserDefaults standardUserDefaults] setUserData:data];
        
        FBUserInfoModel *userInfo = [[FBLoginInfoModel sharedInstance] user];
        UIImageView *avatar = [[UIImageView alloc] init];

        [avatar fb_setImageWithName:userInfo.portrait size:CGSizeMake(100, 100) placeholderImage:kDefaultImageAvatar completed:^(){
            NSData *data = UIImagePNGRepresentation(avatar.image);
            // 缓存头像数据
            [[GVUserDefaults standardUserDefaults] setAvatarData:data];
        
        }];
        
        
    }
}

- (void)purgeUserInfo {
    [self setUserID:@""];
    [self setTokenString:@""];
    [self setLoginType:@""];
    [[GVUserDefaults standardUserDefaults] setUserData:[NSData data]];
}

- (BOOL)connectedPlatform:(NSString *)platform {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"platform = %@", platform];
    NSArray *filteredArray = [self.connectedAcounts filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] > 0) {
        return YES;
    }
    return NO;
}

@end
