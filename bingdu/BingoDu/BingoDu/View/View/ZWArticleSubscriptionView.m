#import "ZWArticleSubscriptionView.h"
#import "ZWSubscriptionModel.h"
#import "ZWSubscribeButton.h"
#import "UIButton+Block.h"
#import "ZWSubscribeManager.h"
#import "ZWLoginViewController.h"
#import "ZWSubscribeNewsListViewController.h"
#import "UIImageView+WebCache.h"
#import "PureLayout.h"

@interface ZWArticleSubscriptionView ()

/** 订阅号信息 */
@property (nonatomic, strong) ZWSubscriptionModel *model;

/** 订阅频道Logo */
@property (nonatomic, strong) UIImageView *logo;

/** 订阅频道标题 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 订阅频道副标题 */
@property (nonatomic, strong) UILabel *subtitleLabel;

/** 订阅按钮 */
@property (nonatomic, strong) ZWSubscribeButton *subscribeButton;

/** 当前视图所在的视图控制器 */
@property (nonatomic, strong) UIViewController *attachedController;

@end

@implementation ZWArticleSubscriptionView

- (instancetype)initWithFrame:(CGRect)frame
                        model:(ZWSubscriptionModel *)model
           attachedController:(UIViewController *)controller {
    if (self = [self initWithFrame:frame]) {
        self.model = model;
        self.attachedController = controller;
    }
    return self;
}

- (UIImageView *)logo {
    if (!_logo) {
        _logo = [UIImageView newAutoLayoutView];
    }
    return _logo;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel newAutoLayoutView];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = COLOR_333333;
        _titleLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [UILabel newAutoLayoutView];
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.textColor = COLOR_848484;
        _subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _subtitleLabel;
}

- (ZWSubscribeButton *)subscribeButton {
    if (!_subscribeButton) {
        _subscribeButton = [ZWSubscribeButton newAutoLayoutView];
        _subscribeButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
         [_subscribeButton setTitleColor:COLOR_333333 forState:UIControlStateNormal];
        [_subscribeButton setTitle:@"立即订阅" forState:UIControlStateNormal];
        _subscribeButton.layer.borderColor = COLOR_E5E5E5.CGColor;
        _subscribeButton.layer.borderWidth = 0.5f;
        
        ZWArticleSubscriptionView *weakSelf = self;
        
        // 状态变更回调函数
        _subscribeButton.statusChangeBlock = ^(ZWSubscribeButton *button) {
            NSString *title = weakSelf.model.isSubscribed? @"立即查看" : @"立即订阅";
            [button setTitle:title forState:UIControlStateNormal];
        };
        
        // 点击按钮事件
        [_subscribeButton addAction:^(UIButton *btn) {
            
            ZWSubscribeButton *weakButton = (ZWSubscribeButton *)btn;
            
            if (weakSelf.model.isSubscribed) {
                // 已经订阅，查看新闻列表
                [weakSelf pushSubscribeNewsListViewControllerWithModel:weakSelf.model];
            } else {
                // 已经登录，直接订阅
                if ([ZWUserInfoModel login]) {
                    
                    [ZWSubscribeManager updateSubscribeStatusWithModel:weakSelf.model
                                                          successBlock:^(id result) {
                                                              [weakButton postStatusChangeNotification];
                                                          }
                                                          failureBlock:nil];
                    
                } else {
                    // 尚未登录，先登录，再订阅
                    ZWLoginViewController *nextViewController = [ZWLoginViewController viewControllerWithSuccessBlock:^{
                        
                        [ZWSubscribeManager updateSubscribeStatusWithModel:weakSelf.model
                                                              successBlock:^(id result) {
                                                                  [weakButton postStatusChangeNotification];
                                                              }
                                                              failureBlock:nil];
                    } failureBlock:nil finallyBlock:nil];
                    [weakSelf.attachedController.navigationController pushViewController:nextViewController animated:YES];
                }
            }
        }];
    }
    return _subscribeButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self addSubview:self.logo];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
    [self addSubview:self.subscribeButton];
    
    // 图标自适配
    [self.logo autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:7.0f];
    [self.logo autoSetDimensionsToSize:CGSizeMake(40.0f, 40.0f)];
    [self.logo autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    // 标题自适配
    [self.titleLabel autoSetDimension:ALDimensionHeight toSize:18.0f];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.logo withOffset:12.0f];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15.0f];
    
    // 副标题自适配
    [self.subtitleLabel autoSetDimension:ALDimensionHeight toSize:15.0f];
    [self.subtitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleLabel];
    [self.subtitleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.titleLabel];
    [self.subtitleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:6.0f];
    
    // 订阅按钮自适配
    [self.subscribeButton autoSetDimensionsToSize:CGSizeMake(75.0f, 30.0f)];
    [self.subscribeButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.subscribeButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:7.0f];
    [self.subscribeButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:8.0f];
}

- (void)setModel:(ZWSubscriptionModel *)model {
    _model = model;
    if (_model) {
        [self.logo sd_setImageWithURL:_model.logo];
        self.titleLabel.text = _model.title;
        self.subtitleLabel.text = _model.subtitle;
        self.subscribeButton.model = _model;
    }
}

/** 进入选中的订阅号新闻列表界面 */
- (void)pushSubscribeNewsListViewControllerWithModel:(ZWSubscriptionModel *)model {
    ZWSubscribeNewsListViewController *nextViewController = [[ZWSubscribeNewsListViewController alloc] initWithModel:model];
    [self.attachedController.navigationController pushViewController:nextViewController animated:YES];
}

@end
