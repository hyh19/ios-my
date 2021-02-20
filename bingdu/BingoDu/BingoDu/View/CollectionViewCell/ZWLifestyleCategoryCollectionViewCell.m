#import "ZWLifestyleCategoryCollectionViewCell.h"

@interface ZWLifestyleCategoryCollectionViewCell ()

@end

@implementation ZWLifestyleCategoryCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = FONT_COLOR(@"life_style_category_list", @"cell");
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[UIColor colorWithRed:207./255 green:207./255 blue:207./255 alpha:0.5] CGColor];
    
    [self.channelImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.channelImageView.contentMode =  UIViewContentModeScaleAspectFill;
    self.channelImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.channelImageView.clipsToBounds  = YES;
}

@end
