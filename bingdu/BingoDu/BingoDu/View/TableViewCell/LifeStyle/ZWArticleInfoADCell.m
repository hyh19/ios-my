#import "ZWArticleInfoADCell.h"

@interface ZWArticleInfoADCell ()

/** 分割线 */
@property (nonatomic, strong) UIView *separator;

/** Header view */
@property (nonatomic, strong) UIView *footerView;

@end

@implementation ZWArticleInfoADCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLabel.numberOfLines = 1;
        [self.contentView addSubview:self.newsImageView];
        [self.contentView addSubview:self.tagImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.separator];
        [self.contentView addSubview:self.footerView];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        // 大图
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [self.newsImageView autoSetDimension:ALDimensionHeight toSize:140];
        
        // 标题
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.titleLabel autoSetDimension:ALDimensionHeight toSize:40];
        [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.newsImageView];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:12];
        
        // 标签
        [self.tagImageView autoSetDimensionsToSize:CGSizeMake(26, 14)];
        [self.tagImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:-8];
        [self.tagImageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
        [self.tagImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:12];
        
        // 分割线
        [self.separator autoSetDimension:ALDimensionHeight toSize:0.33];
        [self.separator autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel];
        [self.separator autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.separator autoPinEdgeToSuperviewEdge:ALEdgeRight];
        
        // Footer view
        [self.footerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.separator];
        [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.footerView autoSetDimension:ALDimensionHeight toSize:6];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [UIView newAutoLayoutView];
        _footerView.backgroundColor = COLOR_F2F2F2;
    }
    return _footerView;
}

- (UIView *)separator {
    if (!_separator) {
        _separator = [UILabel newAutoLayoutView];
        _separator.backgroundColor = COLOR_E7E7E7;
    }
    return _separator;
}

- (void)setModel:(ZWNewsModel *)model {
    [super setModel:model];
    if (self.model) {
        self.titleLabel.text = self.model.newsTitle;
        
        if (self.model.picList.count > 0) {
            ZWPicModel *picModel = [self.model.picList safe_objectAtIndex:0];
            NSString *picURL = picModel.picUrl;
            if ([picURL isValid]) {
                [self.newsImageView sd_setImageWithURL:[NSURL URLWithString:picURL] placeholderImage:[UIImage imageNamed:@"icon_banner_ad"] options:SDWebImageRetryFailed];
            }
        }
    }
}

@end
