//
//  XXMyFollowCell.m
//  LiveShow
//
//  Created by iOS on 16/2/3.
//  Copyright © 2016年 XX. All rights reserved.
//
#import "UIImageView+WebCache.h"
#import "FBContactsCell.h"
#import "FBUserInfoModel.h"
#import "FBContactsModel.h"
#import "FBLoginInfoModel.h"

@interface FBContactsCell ()
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *verifyICon;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UIView *levelView;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;
@property (weak, nonatomic) IBOutlet UILabel *descripitonLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidth;

@end

@implementation FBContactsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.image = [UIImage imageNamed:kLogoDefaultAvatar];
    if (SCREEN_WIDTH == 320) {
        self.nameLabelWidth.constant = 130;
    } else {
        self.nameLabelWidth.constant = 180;
    }
}

- (void)setContacts:(FBContactsModel *)contacts {
    _contacts = contacts;
    //隐藏登录用户自己关注按钮 和黑名单用户的关注按钮
    if ([_contacts.user.userID isEqualToString:[[FBLoginInfoModel sharedInstance] userID]] || [_contacts.relation isEqualToString:@"black"]) {
        _followButton.hidden = YES;
    } else {
        _followButton.hidden = NO;
    }
    
    [_avatarImageView fb_setImageWithName:_contacts.user.portrait size:CGSizeMake(120, 120) placeholderImage:kDefaultImageAvatar completed:nil];
    
    _nameLabel.text = _contacts.user.nick;
    _genderImageView.image = [_contacts.user.gender isEqualToNumber:@(0)] ? [UIImage imageNamed:@"pub_icon_female"] : [UIImage imageNamed:@"pub_icon_male"];
    
    
    _levelLabel.text = [_contacts.user.ulevel stringValue];
    [self setLevelBackgroundColor];

    if (_contacts.user.Description.length != 0) {
        _descripitonLabel.text = _contacts.user.Description;
    } else {
        _descripitonLabel.text = nil;
    }
    
    
    if ([_contacts.relation isEqualToString:@"friend"] || [_contacts.relation isEqualToString:@"following"]) {
        _followButton.selected = YES;
    } else {
        _followButton.selected = NO;
    }
    
    _verifyICon.hidden = !_contacts.user.isVerifiedBroadcastor;
    
    if (_contacts.isLive == 1) {
        _followButton.enabled = NO;
        [_followButton setImage:[UIImage imageNamed:@"pub_icon_livestatus1"] forState:UIControlStateNormal];
        NSMutableArray *imgArray = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"pub_icon_livestatus1"],[UIImage imageNamed:@"pub_icon_livestatus2"], nil];
        [_followButton.imageView setAnimationImages:[imgArray copy]];
        [_followButton.imageView setAnimationDuration:1];
        [_followButton.imageView startAnimating];
    } else {
        _followButton.enabled = YES;
        [_followButton setImage:[UIImage imageNamed:@"pub_btn_follow"] forState:UIControlStateNormal];
        [_followButton.imageView stopAnimating];
    }
}


- (IBAction)followButtonDidClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(contactsCell:changeFollowStatus:)]) {
        [_delegate contactsCell:self changeFollowStatus:sender];
    }
}

- (void)cellColorWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 != 0) {
        self.backgroundColor = [UIColor hx_colorWithHexString:@"fdfdfd"];
    } else {
        self.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff"];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setLevelBackgroundColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setLevelBackgroundColor];
}

- (void)setLevelBackgroundColor {
    if (_contacts.user.ulevel.intValue >= 0 && _contacts.user.ulevel.intValue <= 7) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_star"];
        _levelView.backgroundColor = COLOR_ASSIST_TEXT;
    } else if (_contacts.user.ulevel.intValue >= 8 && _contacts.user.ulevel.intValue <= 16) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_moon"];
        _levelView.backgroundColor = COLOR_4A87F6;
    } else if (_contacts.user.ulevel.intValue >= 17 && _contacts.user.ulevel.intValue <= 31) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_sun"];
        _levelView.backgroundColor = COLOR_FA9F47;
    } else if (_contacts.user.ulevel.intValue >= 32 && _contacts.user.ulevel.intValue <= 63) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_crown"];
        _levelView.backgroundColor = COLOR_FAD247;
    } else if (_contacts.user.ulevel.intValue >= 64 && _contacts.user.ulevel.intValue <= 127) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_golden_crown"];
        _levelView.backgroundColor = COLOR_5061E4;
    } else {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_purple_crown"];
        _levelView.backgroundColor = COLOR_AC47FA;
    }
}

@end
