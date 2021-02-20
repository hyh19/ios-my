#import "ZWCryptoPostRequest.h"
#import "ZWMyNetworkManager.h"

@implementation ZWCryptoPostRequest

- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed {
    
    if (self = [super initWithBaseURL:baseURL path:path parameters:parameters succed:succed failed:failed]) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURL, path];
        /**https请求 特殊处理*/
        if ([urlString containsString:@"https"])
        {
            [self.request setAuthenticationScheme:@"https"];//设置验证方式
            [self.request setValidatesSecureCertificate:NO];//设置验证证书
        }
        // 对"api/"后面的地址要进行加密
        NSRange theRange = [urlString rangeOfString:@"api/"];
        // 地址明文
        NSString *plainText = [urlString substringFromIndex:theRange.location+theRange.length];
        // 加密后的密文
        NSString *ciphertext = [plainText stringByDESEncryptingWithKey:[[ZWUserInfoModel sharedInstance] deskey]];
        
        NSURL *url = [NSURL URLWithString:urlString.replace(plainText, ciphertext)];
        
        [self.request setURL:url];
        
        // 按照服务端要求，在需要加密的请求接口中需要加入uid参数，此uid为用户登录后反回的userId
        parameters[@"uid"] = [ZWUserInfoModel userID];
        
        // 参数值要先转换为JSON字符串再进行加密
        NSString *encryptdParameterString = [[parameters JSONString] stringByDESEncryptingWithKey:[[ZWUserInfoModel sharedInstance] deskey]];
        // 加密的参数值要以字节流的形式传给服务器
        NSData *postData = [encryptdParameterString dataUsingEncoding:NSUTF8StringEncoding];
        
        [self.request appendPostData:postData];
        
        // 设置加密接口的请求头
        NSMutableDictionary *headers = [self headersWithParameters:parameters andRequestType:ZWHTTPRequestTypeCrypto];
        
        [self.request setRequestHeaders:headers];
    }
    
    return self;
}

@end
