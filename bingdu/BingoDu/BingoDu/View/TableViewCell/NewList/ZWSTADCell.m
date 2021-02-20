#import "ZWSTADCell.h"
#import "UIView+NHZW.h"
#import "UIImageView+WebCache.h"
#import "ZWSTADManager.h"
#import "ZWSingleImageCell.h"

@interface ZWSTADCell ()

/** 时趣广告数据 */
@property (nonatomic, strong, readwrite) STObject *STObj;

@end

@implementation ZWSTADCell

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
        [self.newsImageView autoSetDimensionsToSize:[ZWSTADCell imageSize]];
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
    if ([model.adId isEqualToString:kSTADIdentifier]) {
        if ([ZWUtility networkAvailable]) {
            [ZWSTADManager startUpdatingSTADWithSuccessBlock:^(STObject *stObj) {
                self.STObj = stObj;
            } failureBlock:^{
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(STADCell:displayed:)]) {
                        [self.delegate STADCell:self displayed:NO];
                    }
                }
            }];
        }
    }
}

- (void)setSTObj:(STObject *)stObj {
    _STObj = stObj;
    if (_STObj) {
        self.titleLabel.text = _STObj.title;
        [self.newsImageView sd_setImageWithURL:_STObj.content_image_url];
    }
}

+ (CGFloat)height {
    return [ZWSTADCell imageSize].height+16;
}

@end
