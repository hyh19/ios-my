#import "ZWCategoryArticleCell.h"
#import "CustomURLCache.h"
#import "UIImageView+WebCache.h"
#import "ALView+PureLayout.h"
#import "ZWNewsModel.h"
#import "NewsPicList.h"

@implementation ZWCategoryArticleCell

- (void)setModel:(ZWArticleModel *)model {
    [super setModel:model];
    if (self.model) {
        self.timeLabel.text = self.model.publishTime;
    }
}

@end
