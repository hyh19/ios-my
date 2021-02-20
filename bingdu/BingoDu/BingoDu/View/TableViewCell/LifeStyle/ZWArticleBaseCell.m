#import "ZWArticleBaseCell.h"
#import "ALView+PureLayout.h"
#import "NSArray+PureLayout.h"

@interface ZWArticleBaseCell ()

/** 评论图标 */
@property (nonatomic, strong) UIImageView *commentIcon;

/** 分割线 */
@property (nonatomic, strong) UIView *separator1;

/** 分割线 */
@property (nonatomic, strong) UIView *separator2;

/** Header view */
@property (nonatomic, strong) UIView *footerView;

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation ZWArticleBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.articleImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.summaryLabel];
        [self.contentView addSubview:self.separator1];
        [self.contentView addSubview:self.commentLabel];
        [self.contentView addSubview:self.commentIcon];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.footerView];
        [self.contentView addSubview:self.separator2];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        // 文章图片
        [self.articleImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.articleImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.articleImageView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.articleImageView autoSetDimension:ALDimensionHeight toSize:(SCREEN_WIDTH*316/720)];
        
        // 文章标题
        [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.articleImageView withOffset:10];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:12];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:12];
        
        // 文章摘要
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.summaryLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
        }];
        [self.summaryLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:10];
        [self.summaryLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleLabel];
        [self.summaryLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.titleLabel];
        
        // 分割线
        [self.separator1 autoSetDimension:ALDimensionHeight toSize:0.33];
        [self.separator1 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.summaryLabel withOffset:10];
        [self.separator1 autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.summaryLabel];
        [self.separator1 autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.summaryLabel];
        
        // 评论数
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.commentLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.commentLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.separator1 withOffset:7];
        [self.commentLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:12];
        
        // 评论图标
        [self.commentIcon autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.commentLabel withOffset:-4];
        [self.commentIcon autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.commentLabel];
        
        // 发布时间
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.timeLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.timeLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.commentIcon withOffset:-18];
        [self.timeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.commentLabel];
        
        // Footer view
        [self.footerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.commentLabel withOffset:7];
        [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.footerView autoSetDimension:ALDimensionHeight toSize:6];
        
        // 分割线
        [self.separator2 autoSetDimension:ALDimensionHeight toSize:0.33];
        [self.separator2 autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.footerView];
        [self.separator2 autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.footerView];
        [self.separator2 autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.footerView];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.summaryLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.summaryLabel.frame);
}

#pragma mark - Getter & Setter -
- (UIImageView *)articleImageView {
    if (!_articleImageView) {
        _articleImageView = [UIImageView newAutoLayoutView];
    }
    return _articleImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel newAutoLayoutView];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = FONT_SIZE(@"life_style_article_list", @"title");
        _titleLabel.textColor = FONT_COLOR(@"life_style_article_list", @"title");
    }
    return _titleLabel;
}

- (UILabel *)summaryLabel {
    if (!_summaryLabel) {
        _summaryLabel = [UILabel newAutoLayoutView];
        _summaryLabel.numberOfLines = 2;
        _summaryLabel.font = FONT_SIZE(@"life_style_article_list", @"summary");
        _summaryLabel.textColor = FONT_COLOR(@"life_style_article_list", @"summary");
    }
    return _summaryLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel newAutoLayoutView];
        _timeLabel.textColor = COLOR_00BAA2;
        _timeLabel.font = FONT_SIZE_11;
    }
    return _timeLabel;
}

- (UIImageView *)commentIcon {
    if (!_commentIcon) {
        _commentIcon = [UIImageView newAutoLayoutView];
        _commentIcon.image = [UIImage imageNamed:@"icon_new_comment"];
    }
    return _commentIcon;
}

- (UILabel *)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [UILabel newAutoLayoutView];
        _commentLabel.textColor = COLOR_00BAA2;
        _commentLabel.font = FONT_SIZE_11;
    }
    return _commentLabel;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [UIView newAutoLayoutView];
        _footerView.backgroundColor = COLOR_F2F2F2;
    }
    return _footerView;
}

- (UIView *)separator1 {
    if (!_separator1) {
        _separator1 = [UIView newAutoLayoutView];
        _separator1.backgroundColor = COLOR_E7E7E7;
    }
    return _separator1;
}

- (UIView *)separator2 {
    if (!_separator2) {
        _separator2 = [UIView newAutoLayoutView];
        _separator2.backgroundColor = COLOR_E7E7E7;
    }
    return _separator2;
}

- (void)setModel:(ZWArticleModel *)model {
    _model = model;
    if (_model) {
        
        // 已阅读的新闻使用灰色字体
        if ([_model.loadFinished integerValue]>0) {
            self.titleLabel.textColor = [UIColor grayColor];
            self.summaryLabel.textColor = [UIColor grayColor];
        } else {
            self.titleLabel.textColor = COLOR_333333;
            self.summaryLabel.textColor = COLOR_848484;
        }
        
        ZWPicModel *picModel = [_model.picList safe_objectAtIndex:0];
        if (picModel && [picModel.picUrl isValid]) {
            [self.articleImageView sd_setImageWithURL:[NSURL URLWithString:picModel.picUrl] placeholderImage:[UIImage imageNamed:@"icon_banner_article"] options:SDWebImageRetryFailed];
        }
        self.titleLabel.text = _model.newsTitle;
        self.summaryLabel.text = _model.summary;
        self.commentLabel.text = _model.cNum;
    }
}

@end
