#import "ZWSubscriptionView.h"
#import "UIImageView+WebCache.h"
#import "ZWSubscribeButton.h"
#import "ZWNewsModel.h"

@interface ZWSubscriptionView ()

/** Logo */
@property (weak, nonatomic) IBOutlet UIImageView *logo;

/** 标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/** 副标题/简介 */
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

/** 订阅按钮 */
@property (weak, nonatomic) IBOutlet ZWSubscribeButton *subscribeButton;

/** 大新闻图片 */
@property (weak, nonatomic) IBOutlet UIImageView *bigNewsImageView;

/** 大新闻标题 */
@property (weak, nonatomic) IBOutlet UILabel *bigNewsTitleLabel;

/** 第二条热读新闻标题 */
@property (weak, nonatomic) IBOutlet UILabel *secondNewsTitleLabel;

/** 第三条热读新闻标题 */
@property (weak, nonatomic) IBOutlet UILabel *thirdNewsTitleLabel;

/** 订阅号信息 */
@property (nonatomic, strong) ZWSubscriptionModel *model;

@end

@implementation ZWSubscriptionView

- (instancetype)initWithModel:(ZWSubscriptionModel *)model {
    self = [ZWSubscriptionView view];
    if (self) {
        self.model = model;
    }
    return self;
}

- (void)setModel:(ZWSubscriptionModel *)model {
    _model = model;
    if (_model) {
        [self.logo sd_setImageWithURL:_model.logo];
        self.titleLabel.text = _model.title;
        self.subtitleLabel.text = _model.subtitle;
        self.subscribeButton.model = _model;
        [self configureHotNews:_model.hotNews];
    }
}

/** 配置热读新闻 */
- (void)configureHotNews:(NSArray *)hotNews {
    
    if (hotNews && [hotNews count]>2) {
        
        ZWNewsModel *model = hotNews[0];
        self.bigNewsTitleLabel.text = model.newsTitle;
        
        NSArray *images = model.picList;
        if (images && [images count]>0) {
            ZWPicModel *image = images[0];
            [self.bigNewsImageView sd_setImageWithURL:[NSURL URLWithString:image.picUrl]];
        }
        
        ZWNewsModel *second = hotNews[1];
        self.secondNewsTitleLabel.text = second.newsTitle;
        
        ZWNewsModel *third = hotNews[2];
        self.thirdNewsTitleLabel.text = third.newsTitle;
    }
}

/** 点击热读新闻广播点击事件通知 */
- (IBAction)onTapGestureShowDetail:(UITapGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    ZWNewsModel *model = nil;
    
    if (view == self.bigNewsImageView) {
        model = self.model.hotNews[0];
    } else if (view == self.secondNewsTitleLabel) {
        model = self.model.hotNews[1];
    } else if (view == self.thirdNewsTitleLabel) {
        model = self.model.hotNews[2];
    }
    NSNotification *notification = [NSNotification notificationWithName:kNotificationHotNews object:model];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

+ (ZWSubscriptionView *)view {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ZWSubscriptionView class]) owner:self options:nil];
    for (id obj in array) {
        if ([obj isKindOfClass:[ZWSubscriptionView class]]) {
            return obj;
        }
    }
    return nil;
}

@end
