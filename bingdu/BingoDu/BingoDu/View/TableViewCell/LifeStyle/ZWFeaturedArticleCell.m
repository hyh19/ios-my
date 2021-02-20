#import "ZWFeaturedArticleCell.h"
#import "UIView+WhenTappedBlocks.h"

@implementation ZWFeaturedArticleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.timeLabel whenTapped:^{
            if ([self.delegate respondsToSelector:@selector(tapChannelWithModel:)]) {
                [self.delegate tapChannelWithModel:self.model];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNotificationNewsCommentNumChanged:)
                                                     name:kNotificationNewsCommentNumChanged
                                                   object:nil];
    }
    return self;
}

- (void)setModel:(ZWArticleModel *)model {
    [super setModel:model];
    if (self.model) {
        self.timeLabel.text = self.model.channelName;
        self.commentLabel.text = self.model.cNum;
    }
}

- (void)onNotificationNewsCommentNumChanged:(NSNotification *)notification {
    ZWArticleModel *model = (ZWArticleModel *)notification.object;
    if ([model.newsId isEqualToString:self.model.newsId]) {
        self.model = model;
    }
}

@end
