
#import <UIKit/UIKit.h>
/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 带palceholder的Textview
 */
@interface ZWPlaceholderTextview : UITextView
/**
 placeholder字符串
 */
@property(nonatomic, strong) NSString *placeholder;
/**
 placeholder字符串颜色
 */
@property(nonatomic, strong) UIColor* placeholderColor;
/**
 placeholder lable
 */
@property(nonatomic, retain) UILabel *placeHolderLabel;





@end
