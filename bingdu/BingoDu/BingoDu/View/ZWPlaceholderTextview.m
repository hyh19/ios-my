
#import "ZWPlaceholderTextview.h"

@interface ZWPlaceholderTextview ()

@end

@implementation ZWPlaceholderTextview

- (void)dealloc

{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)awakeFromNib

{
    
    [super awakeFromNib];
    
    [self setPlaceholder:@""];
    
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
}
- (id)initWithFrame:(CGRect)frame

{
    
    if( (self = [super initWithFrame:frame]) )
        
    {
        
        [self setPlaceholder:@""];
        
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
        
    }
    
    return self;
    
}
-(void)setPlaceholder:(NSString*)placeholder
{
    _placeholder=placeholder;
   [self setNeedsDisplay];
}


- (void)textChanged:(NSNotification *)notification

{
    
    if([[self placeholder] length] == 0)
        
    {
        
        return;
        
    }
    
    
    
    if([[self text] length] == 0)
        
    {
        
        [[self viewWithTag:999] setAlpha:1];
        
    }
    
    else
        
    {
        
        [[self viewWithTag:999] setAlpha:0];
        
    }
    
}

- (void)setText:(NSString *)text
{
    
    [super setText:text];
    
    [self textChanged:nil];
    
}
- (void)drawRect:(CGRect)rect

{
    if( [[self placeholder] length] > 0 )
        
    {
        
        if ( _placeHolderLabel == nil )
            
        {
            
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(7,6,self.bounds.size.width - 16,20)];
            
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            
            _placeHolderLabel.numberOfLines = 0;
            
            _placeHolderLabel.font = self.font;
            
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            
            _placeHolderLabel.textColor = self.placeholderColor;
            
            _placeHolderLabel.alpha = 0;
            
            _placeHolderLabel.tag = 999;
            
            [self addSubview:_placeHolderLabel];
            
        }
        
        
        
        _placeHolderLabel.text = self.placeholder;
        
       // [_placeHolderLabel sizeToFit];
        
        [self sendSubviewToBack:_placeHolderLabel];
        
    }
    
    
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
        
    {
        
        [[self viewWithTag:999] setAlpha:1];
        
    }
    
    [super drawRect:rect];
    
}
@end
