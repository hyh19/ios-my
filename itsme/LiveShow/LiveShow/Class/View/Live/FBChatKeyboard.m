#import "FBChatKeyboard.h"
#import "UIImage-Helpers.h"
#import "DAKeyboardControl.h"

@interface FBChatKeyboard () <UITextFieldDelegate>

@property (nonatomic, strong, readwrite) UITextField *textField;

@property (nonatomic, strong, readwrite) UIButton *sendButton;

@property (nonatomic, strong, readwrite) UIButton *bulletButton;

@property (nonatomic, strong, readwrite) UIView *spliterView;

@property (nonatomic) FBMessageType type;

@property (nonatomic, strong) UIView *tipView;

@end

@implementation FBChatKeyboard

- (void)dealloc {
    [self removeKeyboardControl];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.type = kMessageTypeDefault;
        
        UIView *superView = self;
        __weak typeof(self) wself = self;
        
        [self addSubview:self.bulletButton];
        [self addSubview:self.sendButton];
        [self addSubview:self.textField];
        [self addSubview:self.tipView];
        [self addSubview:self.spliterView];
        
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(66, 35));
            make.right.equalTo(superView).offset(-2.5);
            make.centerY.equalTo(superView);
        }];
        
        [self.sendButton bk_addEventHandler:^(id sender) {
            if ([wself.textField.text isValid]) {
                if (wself.doSendMessageAction) {
                    wself.doSendMessageAction(self.textField.text, self.type);
                }
                wself.textField.text = nil;
                wself.sendButton.enabled = NO;
            }
        } forControlEvents:UIControlEventTouchUpInside];
        self.sendButton.enabled = NO;
        
        [self.spliterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wself.bulletButton.mas_right);
            make.size.equalTo(CGSizeMake(0.5, 35));
            make.centerY.equalTo(wself.sendButton);
        }];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wself.bulletButton.mas_right).offset(10);
            make.right.equalTo(wself.sendButton.mas_left).offset(-5);
            make.height.equalTo(35);
            make.centerY.equalTo(wself.sendButton);
        }];
        
        [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.bulletButton);
            make.bottom.equalTo(self.bulletButton.mas_top).offset(-18);
            make.height.equalTo(35);
        }];
        self.tipView.hidden = YES;
    }
    return self;
}

- (UIButton *)bulletButton {
    if (!_bulletButton) {
        _bulletButton = [[UIButton alloc] init];
        [_bulletButton setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
        [_bulletButton setImage:[UIImage imageNamed:@"on"] forState:UIControlStateSelected];
        [_bulletButton bk_addEventHandler:^(id sender) {
            [self onTouchButtonDanmu];
        } forControlEvents:UIControlEventTouchDown];
    }
    return _bulletButton;
}

- (UIView *)spliterView
{
    if(nil == _spliterView) {
        _spliterView = [[UIView alloc] init];
        _spliterView.backgroundColor = [UIColor hx_colorWithHexString:@"#cccccc"];
    }
    return _spliterView;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[UIButton alloc] init];
        [_sendButton setTitle:kLocalizationButtonSend forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor hx_colorWithHexString:@"ff4572"] forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor hx_colorWithHexString:@"cccccc"] forState:UIControlStateDisabled];
        _sendButton.layer.cornerRadius = 2.5;
        _sendButton.clipsToBounds = YES;
    }
    return _sendButton;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.returnKeyType = UIReturnKeySend;
        _textField.enablesReturnKeyAutomatically = YES;
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kLocalizationChatPlaceHolder attributes:@{NSForegroundColorAttributeName : [UIColor hx_colorWithHexString:@"cccccc"], NSFontAttributeName : [UIFont systemFontOfSize:15]}];
        __weak typeof(self) wself = self;
        [_textField setBk_shouldChangeCharactersInRangeWithReplacementStringBlock:^BOOL(UITextField *textField, NSRange range, NSString *string) {
            NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
            wself.sendButton.enabled = [text isValid];
            return YES;
        }];
    }
    return _textField;
}

- (FBMessageType)type {
    if (self.bulletButton.isSelected) {
        return kMessageTypeDanmu;
    }
    return kMessageTypeDefault;
}

- (UIView *)tipView {
    if (!_tipView) {
        _tipView = [[UIView alloc] init];
        _tipView.backgroundColor = [UIColor clearColor];
        [_tipView debugWithBorderColor:[UIColor blueColor]];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image  = [[UIImage imageNamed:@"room_bg_danmu_tip"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 34, 12, 2)];
        [imageView debugWithBorderColor:[UIColor greenColor]];
        [_tipView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = kLocalizationBulletOn;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        [label debug];
        [_tipView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_tipView).offset(8);
            make.top.bottom.equalTo(_tipView);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_tipView);
            make.right.equalTo(label).offset(8);
            make.top.equalTo(_tipView);
            make.bottom.equalTo(_tipView).offset(5.5);
        }];
    }
    return _tipView;
}

- (BOOL)isBullet {
    return self.bulletButton.isSelected;
}

- (void)setHideDanmuButton:(BOOL)hideDanmuButton {
    _hideDanmuButton = hideDanmuButton;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)updateConstraints {
    [self.bulletButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.isHideDanmuButton) {
            make.size.equalTo(CGSizeMake(0, 35));
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(0);
        } else {
            make.size.equalTo(CGSizeMake(60, 35));
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(2.5);
        }
    }];
    [super updateConstraints];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.textField.text isValid]) {
        if (self.doSendMessageAction) {
            self.doSendMessageAction(self.textField.text, self.type);
        }
        self.textField.text = nil;
        self.sendButton.enabled = NO;
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length > 60) {
        textField.text = [text substringToIndex:60];
        return NO;
    }
    return YES;
}

//用于监听联想输入
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.textField) {
        
        self.sendButton.enabled = textField.text.length > 0 ? YES : NO;
        
        if (textField.text.length > 60) {
            textField.text = [textField.text substringToIndex:60];
        }
    }
}

- (void)onTouchButtonDanmu {
    self.bulletButton.selected = !self.bulletButton.selected;
    
    self.tipView.hidden = !self.bulletButton.selected;
    if (!self.tipView.hidden) {
        [self bk_performBlock:^(id obj) {
            self.tipView.hidden = YES;
        } afterDelay:2];
    }

    NSString *placeholder = nil;
    if (self.bulletButton.isSelected) {
        placeholder = kLocalizationOpenDanmuTips;
    } else {
        placeholder = kLocalizationChatPlaceHolder;
    }
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor hx_colorWithHexString:@"444444"],
                                  NSFontAttributeName : [UIFont systemFontOfSize:15] };
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:attributes];
    
}

@end
