//
//  NSMutableString+TagReplace.h
//  SonoRoute
//
//  Created by Nigel Grange on 07/06/2014.
//  Copyright (c) 2014 Nigel Grange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (TagReplace)

-(void)replaceAllTagsIntoArray:(NSMutableArray*)array;

@end

/*注，此处的color对应的值必须是系统预定义好的，有
+ (UIColor *)blackColor;      // 0.0 white
+ (UIColor *)darkGrayColor;   // 0.333 white
+ (UIColor *)lightGrayColor;  // 0.667 white
+ (UIColor *)whiteColor;      // 1.0 white
+ (UIColor *)grayColor;       // 0.5 white
+ (UIColor *)redColor;        // 1.0, 0.0, 0.0 RGB
+ (UIColor *)greenColor;      // 0.0, 1.0, 0.0 RGB
+ (UIColor *)blueColor;       // 0.0, 0.0, 1.0 RGB
+ (UIColor *)cyanColor;       // 0.0, 1.0, 1.0 RGB
+ (UIColor *)yellowColor;     // 1.0, 1.0, 0.0 RGB
+ (UIColor *)magentaColor;    // 1.0, 0.0, 1.0 RGB
+ (UIColor *)orangeColor;     // 1.0, 0.5, 0.0 RGB
+ (UIColor *)purpleColor;     // 0.5, 0.0, 0.5 RGB
+ (UIColor *)brownColor;      // 0.6, 0.4, 0.2 RGB
+ (UIColor *)clearColor;      // 0.0 white, 0.0 alpha
否则，程序会crash。
*/
//用法：
//    NSDictionary* style2 = @{@"body" :
//                                 @[[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0],
//                                   [UIColor darkGrayColor]],
//                                @"u": @[[UIColor blueColor],
//                                    @{NSUnderlineStyleAttributeName : @(kCTUnderlineStyleSingle|kCTUnderlinePatternSolid)}
//                                     ],
//                                @"thumb":[UIImage imageNamed:@"thumbIcon"] };
//
//    NSDictionary* style3 = @{@"body":[UIFont fontWithName:@"HelveticaNeue" size:22.0],
//                             @"help":[WPAttributedStyleAction styledActionWithAction:^{
//                                 NSLog(@"Help action");
//                             }],
//                             @"settings":[WPAttributedStyleAction styledActionWithAction:^{
//                                 NSLog(@"Settings action");
//                             }],
//                             @"link": [UIColor orangeColor]};
//    self.label2.attributedText = [@"<thumb> </thumb> Multiple <u>styles</u> text <thumb> </thumb>" attributedStringWithStyleBook:style2];
//    self.label3.attributedText = [@"Tap <help>here</help> to show help or <settings>here</settings> to show settings" attributedStringWithStyleBook:style3];
