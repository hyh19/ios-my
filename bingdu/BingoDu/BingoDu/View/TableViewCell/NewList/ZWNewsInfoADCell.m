#import "ZWNewsInfoADCell.h"

@interface ZWNewsInfoADCell ()

@end

@implementation ZWNewsInfoADCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLabel.numberOfLines = 1;
        [self.contentView addSubview:self.newsImageView];
        [self.contentView addSubview:self.tagImageView];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        // 大图
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [self.newsImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        [self.newsImageView autoSetDimension:ALDimensionHeight toSize:123];
        
        // 标题
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.titleLabel autoSetDimension:ALDimensionHeight toSize:40];
        [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.newsImageView];
        [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.newsImageView];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        // 标签
        [self.tagImageView autoSetDimensionsToSize:CGSizeMake(26, 14)];
        [self.tagImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:-8];
        [self.tagImageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
        [self.tagImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
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
