#import "ZWSubscriptionCell.h"
#import "UIImageView+WebCache.h"
#import "ZWSubscribeButton.h"
#import "ZWSubscriptionViewController.h"
#import "UIButton+Block.h"
#import "ZWSubscribeManager.h"
#import "ZWLoginViewController.h"

@interface ZWSubscriptionCell ()

/** Logo */
@property (weak, nonatomic) IBOutlet UIImageView *logo;

/** 标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/** 副标题 */
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

/** 订阅按钮 */
@property (weak, nonatomic) IBOutlet ZWSubscribeButton *subscribeButton;

@end

@implementation ZWSubscriptionCell

- (void)awakeFromNib {
    
    self.subscribeButton.layer.borderWidth = 0.5;
    self.subscribeButton.layer.borderColor = COLOR_E5E5E5.CGColor;
    
    ZWSubscriptionCell *weakSelf = self;
    
    self.subscribeButton.statusChangeBlock = ^(ZWSubscribeButton *button) {
        NSString *title = _model.isSubscribed? @"取消" : @"订阅";
        [button setTitle:title forState:UIControlStateNormal];
        
        NSString *imageName = button.model.isSubscribed? @"icon_remove" : @"icon_add";
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    };
    
    [self.subscribeButton addAction:^(UIButton *btn) {
        
        ZWSubscribeButton *weakButton = (ZWSubscribeButton *)btn;
        
        // 已经登录，直接订阅
        if ([ZWUserInfoModel login]) {
            
            [ZWSubscribeManager updateSubscribeStatusWithModel:weakButton.model
                                                  successBlock:^(id result) {
                                                      [weakButton postStatusChangeNotification];
                                                  }
                                                  failureBlock:nil];
            
        } else {
            // 尚未登录，先登录，再订阅
            ZWLoginViewController *nextViewController = [ZWLoginViewController viewControllerWithSuccessBlock:^{
                
                [ZWSubscribeManager updateSubscribeStatusWithModel:weakButton.model
                                                      successBlock:^(id result) {
                                                          [weakButton postStatusChangeNotification];
                                                      }
                                                      failureBlock:nil];
            } failureBlock:nil finallyBlock:nil];
            [weakSelf.attachedController.navigationController pushViewController:nextViewController animated:YES];
        }
    }];
}

- (void)setModel:(ZWSubscriptionModel *)model {
    _model = model;
    if (_model) {
        self.titleLabel.text = _model.title;
        self.subtitleLabel.text = _model.subtitle;
        self.subscribeButton.model = _model;
        [self.logo sd_setImageWithURL:_model.logo];
    }
}

@end
