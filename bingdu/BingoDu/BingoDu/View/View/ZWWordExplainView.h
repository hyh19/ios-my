
#import <UIKit/UIKit.h>
/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 词条解释view
 */
@interface ZWWordExplainView : UIView

/**
 *  显示词条view
 *  @param word  词条
 *  @param nav  导航对象
 *  @param wordUrl  词条解释url
 *  @param wordUrl  第三方logo图片
 *  @param sourceUrl  第三方URL
 */
+(void)showWordExplainView:(NSString*)word nav:(UINavigationController*)nav   wordRrl:(NSString*)wordUrl  wordImageUrl:(NSString*)wordUrl sourceUrl:(NSString*)sourceUrl;

@end
