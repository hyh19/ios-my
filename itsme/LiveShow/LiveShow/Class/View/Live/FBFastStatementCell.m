#import "FBFastStatementCell.h"
#import "FBUtility.h"

@interface FBFastStatementCell()

/** 发言内容label */
@property (strong, nonatomic) UILabel *statementLabel;

/** 分割线 */
@property (nonatomic, strong) UIView *separatorView;

@end

@implementation FBFastStatementCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.96];
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor hx_colorWithHexString:@"50e3ce" alpha:0.2];
        
        [self addSubview:self.statementLabel];
        [self addSubview:self.separatorView];
        
        UIView *superView = self;
        
        [self.statementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(150, self.size.height));
            make.left.equalTo(superView).offset(10);
            make.centerY.equalTo(superView);
        }];
        
        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(superView.size.width, 0.5));
            make.bottom.equalTo(superView);
        }];
    }
    return self;
}

- (UILabel *)statementLabel {
    if (!_statementLabel) {
        _statementLabel = [[UILabel alloc] init];
        _statementLabel.textColor = COLOR_444444;
        _statementLabel.font = FONT_SIZE_14;
    }
    
    return _statementLabel;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor hx_colorWithHexString:@"e3e3e3" alpha:0.8];
    }
    return _separatorView;
}

- (void)setModel:(FBPresetDialogModel *)model {
    _model = model;
    self.statementLabel.text = _model.dialog;
}

@end
