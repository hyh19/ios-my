#import "NSString+NHZW.h"
#import "NSString+Encryption.h"

@implementation NSString (NHZW)

+ (NSString *)secureString:(NSString *)source
                headLength:(NSInteger)head
                tailLength:(NSInteger)tail {
    NSString *result = nil;
    if ([source length]>head)
    {
        result = [source substringWithRange:NSMakeRange(0, head)];
        for (NSInteger i = head; i < [source length]-tail; i++)
        {
            result = [result stringByAppendingString:@"*"];
        }
        
        NSInteger lastLocation = [source length]-tail;
        if (lastLocation < head)
        {
            lastLocation = head;
        }
        
        if (lastLocation < [source length])
        {
            result = [result stringByAppendingString:
                      [source substringWithRange:NSMakeRange(lastLocation,
                                                             [source length]-lastLocation)]];
        }
        
        return result;
    }
    
    return source;
}

+ (CGRect) heightForString:(NSString *)value fontSize:(float)fontSize andSize:(CGSize)size {
    
    if (SYSTEM_VERSION_EQUAL_TO(@"6.0")) {
        CGSize curSize = [value sizeWithFont:[UIFont systemFontOfSize:fontSize]
                          constrainedToSize:size
                              lineBreakMode:NSLineBreakByCharWrapping];
        CGRect curRect = {CGPointZero,curSize};
        return  curRect;
        
    }
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGRect curRect = [value boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin |
                                             NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
        /**
         该方式为解决文字不显示完全问题（暂时保留），现仍采用原来做了改动的方式
         */
//        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
//        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
//        
//        NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:fontSize],
//                                     NSParagraphStyleAttributeName: paragraph};
//        
//        CGRect curRect = [value boundingRectWithSize:size
//                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
//                                      attributes:attributes
//                                         context:nil];
        return curRect;
}

- (CGFloat)labelHeightWithNumberOfLines:(NSInteger)lines fontSize:(CGFloat)fontSize labelWidth:(CGFloat)width {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.numberOfLines = lines;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.text = self;
    [label sizeToFit];
    return CGRectGetHeight(label.frame);
}

+ (NSString *)URLEncodedString:(NSString *)string
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)string,NULL,CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),kCFStringEncodingUTF8));
    if(result) {
        return result;
    }
    return @"";
}

@end

@implementation NSString (DESCrypto)

- (NSString *)stringByDESEncryptingWithKey:(NSString *)key {
    
    Byte iv[] = {1,2,3,4,5,6,7,8};
    
    NSString *ciphertext = [self encryptedWithDESUsingKey:key andIV:[NSData dataWithBytes:iv length:8]];
    
    return ciphertext;
}

@end

@implementation NSString (Constants)

+ (NSString *)shareMessageForSMSWithInvitationCode:(NSString *)code {
    NSString *message = [NSString stringWithFormat:@"邀请码【%@】。下载并读，体验我的精致生活。下载链接：%@/share/app?uid=%@", code, BASE_URL, [ZWUserInfoModel userID]];
    
    return message;
}

+ (NSString *)shareMessageForSNSWithInvitationCode:(NSString *)code {
    NSString *message = [NSString stringWithFormat:@"邀请码【%@】。下载并读，体验我的精致生活!下载链接:%@/share/app?uid=%@", code, BASE_URL, [ZWUserInfoModel userID]];
    return message;
}

@end

@implementation NSString (Withdrawing)

#define NMUBERS @"1234567890"

//验证提现金额输入规则
- (BOOL)isValidWithdrawals:(NSString *)textFieldStr
{
    if ([self isEqualToString:@""]) {
        return YES;
    }
    if (textFieldStr.length>11) {
        return NO;
    }
    NSCharacterSet * charact;
    charact = [[NSCharacterSet characterSetWithCharactersInString:NMUBERS]invertedSet];
    NSString * filtered = [[self componentsSeparatedByCharactersInSet:charact]componentsJoinedByString:@""];
    BOOL canChange = [self isEqualToString:filtered];
    if(!canChange) {
        return NO;
    }else
    {
        if (textFieldStr.length==0) {
            if ([self isEqualToString:@"0"]) {
                return NO;
            }
        }else
            return YES;
    }
    return YES;
}

@end
