//
//  FBHashTagView.m
//  LiveShow
//
//  Created by chenfanshun on 10/08/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBHashTagView.h"
#import "UIImage-Helpers.h"

#define TAGSFONT_SIZE   14.0f
#define LABEL_MARGIN 10.0f
#define BOTTOM_MARGIN 15.0f
#define HORIZONTAL_PADDING 15.0f
#define VERTICAL_PADDING 10.0f

@interface FBHashTagView()

{
    CGSize sizeFit;
}

@property(nonatomic, strong)NSArray        *tagsArray;
@property(nonatomic, strong)NSMutableArray *buttonArray;

@end

@implementation FBHashTagView

-(id)init
{
    if(self = [super init]) {
        self.buttonArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.buttonArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setHashTags:(NSArray*)tags
{
    self.tagsArray = tags;
    
    [self updateDislay];
}

-(NSArray*)getSelectTags
{
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    for(UIButton* btn in self.buttonArray)
    {
        if(btn.isSelected) {
            NSString *title = [btn titleForState:UIControlStateNormal];
            if([title length]) {
                [tags addObject:title];
            }
        }
    }
    return tags;
}

-(void)updateDislay
{
    if(CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        return;
    }
    
    for (UIButton *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    [self.buttonArray removeAllObjects];
    
    float totalHeight = 0;
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    NSInteger index = 0;
    for (NSString *text in self.tagsArray) {
        NSMutableAttributedString *attributedString =
        [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = NSMakeRange(0, [text length]);
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:TAGSFONT_SIZE] range:range];
        
        CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading context:nil];
        
        rect.size.width += HORIZONTAL_PADDING*2;
        rect.size.height += VERTICAL_PADDING*2 - 10;
        UIButton *button = nil;
        if (!gotPreviousFrame) {
            button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
            totalHeight = rect.size.height;
        } else {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + rect.size.width + LABEL_MARGIN > self.frame.size.width) {
                newRect.origin = CGPointMake(0, previousFrame.origin.y + rect.size.height + BOTTOM_MARGIN);
                
                totalHeight += rect.size.height + BOTTOM_MARGIN;
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + LABEL_MARGIN, previousFrame.origin.y);
            }
            newRect.size = rect.size;
            button = [[UIButton alloc] initWithFrame:newRect];
        }
        previousFrame = button.frame;
        gotPreviousFrame = YES;
        [button.titleLabel setFont:[UIFont systemFontOfSize:TAGSFONT_SIZE]];

        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:text forState:UIControlStateNormal];
        
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor hx_colorWithHexString:@"#000000" alpha:0.3]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor hx_colorWithHexString:@"#fd4cbe" alpha:0.5]] forState:UIControlStateSelected];
        
        [button.layer setMasksToBounds:YES];
        button.layer.cornerRadius = rect.size.height/2.0;
        button.tag = index;
        [button addTarget:self action:@selector(onTagButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttonArray addObject:button];
        
        index++;
    }
    
    sizeFit = CGSizeMake(self.frame.size.width, totalHeight + 1.0f);
    
}

- (CGSize)fittedSize
{
    return sizeFit;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateDislay];
}

-(void)onTagButton:(UIButton*)sender
{
    [sender setSelected:!sender.isSelected];
    
    if(self.onTagClick) {
        NSInteger index = sender.tag;
        if(index < [self.tagsArray count]) {
            self.onTagClick(self.tagsArray[index], sender.isSelected);
        }
    }
}

-(void)updateStateWithText:(NSString*)text
{
    //先取消
    for (UIButton *btn in self.buttonArray) {
        [btn setSelected:NO];
    }
    
    for(NSInteger i = 0; i < [self.tagsArray count]; i++)
    {
        NSString* cmp = [NSString stringWithFormat:@"%@ ", self.tagsArray[i]];
        
        NSRange rang = [text rangeOfString:cmp options:NSCaseInsensitiveSearch];
        if(rang.location != NSNotFound) {
            UIButton *btn = self.buttonArray[i];
            [btn setSelected:YES];
        }
    }
}

@end
