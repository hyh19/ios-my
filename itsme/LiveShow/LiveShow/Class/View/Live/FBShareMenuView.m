//
//  FBShareMenuVIew.m
//  LiveShow
//
//  Created by tak on 16/9/1.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBShareMenuView.h"

typedef NS_ENUM(NSInteger, FBShareItemType) {
    FBShareItemTypeFacebook = 1,
    FBShareItemTypeTwitter  = 2,
    FBShareItemTypeLine     = 3,
    FBShareItemTypeVK       = 4,
    FBShareItemTypeKakao    = 5
};

CGFloat const titleHeight   = 50;
CGFloat const itemHeight    = 80;
CGFloat const bottomPadding = 20;
CGFloat menuViewHeight = titleHeight + itemHeight + bottomPadding;

@interface FBShareMenuView ()

@property (nonatomic, strong) NSArray *icons;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation FBShareMenuView

- (NSArray *)icons {
    if (!_icons) {
        _icons = @[[UIImage imageNamed:@"share_btn_facebook"],
                   [UIImage imageNamed:@"share_btn_twitter"],
                   [UIImage imageNamed:@"share_btn_line"],
                   [UIImage imageNamed:@"share_btn_vk"],
                   [UIImage imageNamed:@"share_btn_kakao"]];
    }
    return _icons;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"Facebook",@"Twitter",@"Line",@"VK",@"Kakao Talk"];
    }
    return _titles;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, SCREEN_HEIGH - menuViewHeight , SCREEN_WIDTH, menuViewHeight)]) {
        self.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.95];
        [self setupTitleLabel];
        [self setupShareButton];
    }
    return self;
}

- (void)setupTitleLabel {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, titleHeight)];
    title.text = kLocalizationShareFriendTip;
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor hx_colorWithHexString:@"444444"];
    title.font = [UIFont systemFontOfSize:13];
    [self addSubview:title];
}

- (void)setupShareButton {
    CGFloat itemCount = 5;
    CGFloat itemIconWidth = 52;
    CGFloat itemPadding = (SCREEN_WIDTH - itemCount * itemIconWidth) / (itemCount + 1);
    CGFloat itemX;
    CGFloat itemY = titleHeight;
    for (int i = 0; i < itemCount; ++i) {
        itemX = itemPadding + (itemPadding + itemIconWidth) * i;
        FBShareItem *btn = [[FBShareItem alloc] init];
        btn.tag = i + 1;
        [btn addTarget:self action:@selector(onTounchButtonToShare:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(itemX, itemY, itemIconWidth, itemIconWidth + 20);
        [btn setImage:self.icons[i] forState:UIControlStateNormal];
        [btn setTitle:self.titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor hx_colorWithHexString:@"888888"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:10];
        [btn.titleLabel sizeToFit];
        [self addSubview:btn];
    }
}


- (void)onTounchButtonToShare:(FBShareItem *)shareItem {
    NSLog(@"%zd",shareItem.tag);
    if (self.doShareLiveAction) {
        switch (shareItem.tag) {
            case FBShareItemTypeFacebook:
                self.doShareLiveAction(kPlatformFacebook, kShareLiveActionClickLiveRoomMenu,self);
                break;
            case FBShareItemTypeTwitter:
                self.doShareLiveAction(kPlatformTwitter, kShareLiveActionClickLiveRoomMenu,self);
                break;
            case FBShareItemTypeLine:
                self.doShareLiveAction(kPlatformLine, kShareLiveActionClickLiveRoomMenu,self);
                break;
            case FBShareItemTypeVK:
                self.doShareLiveAction(kPlatformVK, kShareLiveActionClickLiveRoomMenu,self);
                break;
            case FBShareItemTypeKakao:
                self.doShareLiveAction(kPlatformKakao, kShareLiveActionClickLiveRoomMenu,self);
                break;
            default:
                break;
        }
    }

}

- (void)dissmiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.y = SCREEN_HEIGH;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCloseShareMenu object:nil];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dissmiss];
}

@end




@implementation FBShareItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 调整图片
    self.imageView.x = 0;
    self.imageView.y = 0;
    self.imageView.width = self.width;
    self.imageView.height = self.imageView.width;
    
    // 调整文字
    self.titleLabel.x = 0;
    self.titleLabel.y = self.imageView.height;
    self.titleLabel.width = self.width;
    self.titleLabel.height = self.height - self.titleLabel.y;
}
@end

