#import "ZWAdxAdvertiseCell.h"
#import "UIImageView+WebCache.h"

@implementation ZWAdxAdvertiseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.newsImageView];
        [self.contentView addSubview:self.tagImageView];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        // 新闻图片适配
        [self.newsImageView autoSetDimensionsToSize:[ZWNewsBaseCell imageSize]];
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
        
        // 新闻标题适配
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
        }];
        [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.newsImageView withOffset:10];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.newsImageView];
        
        // 新闻标签
        [self.tagImageView autoSetDimensionsToSize:CGSizeMake(26, 14)];
        [self.tagImageView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.titleLabel];
        [self.tagImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.newsImageView];
        
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
    self.tagImageView.image = [UIImage imageNamed:@"icon_ad"];
    self.titleLabel.text = @"氪金广告";
    self.newsImageView.image = [UIImage imageNamed:@"icon_banner_ad"];
//    if (self.model) {
//        self.titleLabel.text = self.adxModel.advTitle;
//        [self.newsImageView sd_setImageWithURL:[NSURL URLWithString:self.adxModel.advIconUrl] placeholderImage:[UIImage imageNamed:@"icon_banner_ad"]];
//    }
}

@end
