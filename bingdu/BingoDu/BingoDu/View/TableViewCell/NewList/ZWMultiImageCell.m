#import "ZWMultiImageCell.h"
#import "UIImageView+WebCache.h"
#import "ALView+PureLayout.h"
#import "NSArray+PureLayout.h"

@interface ZWMultiImageCell()

/** 多图模式下的新闻图片 */
@property (nonatomic, strong) UIView *multiImageView;

@end

@implementation ZWMultiImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.readIcon];
        [self.contentView addSubview:self.readLabel];
        [self.contentView addSubview:self.commentIcon];
        [self.contentView addSubview:self.commentLabel];
        [self.contentView addSubview:self.multiImageView];
        [self.contentView addSubview:self.tagImageView];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        // 新闻标题适配
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
        }];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
        
        [self.multiImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [self.multiImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        [self.multiImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:8];
        [self.multiImageView autoSetDimension:ALDimensionHeight toSize:[self imageHeight]];
        
        // 阅读图标适配
        [self.readIcon autoSetDimensionsToSize:CGSizeMake(14, 12)];
        [self.readIcon autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.multiImageView withOffset:8];
        [self.readIcon autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleLabel];
        [self.readIcon autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
        
        // 阅读数适配
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.readLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.readLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.readIcon withOffset:2];
        [self.readLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.readIcon];
        [self.readLabel autoSetDimension:ALDimensionHeight toSize:14];
        
        // 评论图标适配
        [self.commentIcon autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.readLabel withOffset:8];
        [self.commentIcon autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.readIcon];
        
        // 评论数适配
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.commentLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.commentLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.commentIcon withOffset:2];
        [self.commentLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.commentIcon];
        [self.commentLabel autoSetDimension:ALDimensionHeight toSize:14];
        
        // 新闻标签
        [self.tagImageView autoSetDimensionsToSize:CGSizeMake(26, 14)];
        [self.tagImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
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

- (UIView *)multiImageView {
    if (!_multiImageView) {
        _multiImageView = [UIView newAutoLayoutView];
        for (int i = 0; i < 3; ++i) {
            UIImageView *imageView = [UIImageView newAutoLayoutView];
            [_multiImageView addSubview:imageView];
        }
        // 图片适配
        [_multiImageView.subviews autoMatchViewsDimension:ALDimensionWidth];
        [_multiImageView.subviews autoMatchViewsDimension:ALDimensionHeight];
        [_multiImageView.subviews autoAlignViewsToAxis:ALAxisHorizontal];
        
        [[_multiImageView.subviews firstObject] autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [[_multiImageView.subviews firstObject] autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [[_multiImageView.subviews firstObject] autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        [[_multiImageView.subviews lastObject] autoPinEdgeToSuperviewEdge:ALEdgeRight];
        
        for (int i = 0; i < _multiImageView.subviews.count-1; ++i) {
            [_multiImageView.subviews[i] autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_multiImageView.subviews[i+1] withOffset:-8];
        }
    }
    return _multiImageView;
}

- (void)setModel:(ZWNewsModel *)model {
    [super setModel:model];
    if (self.model) {
        self.titleLabel.text = self.model.newsTitle;
        
        self.readLabel.text = self.model.readNum;
        
        self.commentLabel.text = self.model.cNum;
        
        if ([self.model.picList count]>=3) {
            for (int i = 0; i < [self.model.picList count]; i++) {
                ZWPicModel *picModel = self.model.picList[i];
                UIImageView *view = self.multiImageView.subviews[i];
                [view sd_setImageWithURL:[NSURL URLWithString:picModel.picUrl] placeholderImage:[UIImage imageNamed:@"icon_banner_list"] options:SDWebImageRetryFailed];
            }
        }
    }
}

- (CGFloat)imageHeight {
    CGFloat height = 72;
    if ([[UIScreen mainScreen] isFourSevenPhone]) {
        height = 84;
    } else if ([[UIScreen mainScreen] isFiveFivePhone]) {
        height = 92;
    }
    return height;
}

@end
