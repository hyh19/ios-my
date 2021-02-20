//
//  XXPushMangementCell.m
//  LiveShow
//
//  Created by lgh on 16/2/16.
//  Copyright © 2016年 XX. All rights reserved.
//

#import "FBNotificationCell.h"
#import "FBLevelView.h"


@interface FBNotificationCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;

@property (weak, nonatomic) IBOutlet UIView *levelView;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *verfityIcon;

@end

@implementation FBNotificationCell



- (void)setNotifier:(FBNotifierModel *)notifier {
    _notifier = notifier;
    [_avatarImageView fb_setImageWithName:_notifier.user.portrait size:CGSizeMake(120, 120) placeholderImage:kDefaultImageAvatar completed:nil];
    _nickNameLabel.text = _notifier.user.nick;
    _summaryLabel.text = _notifier.user.Description;
    _genderImageView.image = _notifier.user.gender == 0 ? [UIImage imageNamed:@"pub_icon_female"] : [UIImage imageNamed:@"pub_icon_male"];
    _notificationSwitch.on = [_notifier.stat isEqual:@1];

    _verfityIcon.hidden = !_notifier.user.isVerifiedBroadcastor;
    
    if (_notifier.user.ulevel.intValue >= 1 && _notifier.user.ulevel.intValue <= 7) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_star"];
        _levelView.backgroundColor = COLOR_ASSIST_TEXT;
    } else if (_notifier.user.ulevel.intValue >= 8 && _notifier.user.ulevel.intValue <= 16) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_moon"];
        _levelView.backgroundColor = COLOR_4A87F6;
    } else if (_notifier.user.ulevel.intValue >= 17 && _notifier.user.ulevel.intValue <= 31) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_sun"];
        _levelView.backgroundColor = COLOR_FA9F47;
    } else if (_notifier.user.ulevel.intValue >= 32 && _notifier.user.ulevel.intValue <= 63) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_crown"];
        _levelView.backgroundColor = COLOR_FAD247;
    } else if (_notifier.user.ulevel.intValue >= 64 && _notifier.user.ulevel.intValue <= 127) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_golden_crown"];
        _levelView.backgroundColor = COLOR_5061E4;
    } else {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_purple_crown"];
        _levelView.backgroundColor = COLOR_AC47FA;
    }
    _levelLabel.text = [_notifier.user.ulevel stringValue];
}

- (IBAction)statusSwitchDidChange:(UISwitch *)sender {

    if (_statusSwitchBlock) {
        _statusSwitchBlock(sender);
    }
}




//- (BOOL)isOn {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    return [defaults boolForKey:_nickNameLabel.text];
//}
//
//- (void)setOn:(BOOL)on {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    [defaults setBool:on forKey:_nickNameLabel.text];
//    
//    //保存一下
//    [defaults synchronize];
//    
//}
@end
