#import "FBLiveBottomView.h"
#import "FBLoginInfoModel.h"
#import "FBFastStatementView.h"

@interface FBLiveBottomView () <UIGestureRecognizerDelegate, FBFastStatementViewDelegate>

/** 直播类型 */
@property (nonatomic, assign) FBLiveType type;

/** 聊天按钮 */
@property (nonatomic, strong) UIButton *chatButton;

/** 摄像头按钮 */
@property (nonatomic, strong) UIButton *cameraButton;

/** 礼物按钮 */
@property (nonatomic, strong) UIButton *giftButton;

/** 分享按钮 */
@property (nonatomic, strong) UIButton *shareButton;

/** 直播回放的控制面板 */
@property (nonatomic, strong) FBReplayControlPanel *replayPanel;

@end

@implementation FBLiveBottomView

- (instancetype)initWithType:(FBLiveType)type {
    if (self = [super init]) {
        self.type = type;
        UIView *superView = self;
        CGFloat offset = 10;
        CGFloat width = 38;
        
        // 直播回放需要显示回放控制面板
        if (kLiveTypeReplay == self.type) {
            [self addSubview:self.replayPanel];
            [self.replayPanel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(superView);
            }];
        } else {
            [self addSubview:self.chatButton];
            [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(35);
                make.left.equalTo(superView).offset(offset);
                make.right.equalTo(superView).offset(-offset*3-width*2);
                make.centerY.equalTo(superView);
            }];
            FBFastStatementView *view = [[FBFastStatementView alloc] init];
            view.delegate = self;
        }
        
        if (kLiveTypeBroadcast == self.type) {
            
            [self addSubview:self.cameraButton];
            [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(width, width));
                make.right.equalTo(superView).offset(-offset);
                make.centerY.equalTo(superView);
            }];
            
            [self addSubview:self.shareButton];
            [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(width, width));
                make.right.equalTo(self.cameraButton.mas_left).offset(-offset);
                make.centerY.equalTo(superView);
            }];
            
        } else {
            [self addSubview:self.giftButton];
            [self.giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(width, width));
                make.right.equalTo(superView).offset(-offset);
                make.centerY.equalTo(superView);
            }];
            
            [self addSubview:self.shareButton];
            [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(width, width));
                make.right.equalTo(self.giftButton.mas_left).offset(-offset);
                make.centerY.equalTo(superView);
            }];
            
        }
        
        
    }
    return self;
}

- (UIButton *)chatButton {
    if (!_chatButton) {
        _chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _chatButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        _chatButton.layer.cornerRadius = 35/2;
//        _chatButton.layer.borderWidth = 0.5;
        _chatButton.clipsToBounds = YES;
        [_chatButton setTitle:kLocalizationQuickChat forState:UIControlStateNormal];
        [_chatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_chatButton setBackgroundColor:[UIColor hx_colorWithHexString:@"000000" alpha:0.4]];
//        [_chatButton setBackgroundColor:[UIColor hx_colorWithHexString:@"ffffff" alpha:0.6]];
        [_chatButton.titleLabel setFont:FONT_SIZE_14];
//        [_chatButton.titleLabel.layer setShadowColor:[UIColor blackColor].CGColor];
//        [_chatButton.titleLabel.layer setShadowOpacity:0.3f];
//        [_chatButton.titleLabel.layer setShadowOffset:CGSizeMake(0.5f, 0.5f)];
//        [_chatButton.titleLabel.layer setShadowRadius:1.0f];
        _chatButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _chatButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        
        __weak typeof(self) wSelf = self;
        [_chatButton bk_addEventHandler:^(id sender) {
            if (wSelf.doOpenChatKeyboardAction) {
                wSelf.doOpenChatKeyboardAction();
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                     action:@"发言"
                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                      value:@(1)];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_chatButton debug];
        
    }
    return _chatButton;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setImage:[UIImage imageNamed:@"room_btn_camera_nor"] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:@"room_btn_camera_hig"] forState:UIControlStateHighlighted];
        [_cameraButton bk_addEventHandler:^(id sender) {
            //相对父view的区域
            CGRect fram = _cameraButton.frame;
            fram.origin.y += self.frame.origin.y;
            NSDictionary *area = @{@"x": @(fram.origin.x),
                                   @"y": @(fram.origin.y),
                                   @"width": @(fram.size.width),
                                   @"height": @(fram.size.height)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCameraMenu object:area];
        } forControlEvents:UIControlEventTouchUpInside];
        [_cameraButton debug];
    }
    return _cameraButton;
}

- (UIButton *)giftButton{
    if (!_giftButton) {
        _giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_giftButton setImage:[UIImage imageNamed:@"room_btn_gift_nor"] forState:UIControlStateNormal];
        [_giftButton setImage:[UIImage imageNamed:@"room_btn_gift_hig"] forState:UIControlStateHighlighted];
        __weak typeof(self) wself = self;
        [_giftButton bk_addEventHandler:^(id sender) {
            if (wself.doOpenGiftKeyboardAction) {
                wself.doOpenGiftKeyboardAction();
                [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                     action:@"礼物"
                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                      value:@(1)];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_giftButton debug];
    }
    return _giftButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"room_btn_share_nor"] forState:UIControlStateNormal];
        [_shareButton setImage:[UIImage imageNamed:@"room_btn_share_hig"] forState:UIControlStateHighlighted];
        __weak typeof(self) wSelf = self;
        [_shareButton bk_addEventHandler:^(UIButton *btn) {
            if (wSelf.doOpenShareMenuAction) {
                wSelf.doOpenShareMenuAction(btn);
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                     action:@"分享"
                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                      value:@(1)];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_shareButton debug];
    }
    return _shareButton;
}

- (FBReplayControlPanel *)replayPanel {
    if (!_replayPanel) {
        _replayPanel = [[FBReplayControlPanel alloc] init];
        _replayPanel.backgroundColor = [UIColor clearColor];
    }
    return _replayPanel;
}

- (void)changButton {
    [self.chatButton setTitle:kLocalizationChatPlaceHolder forState:UIControlStateNormal];
}

@end
