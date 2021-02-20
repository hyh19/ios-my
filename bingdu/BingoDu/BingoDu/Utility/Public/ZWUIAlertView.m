#import "ZWUIAlertView.h"
#import <objc/runtime.h>

@implementation ZWUIAlertView

@end

// 显示带一个确定按钮的简易提示信息的方法
void hint(NSString *message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
        alert.backgroundColor = [UIColor blackColor];
        [alert show];
    });
}

//显示一个短暂的提示信息方法
void occasionalHint(NSString *message)
{
    [[TKAlertCenter defaultCenter] postAlertWithMessage:message];
}

@implementation NSObject (hint)

static char kAlertTrueBlockKey;
static char kAlertCancelBlockKey;

// 显示带取消和确定两个按钮并为确定按钮关联一个后续操作的提示信息的方法
- (void)hint:(NSString *)message trueBlock:(HintAction)block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        alert.delegate = self;
        [alert show];
        
        [self setBlock:block forKey:&kAlertTrueBlockKey];
    });
}
// 显示带确定按钮并为确定按钮关联一个后续操作的提示信息的方法
- (void)hint:(NSString *)message singleTrueBlock:(HintAction)block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        alert.delegate = self;
        [alert show];
        [self setBlock:block forKey:&kAlertCancelBlockKey];
    });
}

// 显示两个有自定义标题和各自关联一个后续操作的按钮的提示信息的方法
- (void)hint:(NSString *)message
   trueTitle:(NSString *)trueTitle
   trueBlock:(HintAction)trueBlock
 cancelTitle:(NSString *)cancelTitle
 cancelBlock:(HintAction)cancelBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:cancelTitle
                                              otherButtonTitles:trueTitle, nil];
        alert.delegate = self;
        [alert show];
        
        [self setBlock:trueBlock forKey:&kAlertTrueBlockKey];
        [self setBlock:cancelBlock forKey:&kAlertCancelBlockKey];
    });
}

// 显示两个有自定义标题和各自关联一个后续操作的按钮的提示信息的方法
- (void)hint:(NSString *)title
     message:(NSString *)message
   trueTitle:(NSString *)trueTitle
   trueBlock:(HintAction)trueBlock
 cancelTitle:(NSString *)cancelTitle
 cancelBlock:(HintAction)cancelBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:cancelTitle
                                              otherButtonTitles:trueTitle, nil];
        alert.delegate = self;
        [alert show];
        
        [self setBlock:trueBlock forKey:&kAlertTrueBlockKey];
        [self setBlock:cancelBlock forKey:&kAlertCancelBlockKey];
    });
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self runBlockForKey:&kAlertTrueBlockKey];
    }
    else if(buttonIndex == 0)
    {
        [self runBlockForKey:&kAlertCancelBlockKey];
    }
}
- (void)runBlockForKey:(void *)blockKey
{
    HintAction block = objc_getAssociatedObject(self, blockKey);
    if (block) block();
}

- (void)setBlock:(HintAction)block forKey:(void *)blockKey
{
    objc_setAssociatedObject(self, blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end