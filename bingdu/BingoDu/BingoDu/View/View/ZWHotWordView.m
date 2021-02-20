#import "ZWHotWordView.h"
#import <QuartzCore/QuartzCore.h>

#define LABEL_MARGIN 10.0f
#define BOTTOM_MARGIN 10.0f
#define FONT_SIZE 14.0f
#define HORIZONTAL_PADDING 10.0f
#define VERTICAL_PADDING 10.0f
#define BACKGROUND_COLOR [UIColor whiteColor]
#define TEXT_COLOR COLOR_333333
#define TEXT_SHADOW_COLOR [UIColor whiteColor]
#define TEXT_SHADOW_OFFSET CGSizeMake(0.0f, 1.0f)
#define BORDER_COLOR COLOR_E7E7E7.CGColor
#define BORDER_WIDTH 0.7f

@interface ZWHotWordView ()
{
    /**热词视图*/
    UIView *view;
    
    /**热词数据*/
    NSArray *textArray;
    
    /**记录标签的size*/
    CGSize sizeFit;
    
    /**标签的背景颜色*/
    UIColor *lblBackgroundColor;
}
/**热词视图*/
@property (nonatomic, strong) UIView *view;

/**热词数据*/
@property (nonatomic, strong) NSArray *textArray;

@end

@implementation ZWHotWordView

@synthesize view, textArray;

#pragma mark -init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:view];
    }
    return self;
}

#pragma mark - Praviate method
- (void)setTags:(NSArray *)array
{
    textArray = [[NSArray alloc] initWithArray:array];
    sizeFit = CGSizeZero;
    [self display];
}

- (void)setLabelBackgroundColor:(UIColor *)color
{
    lblBackgroundColor = color;
    [self display];
}

- (void)display
{
    for (UILabel *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    float totalHeight = 0;
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    for (NSString *text in textArray) {
        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:CGSizeMake(self.frame.size.width, 1500) lineBreakMode:NSLineBreakByWordWrapping];
        textSize.width += HORIZONTAL_PADDING*2;
        textSize.height += VERTICAL_PADDING*2;
        UIButton *button = nil;
        if (!gotPreviousFrame) {
            button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
            totalHeight = textSize.height;
        } else {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + textSize.width + LABEL_MARGIN > self.frame.size.width) {
                newRect.origin = CGPointMake(0, previousFrame.origin.y + textSize.height + BOTTOM_MARGIN);
                totalHeight += textSize.height + BOTTOM_MARGIN;
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + LABEL_MARGIN, previousFrame.origin.y);
            }
            newRect.size = textSize;
            button = [[UIButton alloc] initWithFrame:newRect];
        }
        previousFrame = button.frame;
        gotPreviousFrame = YES;
        [button.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        if (!lblBackgroundColor) {
            [button setBackgroundColor:BACKGROUND_COLOR];
        } else {
            [button setBackgroundColor:lblBackgroundColor];
        }
        [button setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
        [button setTitle:text forState:UIControlStateNormal];

        [button.layer setMasksToBounds:YES];
        [button.layer setBorderColor:BORDER_COLOR];
        [button.layer setBorderWidth: BORDER_WIDTH];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(onTouchButtonShowSearchResult:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    sizeFit = CGSizeMake(self.frame.size.width, totalHeight + 1.0f);
}

- (CGSize)fittedSize
{
    return sizeFit;
}

#pragma mark - Event handler
/**点击热词按钮触发方法*/
- (void)onTouchButtonShowSearchResult:(UIButton *)button
{
    if([[self delegate] respondsToSelector:@selector(hotWordView:didSelectTag:)])
    {
        [[self delegate] hotWordView:self didSelectTag:button];
    }
}

@end
