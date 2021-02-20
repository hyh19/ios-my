#import "ZWSingleImageCell.h"
#import "UIButton+EnlargeTouchArea.h"
#import "CustomURLCache.h"
#import "UIImageView+WebCache.h"
#import "ALView+PureLayout.h"

@interface ZWSingleImageCell()

@end

@implementation ZWSingleImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.newsImageView];
        [self.contentView addSubview:self.readIcon];
        [self.contentView addSubview:self.readLabel];
        [self.contentView addSubview:self.commentIcon];
        [self.contentView addSubview:self.commentLabel];
        [self.contentView addSubview:self.tagImageView];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        // 新闻图片适配
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
        [self.newsImageView autoSetDimensionsToSize:[ZWSingleImageCell imageSize]];
        
        // 新闻标题适配
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
        }];
        [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.newsImageView withOffset:8];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.newsImageView];
        
        // 阅读图标适配
        [self.readIcon autoSetDimensionsToSize:CGSizeMake(14, 12)];
        [self.readIcon autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleLabel];
        [self.readIcon autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.newsImageView];
        
        // 阅读数适配
        [self.readLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.readIcon withOffset:2];
        [self.readLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.readIcon];
        
        // 评论图标适配
        [self.commentIcon autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.readLabel withOffset:8];
        [self.commentIcon autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.readIcon];
        
        // 评论数适配
        [self.commentLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.commentIcon withOffset:2];
        [self.commentLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.commentIcon];
        
        // 新闻标签
        [self.tagImageView autoSetDimensionsToSize:CGSizeMake(26, 14)];
        [self.tagImageView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.titleLabel];
        [self.tagImageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.commentLabel];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
}

- (void)setModel:(ZWNewsModel *)model {
    
    [super setModel:model];
    
    if (self.model) {
        
        ZWPicModel *picModel = [self.model.picList safe_objectAtIndex:0];
        if (picModel && [picModel.picUrl isValid]) {
            [self.newsImageView sd_setImageWithURL:[NSURL URLWithString:picModel.picUrl] placeholderImage:[UIImage imageNamed:@"icon_banner_list"] options:SDWebImageRetryFailed];
        }
        
        self.titleLabel.text = self.model.newsTitle;
        
        self.readLabel.text = self.model.readNum;
        
        self.commentLabel.text = self.model.cNum;
    }
}

@end
