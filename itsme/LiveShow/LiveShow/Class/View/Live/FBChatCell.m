#import "FBChatCell.h"
#import "FBLevelView.h"
#import "UIImage-Helpers.h"

#define kLabelContainerBackgroundColor [UIColor hx_colorWithHexString:@"ffffff" alpha:0.6]

@interface FBChatCell () <M80AttributedLabelDelegate>

@end

@implementation FBChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self debugWithBorderColor:[UIColor yellowColor]];
        [self.labelContainer addSubview:self.label];
        [self addSubview:self.labelContainer];
    }
    return self;
}

- (UIView *)labelContainer {
    if (!_labelContainer) {
        _labelContainer = [[UIView alloc] initWithFrame:CGRectZero];
//        _labelContainer.backgroundColor = kLabelContainerBackgroundColor;
//        _labelContainer.layer.cornerRadius = 13;
        [_labelContainer debugWithBorderColor:[UIColor blueColor]];
    }
    return _labelContainer;
}

- (M80AttributedLabel *)label {
    if (!_label) {
        _label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.delegate = self;
    }
    return _label;
}

- (void)setMessage:(FBMessageModel *)message {
    _message = message;
    [FBChatCell configLabel:self.label withMessage:message];
}

+ (void)configLabel:(M80AttributedLabel *)label withMessage:(FBMessageModel *)message {
    label.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.5];
    label.shadowOffset = CGSizeMake(0.5, 0.5);
    label.underLineForLink = NO;
    label.autoDetectLinks = NO;
    label.highlightColor = [UIColor clearColor];
    label.linkColor = COLOR_ASSIST_TEXT;
    if (message.type == kMessageTypeFollow      ||
        message.type == kMessageTypeShare       ||
        message.type == kMessageTypeAuthorize   ||
        message.type == kMessageTypeUnauthorize ||
        message.type == kMessageTypeTalkBanned) {
        label.textColor = COLOR_TEXT_HIGHLIGHT;
        label.font = [UIFont boldSystemFontOfSize:17];
    } else if (message.type == kMessageTypeGift) {
        label.textColor = COLOR_ASSIST_BUTTON;
        label.font = [UIFont boldSystemFontOfSize:17];
    } else if (message.type == kMessageTypeSystem ||
               message.type == kMessageTypeAssistant) {
        label.textColor = COLOR_ASSIST_TEXT;
        label.font = [UIFont boldSystemFontOfSize:15];
    } else {
        label.textColor = message.contentColor;
        label.font = [UIFont boldSystemFontOfSize:17];
    }
    
    [label setText:@""];
    
    NSString *name = message.fromUser.nick;
    NSString *content = message.content;
    
    // 一般用户要显示等级、普通用户进场也显示等级
    if (kMessageTypeDefault == message.type ||
        kMessageTypeHit == message.type     ||
        kMessageTypeGift == message.type    ||
        kMessageTypeCommonUserEnter == message.type ||
        kMessageTypeShare == message.type) {
        FBLevelView *levelView = [[FBLevelView alloc] init];
        levelView.frame = CGRectMake(0, 0, 22, 13);
        levelView.level = [message.fromUser.ulevel integerValue];
        levelView.background.layer.cornerRadius = 13.0/2;
        [label appendView:levelView margin:UIEdgeInsetsMake(0, 0, 0, 5) alignment:M80ImageAlignmentCenter];
    }
    
    if (message.type == kMessageTypeAssistant ||
        message.type == kMessageTypeVIPEnter  ||
        message.type == kMessageTypeCommonUserEnter) {
        // 不带昵称
    } else {
        NSString *formattedName = [NSString stringWithFormat:@"%@  ", name];
        NSAttributedString *attributedName = [[NSAttributedString alloc] initWithString:formattedName
                                                                             attributes:@{NSForegroundColorAttributeName : message.contentColor,
                                                                                          NSFontAttributeName : [UIFont boldSystemFontOfSize:17]}];
        [label appendAttributedText:attributedName];
        // 可点击的事件
        NSRange clickRange = [label.text rangeOfString:formattedName];
        [label addCustomLink:[NSValue valueWithRange:clickRange]
                    forRange:clickRange];
    }
    
    if (message.type == kMessageTypeVIPEnter ||
        message.type == kMessageTypeCommonUserEnter) {
        NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content
                                                                                              attributes:@{NSForegroundColorAttributeName : message.contentColor,NSFontAttributeName : [UIFont boldSystemFontOfSize:17]}];
        // 高亮进场用户的昵称
        NSRange highlightedRange = [content rangeOfString:name];
        [attributedContent addAttribute:NSForegroundColorAttributeName value:COLOR_ASSIST_TEXT range:highlightedRange];
        [label appendAttributedText:attributedContent];
        
        // 可点击的事件
        NSRange clickRange = [label.text rangeOfString:name];
        [label addCustomLink:[NSValue valueWithRange:clickRange]
                    forRange:clickRange];
    } else {
        if (kMessageTypeHit == message.type) {
            content = kLocalizationClickHit;
        }
        [label appendText:content];
    }
    
    if (kMessageTypeHit == message.type) {
        UIImageView *hitView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 17.04, 15.33)];
        hitView.image = [UIImage imageWithColor:message.hitColor];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = [FBUtility hitHeartPath].CGPath;
        maskLayer.frame = hitView.bounds;
        hitView.layer.mask = maskLayer;
        [label appendView:hitView margin:UIEdgeInsetsMake(0, 2, 0, 0) alignment:M80ImageAlignmentCenter];
    }
    
    [label debugWithBorderColor:[UIColor greenColor]];
}

+ (CGFloat)labelHeightForMessage:(FBMessageModel *)message {
    M80AttributedLabel *label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
    [FBChatCell configLabel:label withMessage:message];
    CGSize size = [label sizeThatFits:CGSizeMake(kCellWidth-2*(kLabelInset.left+kLabelInset.right+kLabelContainerInset.left+kLabelContainerInset.right), CGFLOAT_MAX)];
    return size.height - 3;
}

+ (CGFloat)singleLineLabelHeightForMessage:(FBMessageModel *)message {
    M80AttributedLabel *label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 1;
    [FBChatCell configLabel:label withMessage:message];
    CGSize size = [label sizeThatFits:CGSizeMake(kCellWidth-2*(kLabelInset.left+kLabelInset.right+kLabelContainerInset.left+kLabelContainerInset.right), CGFLOAT_MAX)];
    return size.height - 3;
}

+ (CGFloat)singleLineLabelWidthForMessage:(FBMessageModel *)message {
    M80AttributedLabel *label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 1;
    [FBChatCell configLabel:label withMessage:message];
    CGSize size = [label sizeThatFits:CGSizeMake(CGFLOAT_MAX, [FBChatCell singleLineLabelHeightForMessage:message])];
    return size.width;
}

- (void)m80AttributedLabel:(M80AttributedLabel *)label
             clickedOnLink:(id)linkData {
    if (kMessageTypeSystem != self.message.type &&
        kMessageTypeAuthorize != self.message.type &&
        kMessageTypeUnauthorize != self.message.type &&
        kMessageTypeTalkBanned != self.message.type) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenUserCard object:self.message.fromUser];
    }
}

@end
